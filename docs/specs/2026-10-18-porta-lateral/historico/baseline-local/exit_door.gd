extends Area2D

## Porta reutilizável: controla alcance, apresentação e pedido de interação.
## A cena de sala que contém a porta decide se e para onde a transição ocorre.

signal transition_requested(player: Player)

@export_enum("Exit", "Entrance") var door_role: int = 0
@export var interaction_enabled: bool = true

@onready var _door_art: Sprite2D = $DoorArt
@onready var _door_label: Label = $DoorLabel

var _players_in_range: Dictionary = {}
var _room_is_cleared: bool = false
var _transition_busy: bool = false
var _terminal_complete: bool = false
var _failure_message: String = ""
var _room_root: Node

func _ready() -> void:
	_room_root = get_parent()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_update_presentation()

func set_room_cleared(cleared: bool) -> void:
	if door_role != 0 or _terminal_complete:
		return
	_room_is_cleared = cleared
	if not cleared:
		_transition_busy = false
		_failure_message = ""
	_update_presentation()

func set_transition_busy(busy: bool) -> void:
	if door_role != 0 or _terminal_complete:
		return
	if busy and not _room_is_cleared:
		return
	_transition_busy = busy
	if busy:
		_failure_message = ""
	_update_presentation()

func report_transition_failure(message: String) -> void:
	if door_role != 0 or _terminal_complete:
		return
	_transition_busy = false
	_failure_message = message.strip_edges()
	_update_presentation()

func _unhandled_input(event: InputEvent) -> void:
	if door_role != 0 or not interaction_enabled or _terminal_complete:
		return
	if not event is InputEventKey:
		return
	var key_event := event as InputEventKey
	if key_event.echo or not key_event.is_action_pressed("interact"):
		return
	if _room_root != null \
		and _room_root.has_method("is_gameplay_action_blocked") \
		and bool(_room_root.call("is_gameplay_action_blocked", &"interact")):
		get_viewport().set_input_as_handled()
		return
	if _transition_busy or not _room_is_cleared:
		return
	if not Input.is_action_just_pressed("interact"):
		return

	var player := _get_live_player_in_range()
	if player == null:
		return

	_transition_busy = true
	_update_presentation()
	transition_requested.emit(player)
	get_viewport().set_input_as_handled()

func _on_body_entered(body: Node2D) -> void:
	if body is Player and body.is_in_group("player"):
		_players_in_range[body] = true

func _on_body_exited(body: Node2D) -> void:
	_players_in_range.erase(body)

func is_player_in_range(player: Player) -> bool:
	if door_role != 0 or not interaction_enabled or _terminal_complete:
		return false
	if player == null or not is_instance_valid(player) or not _players_in_range.has(player):
		return false
	return get_overlapping_bodies().has(player)

func _get_live_player_in_range() -> Player:
	for candidate in _players_in_range.keys():
		if not is_instance_valid(candidate):
			continue
		var player := candidate as Player
		if player != null and player.is_in_group("player") and not player.is_dead and is_player_in_range(player):
			return player
	return null

func set_terminal_complete() -> void:
	_terminal_complete = true
	_room_is_cleared = false
	_transition_busy = false
	_failure_message = ""
	_update_presentation()

func _update_presentation() -> void:
	if not is_instance_valid(_door_art) or not is_instance_valid(_door_label):
		return
	if door_role != 0:
		_door_art.frame = 0
		_door_label.text = "ENTRADA\nACESSO BLOQUEADO"
		return
	if _terminal_complete:
		_door_art.frame = 1
		_door_label.text = "ETAPA CONCLUÍDA"
		return

	var is_open := _room_is_cleared and not _transition_busy
	_door_art.frame = 1 if is_open else 0
	if _transition_busy:
		_door_label.text = "ABRINDO SAÍDA..."
	elif not _room_is_cleared:
		_door_label.text = "SAÍDA BLOQUEADA\nELIMINE OS INIMIGOS"
	elif not _failure_message.is_empty():
		_door_label.text = "%s\nE TENTAR DE NOVO" % _failure_message
	else:
		_door_label.text = "SAÍDA ABERTA\n[E] ENTRAR"
