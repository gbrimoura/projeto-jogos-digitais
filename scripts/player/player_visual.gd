class_name PlayerVisual
extends Node2D

@onready var dash_trail: Line2D = $DashTrail

var _facing_direction: int = 1
var _is_dashing: bool = false
var _dash_phase: float = 0.0

func _ready() -> void:
	_apply_facing()

func _process(delta: float) -> void:
	if not _is_dashing:
		return

	_dash_phase = fmod(_dash_phase + delta * 16.0, TAU)
	var pulse := 0.5 + 0.5 * sin(_dash_phase)
	dash_trail.scale.x = 1.0 + pulse * 0.2

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

func _apply_facing() -> void:
	scale.x = float(_facing_direction)
