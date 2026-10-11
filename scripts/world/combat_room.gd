class_name CombatRoom
extends Node

## Controlador mínimo de encontro. O grupo e os labels são configuráveis para
## que a sala possa ser reutilizada com outros inimigos e HUDs.

signal room_cleared

@export var enemy_group: StringName = &"combat_enemy"
@export var counter_label_path: NodePath = NodePath("")
@export var status_label_path: NodePath = NodePath("")
@export var health_label_path: NodePath = NodePath("")
@export var player_path: NodePath = NodePath("../Player")

var _counter_label: Label
var _status_label: Label
var _health_label: Label
var _player: Player
var _remaining_enemies: Dictionary = {}
var _room_was_cleared: bool = false
var _player_was_defeated: bool = false

var room_is_cleared: bool:
	get:
		return _room_was_cleared

func _unhandled_input(event: InputEvent) -> void:
	if not _player_was_defeated or not event is InputEventKey:
		return
	var key_event := event as InputEventKey
	if key_event.pressed and not key_event.echo and key_event.keycode == KEY_R:
		get_tree().reload_current_scene()

func _ready() -> void:
	add_to_group("combat_room")
	_counter_label = get_node_or_null(counter_label_path) as Label
	_status_label = get_node_or_null(status_label_path) as Label
	_health_label = get_node_or_null(health_label_path) as Label
	_player = get_node_or_null(player_path) as Player
	if _player != null:
		_player.health_changed.connect(_on_player_health_changed)
		_player.died.connect(_on_player_died)
		_on_player_health_changed(_player.current_health, _player.maximum_health)
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
	if _player_was_defeated or _room_was_cleared or not _remaining_enemies.has(enemy):
		return

	_remaining_enemies.erase(enemy)
	_update_hud()
	if _remaining_enemies.is_empty():
		_clear_room()

func _clear_room() -> void:
	if _player_was_defeated or _room_was_cleared:
		return

	_room_was_cleared = true
	_request_hostile_projectile_stops()
	room_cleared.emit()

func _on_player_health_changed(current: int, maximum: int) -> void:
	if _health_label != null:
		_health_label.text = "VIDA: %d / %d" % [current, maximum]

func _on_player_died() -> void:
	if _player_was_defeated:
		return
	_player_was_defeated = true
	_request_hostile_projectile_stops()

## Callback-safe request only; projectiles are removed by Main after the flush.
func _request_hostile_projectile_stops() -> void:
	for projectile in get_tree().get_nodes_in_group("hostile_projectile"):
		if is_instance_valid(projectile) and projectile.has_method("request_stop_sweep"):
			projectile.call("request_stop_sweep")

## Post-flush cleanup. This includes parried rivets, which remain in the group.
func cleanup_hostile_projectiles_after_flush() -> void:
	for projectile in get_tree().get_nodes_in_group("hostile_projectile"):
		if is_instance_valid(projectile) and projectile.has_method("cancel"):
			projectile.call("cancel")

func refresh_status_after_physics() -> void:
	_update_hud()

func _update_hud() -> void:
	var remaining := _remaining_enemies.size()
	if _counter_label != null:
		_counter_label.text = "INIMIGOS RESTANTES: %d" % remaining
	if _status_label == null:
		return
	if _player_was_defeated:
		_status_label.text = "DERROTA — PRESSIONE R PARA REINICIAR"
	elif _room_was_cleared:
		_status_label.text = "ÁREA LIMPA — SALA CONCLUÍDA"
	else:
		_status_label.text = "ENCONTRO ATIVO"
