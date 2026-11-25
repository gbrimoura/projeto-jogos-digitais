class_name RicochetBall
extends CharacterBody2D

const CombatFeedbackScript = preload("res://scripts/feedback/combat_feedback.gd")
const UpgradeCatalogScript = preload("res://scripts/progression/upgrade_catalog.gd")

enum ChargeState { INACTIVE, CHARGED, CONSUMED }

## Bola cinética com reflexão determinística. O parry redireciona o voo atual,
## preservando velocidade, ricochetes já usados e tempo de vida restante.

signal finished(reason: String)
signal bounced(bounce_index: int, impact_position: Vector2, surface_normal: Vector2)

@export var is_parryable: bool = true
@export_range(0.25, 8.0, 0.25) var charged_pulse_frequency_hz: float = 3.0
@export_range(0.2, 0.9, 0.05) var charged_pulse_min_alpha: float = 0.55
@export_range(1.0, 1.8, 0.05) var charged_pulse_width_multiplier: float = 1.3

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var _charge_visual: Line2D = $ChargeVisual

const HEAT_SAMPLE_INTERVAL: float = 0.04
const HEAT_TOUCH_RADIUS: float = 24.0
const FORGE_RADIUS: float = 92.0
const MAGNET_RANGE: float = 175.0
const BOUNCE_SPEED_BONUS_PER_BOUNCE: float = 0.1
const MAX_BOUNCE_SPEED_MULTIPLIER: float = 1.6

var fragment_scene: PackedScene
var _heat_points: Array[Vector2] = []
var _heat_ages: Array[float] = []
var _heat_targets: Dictionary = {}
var _heat_sample_delay: float = 0.0
var _forge_used: bool = false
var _forge_flash: float = 0.0
var _forge_center: Vector2
var _accelerated_trail: Array[Vector2] = []

var _config: ProjectileConfig
var _lifetime_remaining: float = 0.0
var _has_launched: bool = false
var _has_finished: bool = false
var _stop_sweep_requested: bool = false
var _bounce_count: int = 0
var _bounce_speed_multiplier: float = 1.0
var _environmental_bounce_count: int = 0
var _environmental_bounce_speed_multiplier: float = 1.0
var _parry_speed_multiplier: float = 1.0
var _opening_impact_bonus_consumed: bool = false
var _pending_motion: Vector2 = Vector2.ZERO
var _pending_motion_time: float = 0.0
var _damaged_targets_this_tick: Dictionary = {}
var _racket_controller: Node
var _last_parry_swing_id: int = -1
var _parry_release_pending: bool = false
var _return_target: Node2D
var _is_returning: bool = false
var _measured_return_speed: float = 0.0
var _charge_state: ChargeState = ChargeState.INACTIVE
var _charge_pulse_elapsed: float = 0.0
var _charge_visual_base_color: Color = Color.WHITE
var _charge_visual_base_width: float = 2.5

var bounce_count: int:
	get:
		return _bounce_count

func _ready() -> void:
	_charge_visual_base_color = _charge_visual.default_color
	_charge_visual_base_width = _charge_visual.width
	_set_charge_state(_charge_state)

func _process(delta: float) -> void:
	if _forge_flash > 0.0:
		_forge_flash = maxf(_forge_flash - delta, 0.0)
		queue_redraw()
	if _charge_state != ChargeState.CHARGED or not is_instance_valid(_charge_visual):
		return
	_charge_pulse_elapsed += delta
	var pulse := (sin(_charge_pulse_elapsed * TAU * charged_pulse_frequency_hz) + 1.0) * 0.5
	var pulsed_color := _charge_visual_base_color
	pulsed_color.a *= lerpf(charged_pulse_min_alpha, 1.0, pulse)
	_charge_visual.default_color = pulsed_color
	_charge_visual.width = _charge_visual_base_width * lerpf(1.0, charged_pulse_width_multiplier, pulse)

