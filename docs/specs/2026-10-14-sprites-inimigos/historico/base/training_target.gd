class_name TrainingTarget
extends StaticBody2D

## Alvo estático provisório para validar o primeiro contato de combate.

signal defeated

@export_range(1, 100, 1)
var max_health: int = 3

@export_range(0.0, 1.0, 0.01)
var flash_duration: float = 0.12

@onready var _body_fill: Polygon2D = $Visuals/BodyFill
@onready var _health_fill: Polygon2D = $Visuals/HealthFill

var health: int
var _flash_remaining: float = 0.0
var _defeated_emitted: bool = false

func _ready() -> void:
	health = maxi(max_health, 1)
	add_to_group("damageable")
	add_to_group("combat_enemy")
	_update_visuals()

func take_damage(amount: int, _source: Node = null) -> bool:
	if _defeated_emitted or health <= 0 or amount <= 0:
		return false

	health = maxi(health - amount, 0)
	_flash_remaining = maxf(flash_duration, 0.0)
	_update_visuals()
	if health == 0:
		_defeated_emitted = true
		defeated.emit()
		queue_free()
	return true

func _process(delta: float) -> void:
	if _flash_remaining <= 0.0:
		return

	_flash_remaining = maxf(_flash_remaining - delta, 0.0)
	_update_visuals()

func _update_visuals() -> void:
	if not is_instance_valid(_body_fill) or not is_instance_valid(_health_fill):
		return

	_body_fill.color = Color("#fff1c7") if _flash_remaining > 0.0 else Color("#384759")
	var health_ratio := clampf(float(health) / float(maxi(max_health, 1)), 0.0, 1.0)
	_health_fill.scale.x = health_ratio
