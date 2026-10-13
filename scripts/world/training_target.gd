class_name TrainingTarget
extends StaticBody2D

## Alvo estático provisório para validar o primeiro contato de combate.

signal defeated

@export_range(1, 10, 1)
var contact_damage: int = 1

@export_range(0.1, 5.0, 0.1)
var contact_interval: float = 1.0

@export_range(16, 160, 1)
var contact_range: float = 72.0


@export_range(1, 100, 1)
var max_health: int = 3

@export_range(0.0, 1.0, 0.01)
var flash_duration: float = 0.12

@onready var _body_fill: Polygon2D = $Visuals/BodyFill
@onready var _health_fill: Polygon2D = $Visuals/HealthFill

var health: int
var _flash_remaining: float = 0.0
var _defeated_emitted: bool = false
var _player: Player
var _contact_cooldown: float = 0.0

func _ready() -> void:
	health = maxi(max_health, 1)
	add_to_group("damageable")
	call_deferred("_find_player")
	add_to_group("combat_enemy")
	_update_visuals()

func take_damage(amount: int, _source: Node = null) -> void:
	if _defeated_emitted or health <= 0 or amount <= 0:
		return

	health = maxi(health - amount, 0)
	_flash_remaining = maxf(flash_duration, 0.0)
	_update_visuals()
	if health == 0:
		_defeated_emitted = true
		defeated.emit()
		queue_free()

func _process(delta: float) -> void:
		_contact_cooldown = maxf(_contact_cooldown - delta, 0.0)

		if not is_instance_valid(_player):
			_find_player()

		if (
			is_instance_valid(_player)
			and _contact_cooldown <= 0.0
			and global_position.distance_to(_player.global_position) <= contact_range
		):
			_player.take_damage(contact_damage)
			_contact_cooldown = contact_interval
		
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

func _find_player() -> void:
	var candidate := get_tree().get_first_node_in_group("player")
	if candidate is Player:
		_player = candidate as Player