func launch(direction: Vector2, config: ProjectileConfig) -> void:
	if _has_launched or _has_finished or config == null:
		return

	_config = config
	var launch_direction := direction.normalized()
	if launch_direction.is_zero_approx():
		launch_direction = Vector2.RIGHT
	_environmental_bounce_speed_multiplier = 1.0
	_parry_speed_multiplier = 1.0
	_bounce_speed_multiplier = 1.0
	_opening_impact_bonus_consumed = false
	velocity = launch_direction * _current_projectile_speed()
	_lifetime_remaining = _config.lifetime
	_has_launched = true
	_is_returning = false
	_stop_sweep_requested = false
	_set_charge_state(ChargeState.INACTIVE)
	_bounce_count = 0
	_environmental_bounce_count = 0
	_pending_motion = Vector2.ZERO
	_pending_motion_time = 0.0
	_parry_release_pending = true
	if is_instance_valid(collision_shape):
		collision_shape.set_deferred("disabled", false)
	_apply_collision_radius()
	queue_redraw()

func get_ball_speed() -> float:
	if not _has_launched or _config == null or _has_finished or _stop_sweep_requested:
		return 0.0
	return _measured_return_speed if _is_returning else velocity.length()

func set_return_target(target: Node2D) -> void:
	_return_target = target


func _start_returning() -> void:
	if _has_finished or _is_returning:
		return
	if _config.is_fragment:
		_finish("fragment_spent")
		return
	_is_returning = true
	_measured_return_speed = 0.0
	_heat_points.clear()
	_heat_ages.clear()
	_accelerated_trail.clear()
	velocity = Vector2.ZERO
	_pending_motion = Vector2.ZERO
	_pending_motion_time = 0.0
	if is_instance_valid(collision_shape):
		collision_shape.set_deferred("disabled", true)
	queue_redraw()


func _return_to_player(delta: float) -> void:
	_measured_return_speed = 0.0
	if not is_instance_valid(_return_target):
		_finish("return_target_missing")
		return

	var destination := _return_target.global_position
	var capture_distance := maxf(_projectile_radius() + 8.0, 14.0)
	if global_position.distance_to(destination) <= capture_distance:
		global_position = destination
		for child in get_children():
			if child is RicochetBall and not child.is_queued_for_deletion():
				return
		_finish("returned")
		return

	var return_speed_multiplier := clampf(_config.return_speed_multiplier, 1.0, 1.5)
	var return_speed := maxf(_current_projectile_speed() * 1.5 * return_speed_multiplier, 150.0)
	var previous_position := global_position
	global_position = global_position.move_toward(destination, return_speed * delta)
	if delta > 0.0:
		_measured_return_speed = previous_position.distance_to(global_position) / delta

func cancel() -> void:
	_finish("cancelled")

## Synchronous and callback-safe: asks the active sweep to return without
## changing collision state or ending the node inside an external callback.
func request_stop_sweep() -> void:
	_stop_sweep_requested = true
	for child in get_children():
		if child is RicochetBall:
			child.request_stop_sweep()

