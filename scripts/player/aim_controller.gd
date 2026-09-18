class_name AimController
extends Node2D

## Camada de mira independente da locomocao. A bola e a reticula poderao ler
## estes dados depois sem escrever em velocity ou no estado de movimento.

signal aim_changed(direction: Vector2, target_position: Vector2)

@export_range(0.0, 64.0, 0.1)
var minimum_aim_distance: float = 1.0

var _aim_direction: Vector2 = Vector2.RIGHT
var _aim_target_position: Vector2 = Vector2.ZERO

var aim_direction: Vector2:
	get:
		return _aim_direction

var aim_target_position: Vector2:
	get:
		return _aim_target_position

func _ready() -> void:
	_aim_target_position = global_position + _aim_direction * 64.0
	_update_aim()

func _process(_delta: float) -> void:
	_update_aim()

func get_aim_direction() -> Vector2:
	return _aim_direction

func get_aim_target_position() -> Vector2:
	return _aim_target_position

func _update_aim() -> void:
	var new_target_position := get_global_mouse_position()
	var offset := new_target_position - global_position
	var new_direction := _aim_direction
	var minimum_distance_squared := minimum_aim_distance * minimum_aim_distance

	if offset.length_squared() > minimum_distance_squared:
		new_direction = offset.normalized()

	var direction_changed := not new_direction.is_equal_approx(_aim_direction)
	var target_changed := not new_target_position.is_equal_approx(_aim_target_position)
	_aim_direction = new_direction
	_aim_target_position = new_target_position

	if direction_changed or target_changed:
		aim_changed.emit(_aim_direction, _aim_target_position)
