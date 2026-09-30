class_name CombatRoom
extends Node

## Controlador mínimo de encontro. O grupo e os labels são configuráveis para
## que a sala possa ser reutilizada com outros inimigos e HUDs.

signal room_cleared

@export var enemy_group: StringName = &"combat_enemy"
@export var counter_label_path: NodePath = NodePath("")
@export var status_label_path: NodePath = NodePath("")

var _counter_label: Label
var _status_label: Label
var _remaining_enemies: Dictionary = {}
var _room_was_cleared: bool = false

func _ready() -> void:
	_counter_label = get_node_or_null(counter_label_path) as Label
	_status_label = get_node_or_null(status_label_path) as Label
	_register_enemies()
	_update_hud()
	if _remaining_enemies.is_empty():
		_clear_room()

func _register_enemies() -> void:
	for enemy in get_tree().get_nodes_in_group(enemy_group):
		if not is_instance_valid(enemy):
			continue
		if not enemy.has_signal("defeated"):
			push_warning(
				"CombatRoom: ignorando %s no grupo '%s'; o nó não possui o sinal 'defeated'."
				% [enemy.get_path(), enemy_group]
			)
			continue

		_remaining_enemies[enemy] = true
		enemy.connect("defeated", _on_enemy_defeated.bind(enemy), CONNECT_ONE_SHOT)

func _on_enemy_defeated(enemy: Node) -> void:
	if _room_was_cleared or not _remaining_enemies.has(enemy):
		return

	_remaining_enemies.erase(enemy)
	_update_hud()
	if _remaining_enemies.is_empty():
		_clear_room()

func _clear_room() -> void:
	if _room_was_cleared:
		return

	_room_was_cleared = true
	_update_hud()
	room_cleared.emit()

func _update_hud() -> void:
	var remaining := _remaining_enemies.size()
	if _counter_label != null:
		_counter_label.text = "INIMIGOS RESTANTES: %d" % remaining
	if _status_label == null:
		return
	if _room_was_cleared:
		_status_label.text = "ÁREA LIMPA — SALA CONCLUÍDA"
	else:
		_status_label.text = "ENCONTRO ATIVO"
