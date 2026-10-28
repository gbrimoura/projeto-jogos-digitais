extends Node2D

signal run_progression_ready

const RoomTransition = preload("res://scripts/world/room_transition.gd")
const RunBuild = preload("res://scripts/progression/run_build.gd")
const UpgradeOfferScene: PackedScene = preload("res://scenes/upgrade_offer.tscn")
const IMPACTO_REFORCADO_DEFINITION: UpgradeDefinitionResource = preload("res://resources/upgrades/impacto_reforcado.tres")
const MOTOR_ACELERADO_DEFINITION: UpgradeDefinitionResource = preload("res://resources/upgrades/motor_acelerado.tres")
const CARGA_REATIVA_DEFINITION: UpgradeDefinitionResource = preload("res://resources/upgrades/carga_reativa.tres")
const FALLBACK_PLAYER_SPAWN := Vector2(160.0, 560.0)
const DISCRETE_INPUT_ACTIONS: Array[StringName] = [
	&"launch_ball",
	&"parry",
	&"dash",
	&"jump",
	&"interact",
]

enum UpgradeFlowState {
	INACTIVE,
	VICTORY_PENDING,
	OFFER_OPEN,
	SELECTED,
	EXIT_RELEASED,
	CANCELLED,
	COMPLETED,
}

@export_file("*.tscn") var next_room_scene_path: String = "res://scenes/second_room.tscn"
@export var room_title: String = "SALA 01"
@export var reward_enabled: bool = true
@export_range(0.0, 2.0, 0.01) var post_upgrade_input_guard_seconds: float = 0.25
@export var room_title_label_path: NodePath = NodePath("CombatRoom/HUD/RoomLabel")
@export var build_status_label_path: NodePath = NodePath("CombatRoom/HUD/BuildLabel")
@export var player_spawn_marker_path: NodePath = NodePath("PlayerSpawnMarker")

@onready var player: Player = $Player
@onready var combat_room: CombatRoom = $CombatRoom
@onready var exit_door: Node = get_node_or_null("ExitDoor")

var _transition_in_progress: bool = false
var _upgrade_flow_state: UpgradeFlowState = UpgradeFlowState.INACTIVE
var _death_pending: bool = false
var _post_flush_resolution_queued: bool = false
var _upgrade_offer: UpgradeOffer
var _offered_upgrade_ids: Array[StringName] = []
var _owned_offer_pause: bool = false
var _guard_active: bool = false
var _guard_waiting_for_release: bool = false
var _guard_quiet_remaining: float = 0.0
var run_build: RunBuild = RunBuild.new()
var _run_controller_managed: bool = false
var _managed_run_build: RunBuild
var _run_progression_notified: bool = false

var _upgrade_definitions: Array[UpgradeDefinitionResource] = [
	IMPACTO_REFORCADO_DEFINITION,
	MOTOR_ACELERADO_DEFINITION,
	CARGA_REATIVA_DEFINITION,
]

func configure_run_managed(shared_build: RunBuild, offer_build_upgrade: bool) -> bool:
	if is_inside_tree() or shared_build == null:
		return false
	_run_controller_managed = true
	_managed_run_build = shared_build
	reward_enabled = offer_build_upgrade
	var managed_exit_door := get_node_or_null("ExitDoor")
	if managed_exit_door != null:
		remove_child(managed_exit_door)
		managed_exit_door.free()
	return true

func _ready() -> void:
	set_process_input(true)
	if not combat_room.room_cleared.is_connected(_on_room_cleared):
		combat_room.room_cleared.connect(_on_room_cleared)
	if player != null and not player.died.is_connected(_on_player_died):
		player.died.connect(_on_player_died)
	if exit_door != null:
		var transition_callback := Callable(self, "_on_exit_door_transition_requested")
		if not exit_door.is_connected("transition_requested", transition_callback):
			exit_door.connect("transition_requested", transition_callback)

	var title_label := get_node_or_null(room_title_label_path) as Label
	if title_label != null:
		title_label.text = room_title

	if player != null:
		player.reset_to_spawn(_get_player_spawn_position())

	# Os filhos já executaram _ready. O controlador mantém o estado da run
	# entre encontros; cenas standalone continuam consumindo o snapshot one-shot.
	var incoming_snapshot: Dictionary = {}
	if not _run_controller_managed:
		incoming_snapshot = RoomTransition.consume_pending_snapshot(_load_current_packed_scene())
	if _run_controller_managed and _managed_run_build != null:
		run_build = _managed_run_build
	else:
		run_build = RunBuild.new()
	if player != null:
		if not incoming_snapshot.is_empty() and player.health != null:
			var restored_build := RunBuild.new()
			if restored_build.replace_state(
				incoming_snapshot.get("upgrade_ids"),
				incoming_snapshot.get("counts_by_id")
			):
				var health_restored := player.health.restore_health_for_room_transition(
					int(incoming_snapshot["hp_current"]),
					int(incoming_snapshot["hp_max"])
				)
				if health_restored:
					run_build = restored_build
		player.apply_run_build(run_build)

	_upgrade_offer = UpgradeOfferScene.instantiate() as UpgradeOffer
	if _upgrade_offer != null:
		add_child(_upgrade_offer)
		_upgrade_offer.upgrade_selected.connect(_on_upgrade_selected)
		_upgrade_offer.hide()

	_update_build_status()
	if exit_door != null:
		exit_door.call("set_room_cleared", false)
	if combat_room.room_is_cleared:
		_on_room_cleared()

