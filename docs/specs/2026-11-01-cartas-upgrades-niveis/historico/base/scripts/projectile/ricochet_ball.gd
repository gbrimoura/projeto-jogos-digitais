class_name RicochetBall
extends CharacterBody2D

const ImpactSparkEffect = preload("res://scripts/projectile/impact_spark.gd")

const CombatFeedbackScript = preload("res://scripts/feedback/combat_feedback.gd")

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

var _config: ProjectileConfig
var _lifetime_remaining: float = 0.0
var _has_launched: bool = false
var _has_finished: bool = false
var _stop_sweep_requested: bool = false
var _bounce_count: int = 0
var _pending_motion: Vector2 = Vector2.ZERO
var _damaged_targets_this_tick: Dictionary = {}
var _racket_controller: Node
var _last_parry_swing_id: int = -1
var _parry_release_pending: bool = false
var _return_target: Node2D
var _is_returning: bool = false
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
	velocity = launch_direction * _config.speed
	_lifetime_remaining = _config.lifetime
	_has_launched = true
	_is_returning = false
	_stop_sweep_requested = false
	_set_charge_state(ChargeState.INACTIVE)
	_bounce_count = 0
	_pending_motion = Vector2.ZERO
	_parry_release_pending = true
	if is_instance_valid(collision_shape):
		collision_shape.set_deferred("disabled", false)
	_apply_collision_radius()
	queue_redraw()

func set_return_target(target: Node2D) -> void:
	_return_target = target


func _start_returning() -> void:
	if _has_finished or _is_returning:
		return
	_is_returning = true
	velocity = Vector2.ZERO
	_pending_motion = Vector2.ZERO
	if is_instance_valid(collision_shape):
		collision_shape.set_deferred("disabled", true)
	queue_redraw()


func _return_to_player(delta: float) -> void:
	if not is_instance_valid(_return_target):
		_finish("return_target_missing")
		return

	var destination := _return_target.global_position
	var capture_distance := maxf(_projectile_radius() + 8.0, 14.0)
	if global_position.distance_to(destination) <= capture_distance:
		global_position = destination
		_finish("returned")
		return

	var return_speed := maxf(_config.speed * 1.5, 150.0)
	global_position = global_position.move_toward(destination, return_speed * delta)

func cancel() -> void:
	_finish("cancelled")

## Synchronous and callback-safe: asks the active sweep to return without
## changing collision state or ending the node inside an external callback.
func request_stop_sweep() -> void:
	_stop_sweep_requested = true

func _physics_process(delta: float) -> void:
	if not _has_launched or _has_finished or _stop_sweep_requested:
		return

	if _is_returning:
		_return_to_player(delta)
		return
	_damaged_targets_this_tick.clear()
	_update_parry_release_lock()

	var motion_delta := minf(delta, maxf(_lifetime_remaining, 0.0))
	var expires_after_motion := _lifetime_remaining <= delta
	_lifetime_remaining = maxf(_lifetime_remaining - delta, 0.0)

	var remaining_motion := _pending_motion + velocity * motion_delta
	_pending_motion = Vector2.ZERO
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
		var segment_duration := minf(segment_distance / segment_speed, maxf(delta - frame_elapsed, 0.0))
		var parry_hit := _get_parry_hit(remaining_motion, frame_elapsed, segment_duration)
		var collision := move_and_collide(remaining_motion, false, safe_margin, false)
		var world_fraction: float = 1.0
		if collision != null and segment_distance > 0.0:
			world_fraction = clampf(collision.get_travel().length() / segment_distance, 0.0, 1.0)

		if not parry_hit.is_empty():
			var parry_fraction := float(parry_hit.get("fraction", INF))
			var parry_precedes_world := collision == null or parry_fraction < world_fraction - 0.00001
			if parry_precedes_world:
				var parry_position := segment_start + remaining_motion * parry_fraction
				var parry_scene_root := get_tree().current_scene
				global_position = parry_position
				velocity = Vector2(parry_hit.get("direction", Vector2.ZERO)).normalized() * _config.speed
				if velocity.is_zero_approx():
					velocity = Vector2.RIGHT * _config.speed
				_last_parry_swing_id = int(parry_hit.get("swing_id", -1))
				_parry_release_pending = true
				CombatFeedbackScript.enqueue(
					parry_scene_root,
					parry_position,
					CombatFeedbackScript.EffectKind.PARRY
				)
				_arm_reactive_charge()
				_notify_parry_success(_last_parry_swing_id)
				if _has_finished or _stop_sweep_requested:
					return
				_pending_motion = Vector2.ZERO
				frame_elapsed = minf(frame_elapsed + segment_duration * parry_fraction, delta)
				remaining_motion = velocity.normalized() * segment_distance * (1.0 - parry_fraction)
				continue

		if collision == null:
			if expires_after_motion:
				_finish("lifetime")
			return

		collisions_this_tick += 1
		frame_elapsed = minf(frame_elapsed + collision.get_travel().length() / segment_speed, delta)
		var surface_normal := collision.get_normal().normalized()
		if surface_normal.is_zero_approx():
			_finish("invalid_collision")
			return

		if not BounceResolver.should_bounce(velocity, surface_normal):
			global_position += surface_normal * _config.collision_skin
			velocity = BounceResolver.slide_velocity(velocity, surface_normal, _config.speed)
			var grazing_remainder := collision.get_remainder()
			if grazing_remainder.is_zero_approx() or velocity.is_zero_approx():
				if expires_after_motion:
					_finish("lifetime")
				return
			remaining_motion = velocity.normalized() * grazing_remainder.length()
			continue

		var next_bounce_index := _bounce_count + 1
		if next_bounce_index > _config.max_bounces:
			_start_returning()
			return

		_bounce_count = next_bounce_index
		velocity = BounceResolver.reflect_velocity(velocity, surface_normal, _config.speed)
		var impact_position := collision.get_position()
		var impact_scene_root := get_tree().current_scene
		var collider := collision.get_collider()
		global_position += surface_normal * _config.collision_skin
		_apply_impact_damage(collider, impact_position, impact_scene_root)
		if _has_finished or _stop_sweep_requested:
			return
		if not _is_damageable_collider(collider):
			_enqueue_wall_spark(impact_scene_root, impact_position)
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
		remaining_motion = velocity.normalized() * remainder.length()

	if not remaining_motion.is_zero_approx():
		if expires_after_motion:
			_finish("lifetime")
		else:
			_pending_motion = remaining_motion
	elif expires_after_motion:
		_finish("lifetime")

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

