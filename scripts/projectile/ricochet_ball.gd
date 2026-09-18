class_name RicochetBall
extends CharacterBody2D

## Base do projétil. Nesta primeira fatia ele voa em linha reta e expira;
## a reflexão entra no próximo slice sem mudar o contrato de lançamento.

signal finished(reason: String)

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var _config: ProjectileConfig
var _lifetime_remaining: float = 0.0
var _has_launched: bool = false
var _has_finished: bool = false

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
	_apply_collision_radius()
	queue_redraw()

func cancel() -> void:
	_finish("cancelled")

func _physics_process(delta: float) -> void:
	if not _has_launched or _has_finished:
		return

	_lifetime_remaining -= delta
	if _lifetime_remaining <= 0.0:
		_finish("lifetime")
		return

	var collision := move_and_collide(velocity * delta, false, 0.08, false)
	if collision != null:
		_finish("collision")

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