func _exit_tree() -> void:
	if _upgrade_offer != null and is_instance_valid(_upgrade_offer):
		_upgrade_offer.close_offer()
	_guard_active = false
	_guard_waiting_for_release = false
	_guard_quiet_remaining = 0.0
	# Do not unpause during teardown; the new room inherits the actual tree state.
	_owned_offer_pause = false

func _input(event: InputEvent) -> void:
	if _upgrade_flow_state == UpgradeFlowState.OFFER_OPEN and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		return
	if not _guard_active:
		return
	for action in DISCRETE_INPUT_ACTIONS:
		if event.is_action_pressed(action):
			_guard_waiting_for_release = true
			_guard_quiet_remaining = 0.0
			get_viewport().set_input_as_handled()
			return

func _process(delta: float) -> void:
	if not _guard_active:
		return
	if _any_discrete_input_pressed():
		_guard_waiting_for_release = true
		_guard_quiet_remaining = 0.0
		return
	if _guard_waiting_for_release:
		_guard_waiting_for_release = false
		_guard_quiet_remaining = maxf(post_upgrade_input_guard_seconds, 0.0)
		if _guard_quiet_remaining <= 0.0:
			_end_input_guard()
		return

	_guard_quiet_remaining = maxf(_guard_quiet_remaining - delta, 0.0)
	if _guard_quiet_remaining <= 0.0:
		_end_input_guard()

func _physics_process(_delta: float) -> void:
	if player == null or not is_instance_valid(player) or player.is_dead:
		return
	if player.global_position.y > 760.0:
		player.reset_to_spawn(_get_player_spawn_position())

func is_gameplay_action_blocked(action: StringName) -> bool:
	if not DISCRETE_INPUT_ACTIONS.has(action):
		return false
	if _upgrade_flow_state in [
		UpgradeFlowState.VICTORY_PENDING,
		UpgradeFlowState.OFFER_OPEN,
		UpgradeFlowState.SELECTED,
	]:
		return true
	return _guard_active

func _on_room_cleared() -> void:
	if _upgrade_flow_state != UpgradeFlowState.INACTIVE:
		return
	_upgrade_flow_state = UpgradeFlowState.VICTORY_PENDING
	if player != null and is_instance_valid(player):
		player.ball_launcher.request_stop_active_sweep()
	_queue_post_flush_resolution()

func _on_player_died() -> void:
	_death_pending = true
	_upgrade_flow_state = UpgradeFlowState.CANCELLED
	if player != null and is_instance_valid(player):
		player.ball_launcher.request_stop_active_sweep()
	_queue_post_flush_resolution()

func _queue_post_flush_resolution() -> void:
	if _post_flush_resolution_queued:
		return
	_post_flush_resolution_queued = true
	call_deferred("_resolve_after_physics_flush")

func _resolve_after_physics_flush() -> void:
	_post_flush_resolution_queued = false
	if player != null and is_instance_valid(player):
		player.ball_launcher.cleanup_active_ball_after_flush()
	combat_room.cleanup_hostile_projectiles_after_flush()
	combat_room.refresh_status_after_physics()

	if _death_pending or player == null or not is_instance_valid(player) or player.is_dead:
		_death_pending = true
		_upgrade_flow_state = UpgradeFlowState.CANCELLED
		_transition_in_progress = false
		run_build.clear()
		RoomTransition.clear_pending_snapshot()
		_offered_upgrade_ids.clear()
		if _upgrade_offer != null and is_instance_valid(_upgrade_offer):
			_upgrade_offer.close_offer()
		if exit_door != null:
			exit_door.call("set_room_cleared", false)
		_close_owned_offer_pause()
		_end_input_guard()
		_update_build_status()
		if player != null and is_instance_valid(player):
			player.finish_death_after_physics()
		return

	if _upgrade_flow_state != UpgradeFlowState.VICTORY_PENDING or not combat_room.room_is_cleared:
		return
	if reward_enabled and run_build.total_count() == 0:
		_open_upgrade_offer()
	else:
		_release_exit_or_complete()

func _open_upgrade_offer() -> void:
	if _upgrade_offer == null or not is_instance_valid(_upgrade_offer):
		_upgrade_flow_state = UpgradeFlowState.CANCELLED
		push_error("Main: não foi possível criar a oferta de upgrades.")
		if _run_controller_managed:
			_release_exit_or_complete()
		return
	_offered_upgrade_ids.clear()
	for definition in _upgrade_definitions:
		_offered_upgrade_ids.append(definition.upgrade_id)
	if not _upgrade_offer.present_options(_upgrade_definitions):
		_offered_upgrade_ids.clear()
		_upgrade_flow_state = UpgradeFlowState.CANCELLED
		push_error("Main: definições inválidas para a oferta.")
		if _run_controller_managed:
			_release_exit_or_complete()
		return

	_owned_offer_pause = not get_tree().paused
	_upgrade_flow_state = UpgradeFlowState.OFFER_OPEN
	if _owned_offer_pause:
		get_tree().paused = true

