extends Area2D

## Porta reutilizável: controla alcance, apresentação e pedido de interação.
## A cena de sala que contém a porta decide se e para onde a transição ocorre.

signal transition_requested(player: Player)

@onready var _door_panel: Polygon2D = $DoorPanel
@onready var _portal_glow: Polygon2D = $PortalGlow
@onready var _door_rim: Line2D = $DoorRim
@onready var _door_seal: Line2D = $DoorSeal
@onready var _door_label: Label = $DoorLabel

var _players_in_range: Dictionary = {}
var _room_is_cleared: bool = false
var _transition_busy: bool = false
var _failure_message: String = ""
var _room_root: Node

func _ready() -> void:
	_room_root = get_parent()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_update_presentation()

func set_room_cleared(cleared: bool) -> void:
	_room_is_cleared = cleared
	if not cleared:
		_transition_busy = false
		_failure_message = ""
	_update_presentation()

func set_transition_busy(busy: bool) -> void:
	if busy and not _room_is_cleared:
		return
	_transition_busy = busy
	if busy:
		_failure_message = ""
	_update_presentation()

func report_transition_failure(message: String) -> void:
	_transition_busy = false
	_failure_message = message.strip_edges()
	_update_presentation()

func _unhandled_input(event: InputEvent) -> void:
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

func _update_presentation() -> void:
	if not is_instance_valid(_door_panel):
		return
	var is_open := _room_is_cleared and not _transition_busy
	_door_panel.color = Color("#18232b") if is_open else Color("#24252a")
	_portal_glow.color = Color("#63c9b1", 0.32) if is_open else Color("#d68448", 0.2)
	_door_rim.default_color = Color("#79d9c0") if is_open else Color("#d68448")
	_door_seal.visible = not _room_is_cleared or _transition_busy

	if _transition_busy:
		_door_label.text = "ABRINDO SAÍDA..."
	elif not _room_is_cleared:
		_door_label.text = "SAÍDA BLOQUEADA\nELIMINE OS INIMIGOS"
	elif not _failure_message.is_empty():
		_door_label.text = "%s\nE TENTAR DE NOVO" % _failure_message
	else:
		_door_label.text = "SAÍDA ABERTA\n[E] ENTRAR"