func _physics_process(delta: float) -> void:
	if not _has_launched or _has_finished or _stop_sweep_requested:
		return

	if _is_returning:
		_return_to_player(delta)
		return
	_damaged_targets_this_tick.clear()
	_update_parry_release_lock()
	_update_upgrade_effects(delta)
	if _has_finished or _stop_sweep_requested:
		return

	var motion_delta := minf(delta, maxf(_lifetime_remaining, 0.0))
	var expires_after_motion := _lifetime_remaining <= delta
	_lifetime_remaining = maxf(_lifetime_remaining - delta, 0.0)

	var pending_motion_time := _pending_motion_time
	var motion_time_budget := pending_motion_time + motion_delta
	var remaining_motion := _pending_motion + velocity * motion_delta
	_pending_motion = Vector2.ZERO
	_pending_motion_time = 0.0
	var collisions_this_tick := 0
	var frame_elapsed: float = 0.0
	var collision_limit := maxi(_config.max_collisions_per_tick, 1)
	if expires_after_motion:
		collision_limit = maxi(collision_limit, _config.max_bounces + 4)
	var safe_margin := maxf(_config.collision_safe_margin, 0.01)

	while not _stop_sweep_requested and not remaining_motion.is_zero_approx() and collisions_this_tick < collision_limit:
		var segment_start := global_position
		var segment_distance := remaining_motion.length()
		var segment_speed := maxf(velocity.length(), 0.001)
		var segment_duration := minf(segment_distance / segment_speed, maxf(motion_time_budget - frame_elapsed, 0.0))
		# Time carried from a prior tick is already present at the start of the racket window.
		var parry_frame_elapsed := frame_elapsed - pending_motion_time
		var parry_hit := _get_parry_hit(remaining_motion, parry_frame_elapsed, segment_duration)
		var collision := move_and_collide(remaining_motion, false, safe_margin, false)
		var world_fraction: float = 1.0
		if collision != null and segment_distance > 0.0:
			world_fraction = clampf(collision.get_travel().length() / segment_distance, 0.0, 1.0)

		if not parry_hit.is_empty():
			var parry_fraction := float(parry_hit.get("fraction", INF))
			var parry_precedes_world := collision == null or parry_fraction < world_fraction - 0.00001
			if parry_fraction >= 0.0 and parry_fraction <= 1.0 and parry_precedes_world:
				var parry_position := segment_start + remaining_motion * parry_fraction
				var parry_scene_root := get_tree().current_scene
				global_position = parry_position
				var parry_impact_speed := _impact_feedback_speed()
				_record_parry_speed_bonus()
				velocity = Vector2(parry_hit.get("direction", Vector2.ZERO)).normalized() * _current_projectile_speed()
				if velocity.is_zero_approx():
					velocity = Vector2.RIGHT * _current_projectile_speed()
				_last_parry_swing_id = int(parry_hit.get("swing_id", -1))
				_parry_release_pending = true
				CombatFeedbackScript.enqueue(
					parry_scene_root,
					parry_position,
					CombatFeedbackScript.EffectKind.PARRY,
					velocity.normalized(),
					parry_impact_speed,
					_feedback_scope(parry_scene_root)
				)
				_arm_reactive_charge()
				_bounce_count = 0
				_notify_parry_success(_last_parry_swing_id)
				if _has_finished or _stop_sweep_requested:
					return
				_pending_motion = Vector2.ZERO
				_pending_motion_time = 0.0
				frame_elapsed += segment_duration * parry_fraction
				remaining_motion = velocity * maxf(motion_time_budget - frame_elapsed, 0.0)
				continue

		if collision == null:
			if expires_after_motion:
				_finish("lifetime")
			return

		collisions_this_tick += 1
		frame_elapsed += minf(collision.get_travel().length() / segment_speed, segment_duration)
		var surface_normal := collision.get_normal().normalized()
		if surface_normal.is_zero_approx():
			_finish("invalid_collision")
			return

		if not BounceResolver.should_bounce(velocity, surface_normal):
			global_position += surface_normal * _config.collision_skin
			velocity = BounceResolver.slide_velocity(velocity, surface_normal, _current_projectile_speed())
			var grazing_remainder := collision.get_remainder()
			if grazing_remainder.is_zero_approx() or velocity.is_zero_approx():
				if expires_after_motion:
					_finish("lifetime")
				return
			remaining_motion = velocity * maxf(motion_time_budget - frame_elapsed, 0.0)
			continue

		var next_bounce_index := _bounce_count + 1
		if next_bounce_index > _config.max_bounces:
			_start_returning()
			return

		_bounce_count = next_bounce_index
		var incoming_speed := _impact_feedback_speed()
		_record_bounce_speed_bonus()
		var impact_position := collision.get_position()
		var impact_scene_root := get_tree().current_scene
		var impact_scope := _feedback_scope(impact_scene_root)
		var collider := collision.get_collider()
		var is_environmental_bounce := not _is_damageable_collider(collider)
		if is_environmental_bounce:
			_record_environmental_bounce()
		velocity = BounceResolver.reflect_velocity(velocity, surface_normal, _current_projectile_speed())
		global_position += surface_normal * _config.collision_skin
		_apply_impact_damage(collider, impact_position, impact_scene_root, impact_scope, surface_normal, incoming_speed)
		if _has_finished or _stop_sweep_requested:
			return
		if is_environmental_bounce:
			CombatFeedbackScript.enqueue(
				impact_scene_root, impact_position, CombatFeedbackScript.EffectKind.WALL_RICOCHET,
				surface_normal, incoming_speed, impact_scope
			)
			if _config.splits_on_wall and _environmental_bounce_count == 1:
				_spawn_fragments(surface_normal)
		bounced.emit(_bounce_count, impact_position, surface_normal)
		if _has_finished or _stop_sweep_requested:
			return

		if _bounce_count >= _config.max_bounces:
			_start_returning()
			return

		var remainder := collision.get_remainder()
		if remainder.is_zero_approx() or velocity.is_zero_approx():
			if expires_after_motion:
				_finish("lifetime")
			return
		remaining_motion = velocity * maxf(motion_time_budget - frame_elapsed, 0.0)

	if not remaining_motion.is_zero_approx():
		if expires_after_motion:
			_finish("lifetime")
		else:
			_pending_motion = remaining_motion
			_pending_motion_time = maxf(motion_time_budget - frame_elapsed, 0.0)
	elif expires_after_motion:
		_finish("lifetime")

