class_name PlayerHealth
extends Node

signal health_changed(current_health: int, maximum_health: int)
signal damage_accepted(amount: int, current_health: int, maximum_health: int)
signal died

@export_range(1, 100, 1) var maximum_health: int = 5
@export_range(0.0, 5.0, 0.05) var invulnerability_duration: float = 0.5

var current_health: int
var _base_maximum_health: int = 5
var _invulnerability_remaining: float = 0.0

const UpgradeCatalogScript = preload("res://scripts/progression/upgrade_catalog.gd")
var is_dead: bool:
	get:
		return current_health <= 0
var is_invulnerable: bool:
	get:
		return _invulnerability_remaining > 0.0

func _ready() -> void:
	_base_maximum_health = maxi(maximum_health, 1)
	current_health = maxi(maximum_health, 1)
	health_changed.emit(current_health, maximum_health)

func get_base_maximum_health() -> int:
	return _base_maximum_health

func apply_run_build(build: RunBuild, acquired_upgrade_id: StringName = &"", previous_rank: int = 0) -> void:
	var chassis_rank := build.count_for(&"chassi_reforcado") if build != null else 0
	maximum_health = UpgradeCatalogScript.maximum_health(_base_maximum_health, chassis_rank)
	current_health = clampi(current_health, 0, maximum_health)
	if not acquired_upgrade_id.is_empty() and current_health > 0:
		var recovered := UpgradeCatalogScript.acquisition_heal(
			acquired_upgrade_id,
			previous_rank,
			build.count_for(acquired_upgrade_id) if build != null else previous_rank
		)
		current_health = mini(current_health + recovered, maximum_health)
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
	damage_accepted.emit(amount, current_health, maximum_health)
	if is_dead:
		died.emit()
	return true

func _process(delta: float) -> void:
	_invulnerability_remaining = maxf(_invulnerability_remaining - delta, 0.0)

