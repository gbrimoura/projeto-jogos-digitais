class_name PlayerHealth
extends Node

signal health_changed(current_health: int, maximum_health: int)
signal died

@export_range(1, 100, 1) var maximum_health: int = 5
@export_range(0.0, 5.0, 0.05) var invulnerability_duration: float = 0.8

var current_health: int
var _invulnerability_remaining: float = 0.0
var is_dead: bool:
	get:
		return current_health <= 0
var is_invulnerable: bool:
	get:
		return _invulnerability_remaining > 0.0

func _ready() -> void:
	current_health = maxi(maximum_health, 1)
	health_changed.emit(current_health, maximum_health)

func restore_health_for_room_transition(restored_current: int, restored_maximum: int) -> bool:
	if is_dead:
		return false
	maximum_health = clampi(restored_maximum, 1, 100)
	current_health = clampi(restored_current, 1, maximum_health)
	_invulnerability_remaining = 0.0
	health_changed.emit(current_health, maximum_health)
	return true
func take_damage(amount: int, _source: Node = null) -> bool:
	if amount <= 0 or is_dead or is_invulnerable:
		return false
	current_health = maxi(current_health - amount, 0)
	_invulnerability_remaining = maxf(invulnerability_duration, 0.0)
	health_changed.emit(current_health, maximum_health)
	if is_dead:
		died.emit()
	return true

func _process(delta: float) -> void:
	_invulnerability_remaining = maxf(_invulnerability_remaining - delta, 0.0)