func _current_projectile_speed() -> float:
	if _config == null:
		return 0.0
	var environmental_multiplier_cap := maxf(_config.max_environmental_bounce_speed_multiplier, 1.0)
	var environmental_multiplier := clampf(
		_environmental_bounce_speed_multiplier,
		1.0,
		environmental_multiplier_cap
	)
	var parry_multiplier_cap := maxf(_config.max_parry_speed_multiplier, 1.0)
	var parry_multiplier := clampf(_parry_speed_multiplier, 1.0, parry_multiplier_cap)
	return maxf(_config.speed, 0.0) * _bounce_speed_multiplier * environmental_multiplier * parry_multiplier

func _record_bounce_speed_bonus() -> void:
	if _config == null or _config.is_fragment:
		return
	_bounce_speed_multiplier = minf(
		_bounce_speed_multiplier + BOUNCE_SPEED_BONUS_PER_BOUNCE,
		MAX_BOUNCE_SPEED_MULTIPLIER
	)

func _record_environmental_bounce() -> void:
	_environmental_bounce_count += 1
	if _environmental_bounce_count == 1:
		_accelerated_trail.clear()
	if _config == null:
		return
	var speed_cap := maxf(_config.max_environmental_bounce_speed_multiplier, 1.0)
	var speed_bonus := maxf(_config.environmental_bounce_speed_bonus_per_bounce, 0.0)
	_environmental_bounce_speed_multiplier = minf(
		maxf(_environmental_bounce_speed_multiplier, 1.0) + speed_bonus,
		speed_cap
	)

func _record_parry_speed_bonus() -> void:
	if _config == null:
		return
	var speed_cap := maxf(_config.max_parry_speed_multiplier, 1.0)
	var speed_bonus := maxf(_config.parry_speed_bonus_per_success, 0.0)
	_parry_speed_multiplier = minf(
		maxf(_parry_speed_multiplier, 1.0) + speed_bonus,
		speed_cap
	)

func _get_parry_hit(motion: Vector2, frame_elapsed: float, segment_duration: float) -> Dictionary:
	if not is_parryable or _parry_release_pending:
		return {}
	var controller := _find_racket_controller()
	if controller == null:
		return {}
	var radius := 0.0
	if collision_shape.shape is CircleShape2D:
		radius = (collision_shape.shape as CircleShape2D).radius
	var hit: Variant = controller.call(
		"get_sweep_hit",
		global_position,
		motion,
		radius,
		frame_elapsed,
		segment_duration,
		_last_parry_swing_id,
		_parry_release_pending
	)
	return hit if hit is Dictionary else {}

func _find_racket_controller() -> Node:
	if is_instance_valid(_racket_controller):
		return _racket_controller
	for candidate in get_tree().get_nodes_in_group("racket_controller"):
		if is_instance_valid(candidate) and candidate.has_method("get_sweep_hit"):
			_racket_controller = candidate
			return _racket_controller
	return null

