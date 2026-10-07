extends Node2D

const RoomTransition = preload("res://scripts/world/room_transition.gd")
const FALLBACK_PLAYER_SPAWN := Vector2(160.0, 560.0)

@export_file("*.tscn") var next_room_scene_path: String = "res://scenes/second_room.tscn"
@export var room_title: String = "SALA 01"
@export var room_title_label_path: NodePath = NodePath("CombatRoom/HUD/RoomLabel")
@export var player_spawn_marker_path: NodePath = NodePath("PlayerSpawnMarker")

@onready var player: Player = $Player
@onready var combat_room: CombatRoom = $CombatRoom
@onready var exit_door: Node = get_node_or_null("ExitDoor")

var _transition_in_progress: bool = false

func _ready() -> void:
	if not combat_room.room_cleared.is_connected(_on_room_cleared):
		combat_room.room_cleared.connect(_on_room_cleared)
	if exit_door != null:
		var transition_callback := Callable(self, "_on_exit_door_transition_requested")
		if not exit_door.is_connected("transition_requested", transition_callback):
			exit_door.connect("transition_requested", transition_callback)
		exit_door.call("set_room_cleared", combat_room.room_is_cleared)
	if combat_room.room_is_cleared:
		_on_room_cleared()

	var title_label := get_node_or_null(room_title_label_path) as Label
	if title_label != null:
		title_label.text = room_title

	if player != null:
		player.reset_to_spawn(_get_player_spawn_position())
		if player.health != null:
			RoomTransition.apply_pending_health_transfer(_current_scene_path(), player.health)

func _physics_process(_delta: float) -> void:
	if player.global_position.y > 760.0:
		player.reset_to_spawn(_get_player_spawn_position())

func _on_room_cleared() -> void:
	if exit_door != null:
		exit_door.call("set_room_cleared", true)
	for projectile in get_tree().get_nodes_in_group("hostile_projectile"):
		if is_instance_valid(projectile) and projectile.has_method("cancel"):
			projectile.call("cancel")

func _on_exit_door_transition_requested(requested_player: Player) -> void:
	if _transition_in_progress:
		return
	if not combat_room.room_is_cleared:
		if exit_door != null:
			exit_door.call("set_room_cleared", false)
		return
	if requested_player == null or not is_instance_valid(requested_player) or requested_player.is_dead:
		if exit_door != null:
			exit_door.call("report_transition_failure", "JOGADOR INDISPONÍVEL")
		return

	var destination_path := next_room_scene_path.strip_edges()
	if destination_path.is_empty():
		if exit_door != null:
			exit_door.call("report_transition_failure", "DESTINO INDISPONÍVEL")
		return

	_transition_in_progress = true
	if exit_door != null:
		exit_door.call("set_transition_busy", true)
	call_deferred("_change_room_deferred", destination_path, requested_player)

func _change_room_deferred(destination_path: String, requested_player: Player) -> void:
	if not _transition_in_progress:
		return
	if not combat_room.room_is_cleared:
		_cancel_transition_request(destination_path, "")
		return
	if requested_player == null or not is_instance_valid(requested_player) or requested_player.is_dead:
		_cancel_transition_request(destination_path, "")
		return
	if exit_door == null or not bool(exit_door.call("is_player_in_range", requested_player)):
		_cancel_transition_request(destination_path, "")
		return

	var destination_scene := ResourceLoader.load(destination_path, "PackedScene") as PackedScene
	if destination_scene == null:
		_cancel_transition_request(destination_path, "FALHA AO CARREGAR SALA")
		return
	var canonical_destination_path := destination_scene.resource_path
	if canonical_destination_path.is_empty() or not canonical_destination_path.begins_with("res://"):
		_cancel_transition_request(destination_path, "FALHA AO CARREGAR SALA")
		return

	RoomTransition.prepare_health_transfer(
		canonical_destination_path,
		requested_player.current_health,
		requested_player.maximum_health
	)
	var change_result := get_tree().change_scene_to_file(canonical_destination_path)
	if change_result != OK:
		_cancel_transition_request(canonical_destination_path, "FALHA AO CARREGAR SALA")

func _cancel_transition_request(destination_path: String, message: String) -> void:
	RoomTransition.clear_pending_health_transfer(destination_path)
	_transition_in_progress = false
	if exit_door == null:
		return
	if not message.is_empty():
		exit_door.call("report_transition_failure", message)
	elif combat_room.room_is_cleared:
		exit_door.call("set_transition_busy", false)
	else:
		exit_door.call("set_room_cleared", false)

func _get_player_spawn_position() -> Vector2:
	var spawn_marker := get_node_or_null(player_spawn_marker_path) as Marker2D
	if spawn_marker != null:
		return spawn_marker.global_position
	return FALLBACK_PLAYER_SPAWN

func _current_scene_path() -> String:
	if not scene_file_path.is_empty():
		return scene_file_path
	var current_scene := get_tree().current_scene
	if current_scene != null:
		return current_scene.scene_file_path
	return ""
