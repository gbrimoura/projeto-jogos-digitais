class_name HostileRivet
extends CharacterBody2D

const CombatFeedbackScript = preload("res://scripts/feedback/combat_feedback.gd")

signal finished(reason: String)

@export var is_parryable: bool = true

@onready var _visuals: Node2D = $Visuals
@onready var _collision_shape: CollisionShape2D = $CollisionShape2D

var _source: Node
var _source_instance_id: int = 0
var _damage: int = 1
var _lifetime_remaining: float = 2.0
var _launch_speed: float = 0.0
var _has_launched: bool = false
var _has_finished: bool = false
var _stop_sweep_requested: bool = false
var _is_friendly: bool = false
var _damaged_targets: Dictionary = {}
var _racket_controller: Node
var _last_parry_swing_id: int = -1
var _parry_release_pending: bool = false

func _ready() -> void:
	if not is_parryable:
		_visuals.modulate = Color("#c9a1e8")

func launch(direction: Vector2, source: Node, speed: float, damage: int, lifetime: float) -> void:
	if _has_launched or _has_finished:
		return
	var normalized_direction := direction.normalized()
	if normalized_direction.is_zero_approx():
		normalized_direction = Vector2.LEFT
	_source = source
	_source_instance_id = source.get_instance_id() if is_instance_valid(source) else 0
	_damage = maxi(damage, 0)
	_lifetime_remaining = maxf(lifetime, 0.01)
	_launch_speed = maxf(speed, 0.0)
	velocity = normalized_direction * _launch_speed
	_has_launched = true
	_stop_sweep_requested = false
	_visuals.rotation = normalized_direction.angle()

func cancel() -> void:
	_finish("cancelled")

## Synchronous and callback-safe; final removal belongs to post-flush cleanup.
func request_stop_sweep() -> void:
	_stop_sweep_requested = true

func _physics_process(delta: float) -> void:
	if not _has_launched or _has_finished or _stop_sweep_requested:
		return
	_update_parry_release_lock()
	var motion_time := minf(delta, _lifetime_remaining)
	_lifetime_remaining = maxf(_lifetime_remaining - delta, 0.0)
	var motion := velocity * motion_time
	var segment_start := global_position
	var parry_hit := _get_parry_hit(motion, motion_time)
	var collision := move_and_collide(motion, false, 0.01, false)
	var world_fraction: float = 1.0
	if collision != null and motion.length_squared() > 0.0:
		world_fraction = clampf(collision.get_travel().length() / motion.length(), 0.0, 1.0)

	if not parry_hit.is_empty():
		var parry_fraction := float(parry_hit.get("fraction", INF))
		var parry_precedes_world := collision == null or parry_fraction < world_fraction - 0.00001
		if parry_precedes_world:
			global_position = segment_start + motion * parry_fraction
			_apply_parry(parry_hit)
			if _has_finished or _stop_sweep_requested:
				return
			var remaining_distance := motion.length() * (1.0 - parry_fraction)
			if remaining_distance > 0.0001 and not _has_finished and not _stop_sweep_requested:
				var outgoing_collision := move_and_collide(velocity.normalized() * remaining_distance, false, 0.01, false)
				if outgoing_collision != null:
					_apply_impact(outgoing_collision.get_collider(), outgoing_collision.get_position())
					if _has_finished or _stop_sweep_requested:
						return
					_finish("impact")
					return
			if _has_finished or _stop_sweep_requested:
				return
			if _lifetime_remaining <= 0.0:
				_finish("lifetime")
			return

	if collision != null:
		_apply_impact(collision.get_collider(), collision.get_position())
		if _has_finished or _stop_sweep_requested:
			return
		_finish("impact")
		return
	if _lifetime_remaining <= 0.0:
		_finish("lifetime")

func _get_parry_hit(motion: Vector2, segment_duration: float) -> Dictionary:
	if not is_parryable or _parry_release_pending or motion.is_zero_approx():
		return {}
	var controller := _find_racket_controller()
	if controller == null:
		return {}
	var hit: Variant = controller.call(
		"get_sweep_hit",
		global_position,
		motion,
		_projectile_radius(),
		0.0,
		segment_duration,
		_last_parry_swing_id,
		_parry_release_pending
	)
	return hit if hit is Dictionary else {}

func _apply_parry(parry_hit: Dictionary) -> void:
	var parry_position := global_position
	var parry_scene_root := get_tree().current_scene
	var direction := Vector2(parry_hit.get("direction", Vector2.ZERO)).normalized()
	if direction.is_zero_approx():
		direction = Vector2.LEFT
	_is_friendly = true
	var controller := _find_racket_controller()
	var player: Node = controller.get_parent() if controller != null else null
	if player != null:
		_source = player
		_source_instance_id = player.get_instance_id()
	_last_parry_swing_id = int(parry_hit.get("swing_id", -1))
	_parry_release_pending = true
	velocity = direction * _launch_speed
	_visuals.rotation = direction.angle()
	_visuals.modulate = Color("#77e7bd")
	collision_mask = 9 # World (1) + Damageable (8); deliberately excludes Player (2).
	CombatFeedbackScript.enqueue(
		parry_scene_root,
		parry_position,
		CombatFeedbackScript.EffectKind.PARRY
	)
	_notify_parry_success(_last_parry_swing_id)

func _apply_impact(collider: Object, impact_position: Vector2) -> void:
	if _damage <= 0 or not collider is Node:
		return
	var target := collider as Node
	var target_id := target.get_instance_id()
	if target_id == _source_instance_id or _damaged_targets.has(target_id):
		return
	if _is_friendly:
		if not target.is_in_group("damageable") or not target.has_method("take_damage"):
			return
	elif not target.is_in_group("player") or not target.has_method("take_damage"):
		return
	_damaged_targets[target_id] = true
	var valid_source: Node = _source if is_instance_valid(_source) else null
	var feedback_scene_root := get_tree().current_scene
	var damage_result: Variant = target.call("take_damage", _damage, valid_source)
	if _is_friendly and typeof(damage_result) == TYPE_BOOL and bool(damage_result):
		CombatFeedbackScript.enqueue(
			feedback_scene_root,
			impact_position,
			CombatFeedbackScript.EffectKind.ENEMY_HIT
		)

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
	if _collision_shape.shape is CircleShape2D:
		return (_collision_shape.shape as CircleShape2D).radius
	return 0.0

func _notify_parry_success(swing_id: int) -> void:
	var controller := _find_racket_controller()
	if controller != null and controller.has_method("register_parry_success"):
		controller.call("register_parry_success", swing_id)

func _finish(reason: String) -> void:
	if _has_finished:
		return
	_has_finished = true
	collision_layer = 0
	collision_mask = 0
	finished.emit(reason)
	queue_free()