func _update_parry_release_lock() -> void:
	if not _parry_release_pending:
		return
	var controller := _find_racket_controller()
	if controller == null:
		return
	var origin: Vector2 = controller.call("get_parry_origin")
	var catch_radius: float = controller.call("get_catch_radius", _projectile_radius())
	if global_position.distance_to(origin) > catch_radius + 0.5:
		_parry_release_pending = false

func _projectile_radius() -> float:
	if collision_shape.shape is CircleShape2D:
		return (collision_shape.shape as CircleShape2D).radius
	return 0.0

func _notify_parry_success(swing_id: int) -> void:
	var controller := _find_racket_controller()
	if controller != null and controller.has_method("register_parry_success"):
		controller.call("register_parry_success", swing_id)

func _apply_impact_damage(
	collider: Object, impact_position: Vector2, feedback_scene_root: Node,
	feedback_scope: Node, surface_normal: Vector2, impact_speed: float
) -> void:
	if _config == null or _config.damage <= 0 or not collider is Node:
		return

	var target := collider as Node
	if not target.is_in_group("damageable") or not target.has_method("take_damage"):
		return
	if _damaged_targets_this_tick.has(target):
		return

	_damaged_targets_this_tick[target] = true
	var was_charged := _charge_state == ChargeState.CHARGED
	var can_apply_opening_impact_bonus := _environmental_bounce_count == 0 and not _opening_impact_bonus_consumed
	var impact_rank := _config.impact_rank if can_apply_opening_impact_bonus else 0
	var damage_amount := UpgradeCatalogScript.projectile_damage(
		_config.damage,
		impact_rank,
		_config.charge_rank,
		was_charged and _config.reactive_charge_enabled,
		_config.pressure_rank,
		_environmental_bounce_count
	)
	var damage_result: Variant = target.call("take_damage", damage_amount, self)
	var damage_was_accepted := typeof(damage_result) == TYPE_BOOL and bool(damage_result)
	if not damage_was_accepted:
		return
	if can_apply_opening_impact_bonus and _config.impact_rank > 0:
		_opening_impact_bonus_consumed = true
	var effect_kind: int = (
		CombatFeedbackScript.EffectKind.CHARGED_HIT
		if was_charged
		else CombatFeedbackScript.EffectKind.ENEMY_HIT
	)
	CombatFeedbackScript.enqueue(
		feedback_scene_root, impact_position, effect_kind, surface_normal, impact_speed, feedback_scope
	)
	if was_charged and _charge_state == ChargeState.CHARGED:
		_set_charge_state(ChargeState.CONSUMED)
	if _config.has_forge and not _forge_used and _environmental_bounce_count > 0 and not _stop_sweep_requested:
		_trigger_forge(impact_position, target)

func _update_upgrade_effects(delta: float) -> void:
	if _config.environmental_bounce_speed_bonus_per_bounce > 0.0 or _bounce_speed_multiplier > 1.0:
		_accelerated_trail.append(global_position)
		if _accelerated_trail.size() > 8:
			_accelerated_trail.pop_front()
		queue_redraw()
	if _config.heat_rank > 0:
		_update_heat_trail(delta)
	if _config.magnet_rank > 0 and _environmental_bounce_count > 0:
		_steer_toward_enemy(delta)

func _update_heat_trail(delta: float) -> void:
	for index in range(_heat_ages.size() - 1, -1, -1):
		_heat_ages[index] -= delta
		if _heat_ages[index] <= 0.0:
			_heat_ages.remove_at(index)
			_heat_points.remove_at(index)
	queue_redraw()
	_heat_sample_delay -= delta
	if _heat_sample_delay > 0.0:
		return
	_heat_sample_delay = HEAT_SAMPLE_INTERVAL
	var extra_duration := 0.25 if _config.heat_rank > 1 and _last_parry_swing_id >= 0 else 0.0
	_heat_points.append(global_position)
	_heat_ages.append(0.32 + extra_duration + _config.heat_duration_bonus)
	for node in get_tree().get_nodes_in_group(&"combat_enemy"):
		var enemy := node as Node2D
		if not _can_affect_enemy(enemy) or _heat_targets.has(enemy.get_instance_id()):
			continue
		for point in _heat_points:
			var center := _enemy_center(enemy)
			if center.distance_squared_to(point) <= HEAT_TOUCH_RADIUS * HEAT_TOUCH_RADIUS and _has_clear_path(point, center):
				_apply_heat_damage.call_deferred(weakref(enemy))
				break