func _apply_impact_damage(collider: Object, impact_position: Vector2, feedback_scene_root: Node) -> void:
	if _config == null or _config.damage <= 0 or not collider is Node:
		return

	var target := collider as Node
	if not target.is_in_group("damageable") or not target.has_method("take_damage"):
		return
	if _damaged_targets_this_tick.has(target):
		return

	_damaged_targets_this_tick[target] = true
	var was_charged := _charge_state == ChargeState.CHARGED
	var damage_amount := _config.damage
	if was_charged:
		damage_amount += maxi(_config.charged_damage_bonus, 0)
	var damage_result: Variant = target.call("take_damage", damage_amount, self)
	var damage_was_accepted := typeof(damage_result) == TYPE_BOOL and bool(damage_result)
	if not damage_was_accepted:
		return
	var effect_kind: int = (
		CombatFeedbackScript.EffectKind.CHARGED_HIT
		if was_charged
		else CombatFeedbackScript.EffectKind.ENEMY_HIT
	)
	CombatFeedbackScript.enqueue(feedback_scene_root, impact_position, effect_kind)
	if was_charged and _charge_state == ChargeState.CHARGED:
		_set_charge_state(ChargeState.CONSUMED)

func _enqueue_wall_spark(scene_root: Node, impact_position: Vector2) -> void:
	if not is_instance_valid(scene_root) or scene_root.is_queued_for_deletion():
		return
	var scene_tree := get_tree()
	if scene_tree == null or scene_tree.current_scene != scene_root:
		return
	var spark := ImpactSparkEffect.new() as Node2D
	if spark == null:
		return
	spark.top_level = true
	spark.global_position = impact_position
	scene_root.call_deferred("add_child", spark)

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
	if _charge_state == ChargeState.CHARGED:
		_set_charge_state(ChargeState.CONSUMED)
	finished.emit(reason)
	queue_free()

func _draw() -> void:
	var visual_radius := 8.0
	if _config != null:
		visual_radius = _config.collision_radius
	var fill_color := Color("#f0b35b") if is_parryable else Color("#b88ce0")
	var rim_color := Color("#ffdf9a") if is_parryable else Color("#e0c5ff")

	draw_circle(Vector2.ZERO, visual_radius + 2.0, Color("#101722"))
	draw_circle(Vector2.ZERO, visual_radius, fill_color)
	draw_arc(Vector2.ZERO, visual_radius, 0.0, TAU, 24, rim_color, 1.5, true)
	draw_circle(
		Vector2(-visual_radius * 0.35, -visual_radius * 0.35),
		maxf(visual_radius * 0.2, 1.0),
		Color("#fff2ca")
	)