func _on_upgrade_selected(upgrade_id: StringName) -> void:
	if _upgrade_flow_state != UpgradeFlowState.OFFER_OPEN:
		return
	if player == null or not is_instance_valid(player) or player.is_dead:
		return
	if not _offered_upgrade_ids.has(upgrade_id):
		return
	if not RunBuild.is_known_upgrade_id(upgrade_id):
		return
	if run_build.count_for(upgrade_id) != 0 or run_build.total_count() >= RunBuild.MAX_UPGRADES:
		return

	# State changes before the build and player configurations are mutated.
	_upgrade_flow_state = UpgradeFlowState.SELECTED
	if not run_build.add_upgrade(upgrade_id):
		_upgrade_flow_state = UpgradeFlowState.OFFER_OPEN
		return
	player.apply_run_build(run_build)
	_update_build_status()
	_offered_upgrade_ids.clear()
	if _upgrade_offer != null and is_instance_valid(_upgrade_offer):
		_upgrade_offer.close_offer()
	_begin_input_guard()
	_close_owned_offer_pause()
	_release_exit_or_complete()

func _release_exit_or_complete() -> void:
	if exit_door == null:
		_upgrade_flow_state = UpgradeFlowState.COMPLETED
		_notify_run_progression_ready()
		return
	_upgrade_flow_state = UpgradeFlowState.EXIT_RELEASED
	exit_door.call("set_room_cleared", true)

func _notify_run_progression_ready() -> void:
	if not _run_controller_managed or _run_progression_notified:
		return
	_run_progression_notified = true
	run_progression_ready.emit()

func _begin_input_guard() -> void:
	_guard_active = true
	_guard_waiting_for_release = _any_discrete_input_pressed()
	_guard_quiet_remaining = 0.0 if _guard_waiting_for_release else maxf(post_upgrade_input_guard_seconds, 0.0)
	if not _guard_waiting_for_release and _guard_quiet_remaining <= 0.0:
		_end_input_guard()

func _end_input_guard() -> void:
	_guard_active = false
	_guard_waiting_for_release = false
	_guard_quiet_remaining = 0.0

func _any_discrete_input_pressed() -> bool:
	for action in DISCRETE_INPUT_ACTIONS:
		if Input.is_action_pressed(action):
			return true
	return false

func _close_owned_offer_pause() -> void:
	if _owned_offer_pause and get_tree().paused:
		get_tree().paused = false
	_owned_offer_pause = false

func _on_exit_door_transition_requested(requested_player: Player) -> void:
	if _transition_in_progress or _upgrade_flow_state != UpgradeFlowState.EXIT_RELEASED:
		return
	if requested_player == null or not is_instance_valid(requested_player) or requested_player != player or requested_player.is_dead:
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
	if not _transition_in_progress or _upgrade_flow_state != UpgradeFlowState.EXIT_RELEASED:
		return
	if not combat_room.room_is_cleared:
		_cancel_transition_request(destination_path, "")
		return
	if requested_player == null or not is_instance_valid(requested_player) or requested_player != player or requested_player.is_dead:
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

	if not RoomTransition.prepare_run_snapshot(
		destination_scene,
		requested_player.current_health,
		requested_player.maximum_health,
		run_build
	):
		_cancel_transition_request(canonical_destination_path, "FALHA AO PREPARAR TRANSIÇÃO")
		return
	var change_result := get_tree().change_scene_to_packed(destination_scene)
	if change_result != OK:
		_cancel_transition_request(canonical_destination_path, "FALHA AO CARREGAR SALA")

func _cancel_transition_request(_destination_path: String, message: String) -> void:
	RoomTransition.clear_pending_snapshot()
	_transition_in_progress = false
	if exit_door == null:
		return
	if not message.is_empty():
		exit_door.call("report_transition_failure", message)
	elif _upgrade_flow_state == UpgradeFlowState.EXIT_RELEASED:
		exit_door.call("set_transition_busy", false)
	else:
		exit_door.call("set_room_cleared", false)

func _update_build_status() -> void:
	var label := get_node_or_null(build_status_label_path) as Label
	if label == null:
		return
	if run_build == null or run_build.total_count() == 0:
		label.text = "BUILD: VAZIA"
		return

	var upgrade_id := run_build.get_upgrade_ids()[0]
	var display_name := ""
	for definition in _upgrade_definitions:
		if definition.upgrade_id == upgrade_id:
			display_name = definition.title
			break
	label.text = "BUILD: %s" % display_name.to_upper()

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

func _load_current_packed_scene() -> PackedScene:
	var current_path := _current_scene_path()
	if current_path.is_empty():
		return null
	return ResourceLoader.load(current_path, "PackedScene") as PackedScene