func _apply_heat_damage(target_ref: WeakRef) -> void:
	if _has_finished or _stop_sweep_requested or _is_returning:
		return
	var enemy := target_ref.get_ref() as Node2D
	if not _can_affect_enemy(enemy) or _damaged_targets_this_tick.has(enemy):
		return
	var id := enemy.get_instance_id()
	if _heat_targets.has(id):
		return
	var accepted: Variant = enemy.call("take_damage", _config.heat_trail_damage, self)
	if accepted is bool and accepted:
		_heat_targets[id] = true

func _steer_toward_enemy(delta: float) -> void:
	if velocity.is_zero_approx() or not _pending_motion.is_zero_approx():
		return
	var forward := velocity.normalized()
	var closest := MAGNET_RANGE * MAGNET_RANGE
	var target_offset := Vector2.ZERO
	for node in get_tree().get_nodes_in_group(&"combat_enemy"):
		var enemy := node as Node2D
		if not _can_affect_enemy(enemy):
			continue
		var center := _enemy_center(enemy)
		var offset := center - global_position
		var distance := offset.length_squared()
		if distance >= closest or forward.dot(offset.normalized()) < 0.35:
			continue
		if not _has_clear_path(global_position, center):
			continue
		target_offset = offset
		closest = distance
	if not target_offset.is_zero_approx():
		var turn_rate := 0.85 if _config.magnet_rank == 1 else 1.4
		var turn := clampf(forward.angle_to(target_offset), -turn_rate * delta, turn_rate * delta)
		velocity = velocity.rotated(turn)

func _trigger_forge(center: Vector2, direct_target: Node) -> void:
	_forge_used = true
	_forge_flash = 0.24
	_forge_center = center
	queue_redraw()
	for node in get_tree().get_nodes_in_group(&"combat_enemy"):
		var enemy := node as Node2D
		if enemy == direct_target or not _can_affect_enemy(enemy):
			continue
		var target_center := _enemy_center(enemy)
		if center.distance_squared_to(target_center) <= FORGE_RADIUS * FORGE_RADIUS and _has_clear_path(center, target_center):
			enemy.call("take_damage", 2, self)
		if _stop_sweep_requested:
			return

func _can_affect_enemy(enemy: Node2D) -> bool:
	return (
		is_instance_valid(enemy) and not enemy.is_queued_for_deletion()
		and enemy.is_in_group(&"damageable") and enemy.has_method("take_damage")
	)

func _enemy_center(enemy: Node2D) -> Vector2:
	var shape := enemy.get_node_or_null("CollisionShape2D") as CollisionShape2D
	return shape.global_position if shape != null else enemy.global_position

func _has_clear_path(origin: Vector2, destination: Vector2) -> bool:
	var query := PhysicsRayQueryParameters2D.create(origin, destination, 1)
	return get_world_2d().direct_space_state.intersect_ray(query).is_empty()

func _spawn_fragments(normal: Vector2) -> void:
	if fragment_scene == null or velocity.is_zero_approx():
		return
	for spread in [-_config.fragment_half_angle, _config.fragment_half_angle]:
		var direction := velocity.normalized().rotated(float(spread))
		if direction.dot(normal) <= 0.0:
			direction = (direction.slide(normal) + normal * 0.15).normalized()
		var fragment := fragment_scene.instantiate() as RicochetBall
		if fragment == null:
			continue
		var config := ProjectileConfig.new()
		config.speed = velocity.length() * 0.8
		config.lifetime = 0.45
		config.collision_radius = minf(_config.collision_radius * 0.5, 4.0)
		config.damage = _config.fragment_damage
		config.heat_rank = 1 if _config.fragments_leave_heat else 0
		config.max_bounces = 1
		config.is_fragment = true
		config.collision_mask = _config.collision_mask
		fragment.collision_layer = 0
		fragment.collision_mask = config.collision_mask
		fragment.is_parryable = false
		fragment.top_level = true
		fragment.position = global_position
		add_child(fragment)
		fragment.launch(direction, config)

