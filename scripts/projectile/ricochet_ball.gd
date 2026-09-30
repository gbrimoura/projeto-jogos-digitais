class_name RicochetBall
extends CharacterBody2D

## Bola cinética com reflexão determinística. O contrato de lançamento continua
## recebendo apenas a direção inicial e um Resource de configuração.

signal finished(reason: String)
signal bounced(bounce_index: int, impact_position: Vector2, surface_normal: Vector2)

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var _config: ProjectileConfig
var _lifetime_remaining: float = 0.0
var _has_launched: bool = false
var _has_finished: bool = false
var _bounce_count: int = 0
var _pending_motion: Vector2 = Vector2.ZERO
var _damaged_targets_this_tick: Dictionary = {}

var bounce_count: int:
	get:
		return _bounce_count

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
	_bounce_count = 0
	_pending_motion = Vector2.ZERO
	_apply_collision_radius()
	queue_redraw()

func cancel() -> void:
	_finish("cancelled")

func _physics_process(delta: float) -> void:
	if not _has_launched or _has_finished:
		return

	_damaged_targets_this_tick.clear()

	var motion_delta := minf(delta, maxf(_lifetime_remaining, 0.0))
	var expires_after_motion := _lifetime_remaining <= delta
	_lifetime_remaining = maxf(_lifetime_remaining - delta, 0.0)

	var remaining_motion := _pending_motion + velocity * motion_delta
	_pending_motion = Vector2.ZERO
	var collisions_this_tick := 0
	var collision_limit := maxi(_config.max_collisions_per_tick, 1)
	if expires_after_motion:
		collision_limit = maxi(collision_limit, _config.max_bounces + 4)
	var safe_margin := maxf(_config.collision_safe_margin, 0.01)

	while not remaining_motion.is_zero_approx() and collisions_this_tick < collision_limit:
		var collision := move_and_collide(remaining_motion, false, safe_margin, false)
		if collision == null:
			if expires_after_motion:
				_finish("lifetime")
			return

		collisions_this_tick += 1
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
			_finish("bounce_limit")
			return

		_bounce_count = next_bounce_index
		velocity = BounceResolver.reflect_velocity(velocity, surface_normal, _config.speed)
		var impact_position := collision.get_position()
		global_position += surface_normal * _config.collision_skin
		_apply_impact_damage(collision.get_collider())
		bounced.emit(_bounce_count, impact_position, surface_normal)

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

func _apply_impact_damage(collider: Object) -> void:
	if _config == null or _config.damage <= 0 or not collider is Node:
		return

	var target := collider as Node
	if not target.is_in_group("damageable") or not target.has_method("take_damage"):
		return
	if _damaged_targets_this_tick.has(target):
		return

	_damaged_targets_this_tick[target] = true
	target.call("take_damage", _config.damage, self)

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
	finished.emit(reason)
	queue_free()

func _draw() -> void:
	var visual_radius := 8.0
	if _config != null:
		visual_radius = _config.collision_radius

	draw_circle(Vector2.ZERO, visual_radius + 2.0, Color("#101722"))
	draw_circle(Vector2.ZERO, visual_radius, Color("#f0b35b"))
	draw_arc(Vector2.ZERO, visual_radius, 0.0, TAU, 24, Color("#ffdf9a"), 1.5, true)
	draw_circle(
		Vector2(-visual_radius * 0.35, -visual_radius * 0.35),
		maxf(visual_radius * 0.2, 1.0),
		Color("#fff2ca")
	)
