class_name PlayerVisual
extends Node2D

@onready var dash_trail: Line2D = $DashTrail

var _facing_direction: int = 1
var _is_dashing: bool = false
var _is_invulnerable: bool = false
var _is_dead: bool = false
var _dash_phase: float = 0.0

func _ready() -> void:
	_apply_facing()

func _process(delta: float) -> void:
	if _is_dead:
		return
	if _is_invulnerable:
		var damage_pulse := 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.035)
		modulate = Color(1.0, 0.56 + damage_pulse * 0.34, 0.5 + damage_pulse * 0.42, 0.45 + damage_pulse * 0.35)
	else:
		modulate = Color.WHITE
	if not _is_dashing:
		return

	_dash_phase = fmod(_dash_phase + delta * 16.0, TAU)
	var dash_pulse := 0.5 + 0.5 * sin(_dash_phase)
	dash_trail.scale.x = 1.0 + dash_pulse * 0.2

func set_facing_direction(direction: int) -> void:
	if direction == 0 or direction == _facing_direction:
		return
	_facing_direction = 1 if direction > 0 else -1
	_apply_facing()

func set_dashing(value: bool) -> void:
	if value == _is_dashing:
		return
	_is_dashing = value
	dash_trail.visible = _is_dashing
	if not _is_dashing:
		dash_trail.scale.x = 1.0

func set_invulnerable(value: bool) -> void:
	_is_invulnerable = value

func set_dead(value: bool) -> void:
	_is_dead = value
	_is_invulnerable = false
	if _is_dead:
		set_dashing(false)
		modulate = Color("#6f747a")
	else:
		modulate = Color.WHITE

func _apply_facing() -> void:
	scale.x = float(_facing_direction)