func _impact_feedback_speed() -> float:
	return 0.0 if _config.is_fragment else velocity.length()

func _feedback_scope(scene_root: Node) -> Node:
	var ancestor := get_parent()
	while ancestor != null and ancestor != scene_root:
		if ancestor.has_node("CombatRoom"):
			return ancestor
		ancestor = ancestor.get_parent()
	return scene_root

func _is_damageable_collider(collider: Object) -> bool:
	return collider is Node and (collider as Node).is_in_group("damageable")

func _arm_reactive_charge() -> void:
	if _config == null or not _config.reactive_charge_enabled or _charge_state != ChargeState.INACTIVE:
		return
	_set_charge_state(ChargeState.CHARGED)

func _set_charge_state(next_state: ChargeState) -> void:
	_charge_state = next_state
	if is_instance_valid(_charge_visual):
		_charge_visual.visible = _charge_state == ChargeState.CHARGED
		if _charge_state == ChargeState.CHARGED:
			_charge_pulse_elapsed = 0.0
		else:
			_charge_visual.default_color = _charge_visual_base_color
			_charge_visual.width = _charge_visual_base_width

func _apply_collision_radius() -> void:
	if collision_shape.shape is not CircleShape2D:
		return
	var configured_shape := collision_shape.shape.duplicate() as CircleShape2D
	configured_shape.radius = _config.collision_radius
	collision_shape.shape = configured_shape

func _finish(reason: String) -> void:
	if _has_finished:
		return
	_has_finished = true
	request_stop_sweep()
	if _charge_state == ChargeState.CHARGED:
		_set_charge_state(ChargeState.CONSUMED)
	finished.emit(reason)
	queue_free()

func _draw() -> void:
	for index in _heat_points.size():
		var point := to_local(_heat_points[index]).snapped(Vector2(2.0, 2.0))
		var extent := 4.0 if _heat_ages[index] > 0.16 else 2.0
		draw_rect(Rect2(point - Vector2.ONE * extent, Vector2.ONE * extent * 2.0), Color("#e96d35"))
	if _environmental_bounce_speed_multiplier > 1.0 or _bounce_speed_multiplier > 1.0:
		var acceleration_ratio := _environmental_bounce_speed_multiplier * _bounce_speed_multiplier
		var streak_size := minf(2.0 + (acceleration_ratio - 1.0) * 10.0, 7.0)
		for point in _accelerated_trail:
			draw_rect(Rect2(to_local(point).snapped(Vector2(2.0, 2.0)), Vector2(streak_size, 2.0)), Color("#f7d762"))
	if _forge_flash > 0.0:
		draw_arc(to_local(_forge_center), lerpf(FORGE_RADIUS, 14.0, _forge_flash / 0.24), 0.0, TAU, 32, Color("#f58ac1"), 3.0)
	var visual_radius := 8.0
	if _config != null:
		visual_radius = _config.collision_radius
	var fill_color := Color("#f0b35b") if is_parryable else Color("#b88ce0")
	var rim_color := Color("#ffdf9a") if is_parryable else Color("#e0c5ff")

	if _config != null:
		if _config.has_forge:
			fill_color = Color("#f58ac1")
		elif _config.heat_rank > 0:
			fill_color = Color("#f47b3d")
		elif _config.magnet_rank > 0:
			fill_color = Color("#63dfe9")
	draw_circle(Vector2.ZERO, visual_radius + 2.0, Color("#101722"))
	draw_circle(Vector2.ZERO, visual_radius, fill_color)
	draw_arc(Vector2.ZERO, visual_radius, 0.0, TAU, 24, rim_color, 1.5, true)
	draw_circle(
		Vector2(-visual_radius * 0.35, -visual_radius * 0.35),
		maxf(visual_radius * 0.2, 1.0),
		Color("#fff2ca")
	)
