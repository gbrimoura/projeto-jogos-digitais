extends Node2D

const RunBuild = preload("res://scripts/progression/run_build.gd")
const RoomTransition = preload("res://scripts/world/room_transition.gd")
const RewardScreenScript = preload("res://scripts/ui/reward_screen.gd")
const RoomRunLayout = preload("res://scripts/world/room_run_layout.gd")

@export_range(1, 20) var floors_per_run: int = 8
@export_range(1, 10) var common_rooms_per_floor: int = 3
@export_range(0.0, 10.0, 0.1) var transition_delay: float = 0.0
@export var common_room_scene: PackedScene
@export var boss_room_scene: PackedScene
@export var run_seed: int = 0
@export var randomize_run_seed: bool = true

@onready var room_container: Node2D = $RoomContainer
@onready var progress_label: Label = $HUD/ProgressLabel
@onready var status_label: Label = $HUD/StatusLabel

var current_floor: int = 1
var current_room: int = 1
var current_room_instance: Node
var transition_pending: bool = false
var _run_ended: bool = false
var _damage_multiplier: float = 1.0
var _speed_multiplier: float = 1.0
var _radius_multiplier: float = 1.0
var _run_player_health: int = -1
var _run_player_max_health: int = -1
var _run_build: RunBuild = RunBuild.new()
var _active_reward_screen: Node
var _owned_reward_pause: bool = false
var _owned_transition_pause: bool = false
var _restart_in_progress: bool = false
var _transition_fade_layer: CanvasLayer
var _transition_fade_rect: ColorRect
var _resolved_run_seed: int = 0
var _floor_room_descriptors: Array[Dictionary] = []
var _last_room_family: StringName = &""
var _room_signal_connections: Dictionary = {}
var _pending_stage_proposal: Dictionary = {}
var _pending_stage_source: Node
var _technical_error_layer: CanvasLayer
var _technical_error_source: Node
var _technical_retry_kind: StringName = &""
var _technical_retry_proposal: Dictionary = {}
var _technical_error_pause_owned: bool = false
var _boss_reward_room_id: int = 0
var _boss_reward_name: String = ""
var _boss_reward_applied: bool = false
var _initial_floor_plan_error: String = ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	RoomTransition.clear_pending_snapshot()
	_resolved_run_seed = RoomRunLayout.resolve_seed(run_seed, randomize_run_seed)
	if common_room_scene == null:
		_present_technical_error("ERRO: cena de sala comum não definida.", {}, null, &"initial_load", true)
		return
	if boss_room_scene == null:
		_present_technical_error("ERRO: cena de chefe não definida.", {}, null, &"initial_load", true)
		return
	if not _prepare_current_floor_plan():
		_present_technical_error(_initial_floor_plan_error, {}, null, &"floor_plan", true)
		return
	_load_current_encounter()

func get_resolved_run_seed() -> int:
	return _resolved_run_seed

func _prepare_current_floor_plan() -> bool:
	var result: Dictionary = RoomRunLayout.build_floor(
		_resolved_run_seed,
		current_floor,
		common_rooms_per_floor + 1,
		_last_room_family
	)
	if not bool(result.get("valid", false)):
		_initial_floor_plan_error = "ERRO: não foi possível planejar a sequência de salas: %s" % String(result.get("error", "topologia inválida"))
		return false
	_floor_room_descriptors.clear()
	for descriptor: Dictionary in result.get("rooms", []):
		_floor_room_descriptors.append(descriptor.duplicate(true))
	_last_room_family = StringName(result.get("last_family", _last_room_family))
	_initial_floor_plan_error = ""
	return true

func _stage_proposal(floor_index: int, room_index: int, descriptors: Array[Dictionary], last_family: StringName) -> Dictionary:
	var descriptor_index := room_index - 1
	if descriptor_index < 0 or descriptor_index >= descriptors.size():
		return {
			"valid": false,
			"error": "ERRO: descritor da sala %d do andar %d ausente." % [room_index, floor_index],
			"floor": floor_index,
			"room": room_index,
			"descriptors": descriptors.duplicate(true),
			"last_family": last_family,
		}
	var destination_descriptor: Dictionary = descriptors[descriptor_index].duplicate(true)
	return {
		"valid": true,
		"floor": floor_index,
		"room": room_index,
		"descriptors": descriptors.duplicate(true),
		"last_family": last_family,
		"descriptor": destination_descriptor,
	}

func _current_stage_proposal() -> Dictionary:
	return _stage_proposal(current_floor, current_room, _floor_room_descriptors, _last_room_family)

func _next_stage_proposal() -> Dictionary:
	var proposed_floor: int = current_floor
	var proposed_room: int = current_room
	var proposed_descriptors: Array[Dictionary] = _floor_room_descriptors.duplicate(true)
	var proposed_last_family: StringName = _last_room_family
	if _is_boss_room():
		proposed_floor += 1
		proposed_room = 1
		var result: Dictionary = RoomRunLayout.build_floor(
			_resolved_run_seed,
			proposed_floor,
			common_rooms_per_floor + 1,
			proposed_last_family
		)
		if not bool(result.get("valid", false)):
			return {
				"valid": false,
				"error": "ERRO: não foi possível planejar o andar %d: %s" % [proposed_floor, String(result.get("error", "topologia inválida"))],
				"floor": proposed_floor,
				"room": proposed_room,
				"descriptors": [],
				"last_family": proposed_last_family,
			}
		proposed_descriptors.clear()
		for descriptor: Dictionary in result.get("rooms", []):
			proposed_descriptors.append(descriptor.duplicate(true))
		proposed_last_family = StringName(result.get("last_family", proposed_last_family))
	else:
		proposed_room += 1
	return _stage_proposal(proposed_floor, proposed_room, proposed_descriptors, proposed_last_family)

func _commit_stage_proposal(proposal: Dictionary) -> void:
	current_floor = int(proposal.get("floor", current_floor))
	current_room = int(proposal.get("room", current_room))
	_floor_room_descriptors.clear()
	for descriptor: Dictionary in proposal.get("descriptors", []):
		_floor_room_descriptors.append(descriptor.duplicate(true))
	_last_room_family = StringName(proposal.get("last_family", _last_room_family))

func _is_boss_room() -> bool:
	return current_room > common_rooms_per_floor


func _is_final_boss() -> bool:
	return current_floor == floors_per_run and _is_boss_room()

func is_active_room_instance(room: Node) -> bool:
	return not _run_ended and is_instance_valid(current_room_instance) and room == current_room_instance


func _load_current_encounter(retry_proposal: Dictionary = {}) -> bool:
	if _run_ended:
		return false
	var proposal: Dictionary = retry_proposal.duplicate(true) if bool(retry_proposal.get("valid", false)) else _current_stage_proposal()
	if not bool(proposal.get("valid", false)):
		_present_technical_error(String(proposal.get("error", "descritor atual inválido")), proposal, null, &"initial_load", true)
		return false
	var candidate_result: Dictionary = _prepare_room_candidate(proposal)
	if not bool(candidate_result.get("valid", false)):
		_present_technical_error(String(candidate_result.get("error", "falha técnica ao preparar a sala")), proposal, null, &"initial_load", true)
		return false
	var candidate: Node = candidate_result.get("room") as Node
	room_container.add_child(candidate)
	var attached_result: Dictionary = _validate_attached_candidate(candidate)
	if not bool(attached_result.get("valid", false)):
		room_container.remove_child(candidate)
		candidate.queue_free()
		_present_technical_error(String(attached_result.get("error", "falha técnica ao validar jogador/HP")), proposal, null, &"initial_load", true)
		return false
	var candidate_player: Player = attached_result.get("player") as Player
	_commit_room_candidate(candidate, candidate_player, proposal, null)
	_dismiss_technical_error()
	_release_technical_error_pause()
	return true

func _prepare_room_candidate(proposal: Dictionary) -> Dictionary:
	if not bool(proposal.get("valid", false)):
		return {"valid": false, "error": String(proposal.get("error", "proposta de sala inválida"))}
	var target_room: int = int(proposal.get("room", 0))
	var packed_scene: PackedScene = boss_room_scene if target_room > common_rooms_per_floor else common_room_scene
	if packed_scene == null:
		return {"valid": false, "error": "ERRO: cena de sala destino não definida."}
	var next_room: Node = packed_scene.instantiate()
	if next_room == null:
		return {"valid": false, "error": "ERRO: não foi possível instanciar a cena destino."}
	next_room.process_mode = Node.PROCESS_MODE_DISABLED
	if not next_room.has_method("configure_run_managed"):
		next_room.free()
		return {"valid": false, "error": "ERRO: a cena de sala não oferece integração gerenciada."}
	if not next_room.has_signal("run_progression_ready"):
		next_room.free()
		return {"valid": false, "error": "ERRO: a sala não oferece o sinal run_progression_ready."}
	var descriptor: Dictionary = proposal.get("descriptor", {})
	var requested_seed: int = int(descriptor.get("room_seed", 0))
	if not bool(next_room.call("configure_run_managed", _run_build, _run_build.total_count() == 0, requested_seed, descriptor)):
		var layout_error := ""
		if next_room.has_method("get_authored_layout_error"):
			layout_error = String(next_room.call("get_authored_layout_error"))
		next_room.free()
		var failure := "ERRO: não foi possível configurar a sala para esta run."
		if not layout_error.is_empty():
			failure += " Layout: " + layout_error
		return {"valid": false, "error": failure}
	return {"valid": true, "room": next_room}

func _validate_attached_candidate(candidate: Node) -> Dictionary:
	if candidate.has_method("is_authored_layout_valid") \
		and not bool(candidate.call("is_authored_layout_valid")):
		var layout_error := ""
		if candidate.has_method("get_authored_layout_error"):
			layout_error = String(candidate.call("get_authored_layout_error"))
		return {"valid": false, "error": "ERRO: a sala candidata falhou na validação ao entrar na árvore. " + layout_error}
	var candidate_player: Player = _find_player(candidate)
	if candidate_player == null or candidate_player.health == null:
		return {"valid": false, "error": "ERRO: a sala candidata não contém um jogador com PlayerHealth."}
	if _run_player_health < 0:
		return {"valid": true, "player": candidate_player}
	if _run_player_health <= 0 or _run_player_max_health <= 0:
		return {"valid": false, "error": "ERRO: snapshot de HP inválido; a sala candidata foi descartada."}
	if not candidate_player.health.restore_health_for_room_transition(_run_player_health, _run_player_max_health):
		return {"valid": false, "error": "ERRO: não foi possível restaurar o HP na sala candidata."}
	return {"valid": true, "player": candidate_player}

func _commit_room_candidate(candidate: Node, candidate_player: Player, proposal: Dictionary, source: Node) -> void:
	if source != null:
		_disconnect_room_player_signals(source)
	_commit_stage_proposal(proposal)
	current_room_instance = candidate
	candidate.process_mode = Node.PROCESS_MODE_PAUSABLE
	_connect_room_player_signals(candidate, candidate_player)
	_connect_room_progression_signal(candidate)
	_apply_run_upgrades(candidate)
	if source != null and _boss_reward_room_id == source.get_instance_id():
		_boss_reward_room_id = 0
		_boss_reward_name = ""
		_boss_reward_applied = false
	_update_hud("ENCONTRO ATIVO")

func _connect_room_player_signals(room: Node, room_player: Player) -> void:
	if room == null or not is_instance_valid(room) or room_player == null or not is_instance_valid(room_player):
		return
	var room_id: int = room.get_instance_id()
	var health_callback := Callable(self, "_on_room_health_changed").bind(room)
	var died_callback := Callable(self, "_on_room_player_died").bind(room)
	if not room_player.health_changed.is_connected(health_callback):
		room_player.health_changed.connect(health_callback)
	if not room_player.died.is_connected(died_callback):
		room_player.died.connect(died_callback)
	_room_signal_connections[room_id] = {"player": room_player, "health": health_callback, "died": died_callback}
	_on_room_health_changed(room_player.current_health, room_player.maximum_health, room)

func _disconnect_room_player_signals(room: Node) -> void:
	if room == null or not is_instance_valid(room):
		return
	var room_id: int = room.get_instance_id()
	var connection_data: Dictionary = _room_signal_connections.get(room_id, {})
	var room_player: Player = connection_data.get("player") as Player
	var health_callback: Callable = connection_data.get("health", Callable())
	var died_callback: Callable = connection_data.get("died", Callable())
	if room_player != null and is_instance_valid(room_player):
		if health_callback.is_valid() and room_player.health_changed.is_connected(health_callback):
			room_player.health_changed.disconnect(health_callback)
		if died_callback.is_valid() and room_player.died.is_connected(died_callback):
			room_player.died.disconnect(died_callback)
	_room_signal_connections.erase(room_id)

func _connect_room_progression_signal(room: Node) -> void:
	if room == null or not is_instance_valid(room) or not room.has_signal("run_progression_ready"):
		return
	var progression_callback := Callable(self, "_on_room_progression_ready").bind(room)
	if not room.is_connected("run_progression_ready", progression_callback):
		room.connect("run_progression_ready", progression_callback, CONNECT_ONE_SHOT)

func _transition_source_matches(room: Node, transition_token: int, allow_detached: bool = false) -> bool:
	if _run_ended or _restart_in_progress or room == null or not is_instance_valid(room) \
		or room != current_room_instance or not room.has_method("get_managed_transition_token"):
		return false
	if not allow_detached and not room.is_inside_tree():
		return false
	return int(room.call("get_managed_transition_token")) == transition_token

func _present_recoverable_transition_error(source: Node, transition_token: int, message: String, proposal: Dictionary) -> void:
	if _run_ended or _restart_in_progress:
		_finish_managed_transition(false)
		return
	if source == null or not is_instance_valid(source) or source != current_room_instance:
		transition_pending = true
		_present_technical_error(message, proposal, null, &"", false)
		return
	if not source.is_inside_tree():
		room_container.add_child(source)
	if not source.has_method("recover_managed_transition_failure") \
		or not bool(source.call("recover_managed_transition_failure", transition_token, message)):
		transition_pending = true
		_present_technical_error(message + " A sala concluída não pôde ser reativada com segurança.", proposal, null, &"", false)
		return
	_pending_stage_proposal = proposal.duplicate(true) if bool(proposal.get("valid", false)) else {}
	_pending_stage_source = source
	_connect_room_progression_signal(source)
	transition_pending = true
	_update_hud("ERRO TÉCNICO NA PRÓXIMA SALA")
	_present_technical_error(message, proposal, source, &"", false)

func _present_restart_only_technical_error(message: String, proposal: Dictionary) -> void:
	if _run_ended or _restart_in_progress:
		return
	transition_pending = true
	_present_technical_error(message, proposal, null, &"", false)

func _on_room_progression_ready(transition_token: int, room: Node) -> void:
	if _run_ended or transition_pending or room != current_room_instance:
		return
	if not _transition_source_matches(room, transition_token):
		return
	transition_pending = true
	call_deferred("_advance_after_room", room, transition_token)

func _advance_after_room(completed_room: Node, transition_token: int) -> void:
	if not _transition_source_matches(completed_room, transition_token):
		_present_restart_only_technical_error("ERRO: a sala concluída não está mais disponível para avançar.", _next_stage_proposal())
		return

	if _is_boss_room() and not _boss_reward_is_applied_for(completed_room):
		var reward_screen: Variant = RewardScreenScript.new()
		if reward_screen == null:
			_present_recoverable_transition_error(completed_room, transition_token, "ERRO: não foi possível abrir a recompensa do chefe.", {})
			return
		_owned_reward_pause = not get_tree().paused
		if _owned_reward_pause:
			get_tree().paused = true
		add_child(reward_screen)
		_active_reward_screen = reward_screen
		var selected_reward: String = await reward_screen.reward_chosen
		_active_reward_screen = null
		if is_instance_valid(reward_screen):
			reward_screen.queue_free()
		_close_owned_reward_pause()
		if _run_ended:
			return
		if not _transition_source_matches(completed_room, transition_token):
			_present_restart_only_technical_error("ERRO: a sala concluída deixou de estar disponível após a recompensa.", _next_stage_proposal())
			return
		if selected_reward.is_empty():
			_present_recoverable_transition_error(completed_room, transition_token, "ERRO: a recompensa do chefe não foi concluída.", {})
			return
		_apply_reward(selected_reward)
		_boss_reward_room_id = completed_room.get_instance_id()
		_boss_reward_name = selected_reward
		_boss_reward_applied = true

	if _is_final_boss():
		_run_ended = true
		_show_victory_screen()
		return

	if transition_delay > 0.0:
		_update_hud("SALA CONCLUÍDA. PRÓXIMA ETAPA EM %.1f s." % transition_delay)
		var delay_timer: SceneTreeTimer = get_tree().create_timer(transition_delay)
		await delay_timer.timeout
	else:
		_update_hud("SALA CONCLUÍDA. PREPARANDO PRÓXIMA ETAPA.")
	if not _transition_source_matches(completed_room, transition_token):
		_present_restart_only_technical_error("ERRO: a sala concluída deixou de estar disponível após a preparação.", _next_stage_proposal())
		return
	_owned_transition_pause = not get_tree().paused
	if _owned_transition_pause:
		get_tree().paused = true
	await _fade_managed_transition_to(1.0, 0.18)
	if not _transition_source_matches(completed_room, transition_token):
		_finish_managed_transition(false)
		if not _run_ended and not _restart_in_progress:
			_present_technical_error("ERRO: a origem da transição deixou de estar disponível após o fade.", _next_stage_proposal(), null, &"", false)
		return

	var proposal: Dictionary
	if _pending_stage_source == completed_room and bool(_pending_stage_proposal.get("valid", false)):
		proposal = _pending_stage_proposal.duplicate(true)
	else:
		proposal = _next_stage_proposal()
	if not bool(proposal.get("valid", false)):
		_present_recoverable_transition_error(completed_room, transition_token, String(proposal.get("error", "falha ao preparar a próxima etapa")), proposal)
		return
	_pending_stage_proposal = proposal.duplicate(true)
	_pending_stage_source = completed_room

	var candidate_result: Dictionary = _prepare_room_candidate(proposal)
	if not bool(candidate_result.get("valid", false)):
		_present_recoverable_transition_error(completed_room, transition_token, String(candidate_result.get("error", "falha técnica ao preparar a próxima sala")), proposal)
		return
	var candidate: Node = candidate_result.get("room") as Node
	var source_player: Player = _find_player(completed_room)
	if source_player == null or source_player.health == null or source_player.is_dead:
		candidate.free()
		if source_player != null and source_player.is_dead:
			_on_room_player_died(completed_room)
			_finish_managed_transition(false)
			return
		_present_recoverable_transition_error(completed_room, transition_token, "ERRO: não foi possível confirmar o estado de HP da sala concluída.", proposal)
		return
	_run_player_health = source_player.health.current_health
	_run_player_max_health = source_player.health.maximum_health
	if _run_player_health <= 0 or _run_player_max_health <= 0:
		candidate.free()
		_present_recoverable_transition_error(completed_room, transition_token, "ERRO: snapshot de HP inválido na sala concluída.", proposal)
		return

	room_container.remove_child(completed_room)
	await get_tree().process_frame
	var source_is_detached: bool = is_instance_valid(completed_room) and not completed_room.is_inside_tree()
	if not source_is_detached or not _transition_source_matches(completed_room, transition_token, true):
		candidate.free()
		if is_instance_valid(completed_room) and completed_room == current_room_instance \
			and not completed_room.is_inside_tree():
			room_container.add_child(completed_room)
		if _run_ended or _restart_in_progress:
			_finish_managed_transition(false)
			return
		_finish_managed_transition(false)
		_present_technical_error("ERRO: a sala concluída deixou de ser uma origem válida durante a preparação.", proposal, null, &"", false)
		return

	room_container.add_child(candidate)
	var attached_result: Dictionary = _validate_attached_candidate(candidate)
	if not bool(attached_result.get("valid", false)):
		room_container.remove_child(candidate)
		candidate.queue_free()
		await get_tree().process_frame
		if is_instance_valid(completed_room) and completed_room == current_room_instance \
			and not completed_room.is_inside_tree():
			room_container.add_child(completed_room)
		if _run_ended or _restart_in_progress:
			_finish_managed_transition(false)
			return
		_present_recoverable_transition_error(completed_room, transition_token, String(attached_result.get("error", "falha técnica ao validar a próxima sala")), proposal)
		return
	var source_remains_detached: bool = is_instance_valid(completed_room) and not completed_room.is_inside_tree()
	if not source_remains_detached or not _transition_source_matches(completed_room, transition_token, true):
		room_container.remove_child(candidate)
		candidate.queue_free()
		await get_tree().process_frame
		if is_instance_valid(completed_room) and completed_room == current_room_instance \
			and not completed_room.is_inside_tree():
			room_container.add_child(completed_room)
		if _run_ended or _restart_in_progress:
			_finish_managed_transition(false)
			return
		_finish_managed_transition(false)
		_present_technical_error("ERRO: a origem da transição mudou antes da confirmação da sala candidata.", proposal, null, &"", false)
		return

	var candidate_player: Player = attached_result.get("player") as Player
	_commit_room_candidate(candidate, candidate_player, proposal, completed_room)
	completed_room.queue_free()
	_pending_stage_proposal.clear()
	_pending_stage_source = null
	transition_pending = false
	await _fade_managed_transition_to(0.0, 0.22)
	if _run_ended or _restart_in_progress:
		_finish_managed_transition(false)
		return
	if not is_instance_valid(current_room_instance) or not current_room_instance.is_inside_tree():
		_finish_managed_transition(false)
		_present_restart_only_technical_error("ERRO: a sala candidata deixou de estar disponível após o commit.", _current_stage_proposal())
		return
	_finish_managed_transition(true)

func _boss_reward_is_applied_for(room: Node) -> bool:
	return room != null and is_instance_valid(room) \
		and _boss_reward_applied and _boss_reward_room_id == room.get_instance_id()

func _update_hud(status_text: String) -> void:
	var stage_text := (
		"CHEFE"
		if _is_boss_room()
		else "SALA %d/%d" % [current_room, common_rooms_per_floor]
	)
	if progress_label != null:
		progress_label.text = "ANDAR %02d/%02d | %s | SEED %d" % [
			current_floor,
			floors_per_run,
			stage_text,
			_resolved_run_seed,
		]
	if status_label != null:
		status_label.text = status_text


func _show_victory_screen() -> void:
	var overlay := CanvasLayer.new()
	overlay.name = "VictoryOverlay"
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(overlay)

	var backdrop := ColorRect.new()
	backdrop.color = Color(0.02, 0.04, 0.08, 0.94)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(backdrop)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(720, 300)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#101c2c")
	panel_style.border_color = Color("#f0b35b")
	panel_style.set_border_width_all(3)
	panel_style.set_corner_radius_all(14)
	panel_style.content_margin_left = 32
	panel_style.content_margin_right = 32
	panel_style.content_margin_top = 28
	panel_style.content_margin_bottom = 28
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 20)
	panel.add_child(content)

	var title := Label.new()
	title.text = "ENTREGA CONCLUÍDA!"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 34)
	title.add_theme_color_override("font_color", Color("#f0b35b"))
	content.add_child(title)

	var message := Label.new()
	message.text = "O robô chegou ao topo da torre."
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.add_theme_font_size_override("font_size", 20)
	content.add_child(message)

	var restart_button := Button.new()
	restart_button.text = "JOGAR NOVAMENTE"
	restart_button.custom_minimum_size = Vector2(260, 54)
	restart_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	restart_button.pressed.connect(_restart_run)
	content.add_child(restart_button)
	get_tree().paused = true


func _show_game_over_screen(message_text: String = "O robô ficou sem energia.") -> void:
	var overlay := CanvasLayer.new()
	overlay.name = "GameOverOverlay"
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(overlay)

	var backdrop := ColorRect.new()
	backdrop.color = Color(0.02, 0.04, 0.08, 0.94)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(backdrop)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(620, 280)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#101c2c")
	panel_style.border_color = Color("#e86b69")
	panel_style.set_border_width_all(3)
	panel_style.set_corner_radius_all(14)
	panel_style.content_margin_left = 32
	panel_style.content_margin_right = 32
	panel_style.content_margin_top = 28
	panel_style.content_margin_bottom = 28
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 20)
	panel.add_child(content)

	var title := Label.new()
	title.text = "RUN ENCERRADA"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 32)
	title.add_theme_color_override("font_color", Color("#e86b69"))
	content.add_child(title)

	var message := Label.new()
	message.text = message_text
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.add_theme_font_size_override("font_size", 20)
	content.add_child(message)

	var restart_button := Button.new()
	restart_button.text = "TENTAR NOVAMENTE"
	restart_button.custom_minimum_size = Vector2(260, 54)
	restart_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	restart_button.pressed.connect(_restart_run)
	content.add_child(restart_button)
	get_tree().paused = true

func _ensure_transition_fade() -> void:
	if is_instance_valid(_transition_fade_layer) and is_instance_valid(_transition_fade_rect):
		return
	_transition_fade_layer = CanvasLayer.new()
	_transition_fade_layer.name = "ManagedRoomTransitionFade"
	_transition_fade_layer.layer = 100
	_transition_fade_layer.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_transition_fade_layer)
	_transition_fade_rect = ColorRect.new()
	_transition_fade_rect.name = "Fade"
	_transition_fade_rect.color = Color(0.0, 0.0, 0.0, 0.0)
	_transition_fade_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_transition_fade_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_transition_fade_layer.add_child(_transition_fade_rect)

func _fade_managed_transition_to(target_alpha: float, duration: float) -> void:
	_ensure_transition_fade()
	if not is_instance_valid(_transition_fade_rect):
		return
	_transition_fade_rect.show()
	var start_alpha := _transition_fade_rect.color.a
	var tween := create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_method(_set_managed_fade_alpha, start_alpha, target_alpha, duration)
	await tween.finished

func _set_managed_fade_alpha(alpha: float) -> void:
	if not is_instance_valid(_transition_fade_rect):
		return
	var tint := _transition_fade_rect.color
	tint.a = clampf(alpha, 0.0, 1.0)
	_transition_fade_rect.color = tint

func _finish_managed_transition(release_owned_pause: bool) -> void:
	if is_instance_valid(_transition_fade_layer):
		_transition_fade_layer.queue_free()
	_transition_fade_layer = null
	_transition_fade_rect = null
	if release_owned_pause and not _run_ended and _owned_transition_pause and get_tree().paused:
		get_tree().paused = false
	_owned_transition_pause = false

func _hide_managed_transition_fade() -> void:
	if is_instance_valid(_transition_fade_rect):
		_set_managed_fade_alpha(0.0)
		_transition_fade_rect.hide()

func fail_managed_room_transition(room: Node, message: String) -> void:
	if _run_ended or room != current_room_instance:
		return
	_run_ended = true
	transition_pending = true
	_update_hud("FALHA NA TRANSIÇÃO: %s" % message)
	call_deferred("_present_managed_transition_failure")

func _present_managed_transition_failure() -> void:
	_finish_managed_transition(false)
	_owned_transition_pause = not get_tree().paused
	if _owned_transition_pause:
		get_tree().paused = true
	if _run_ended:
		_show_game_over_screen("A transição da sala falhou.")


func _present_technical_error(message: String, proposal: Dictionary, source: Node, retry_kind: StringName, allow_initial_retry: bool) -> void:
	if is_instance_valid(_technical_error_layer):
		_technical_error_layer.queue_free()
	_technical_error_source = source if source != null and is_instance_valid(source) \
		and source == current_room_instance and source.is_inside_tree() else null
	_technical_retry_kind = retry_kind
	_technical_retry_proposal = proposal.duplicate(true)
	if not get_tree().paused:
		_technical_error_pause_owned = true
		get_tree().paused = true
	var overlay := CanvasLayer.new()
	overlay.name = "ManagedRoomTechnicalError"
	overlay.layer = 200
	overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(overlay)
	_technical_error_layer = overlay
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.02, 0.04, 0.08, 0.96)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(backdrop)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(820.0, 380.0)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#101c2c")
	panel_style.border_color = Color("#f0b35b")
	panel_style.set_border_width_all(3)
	panel_style.set_corner_radius_all(14)
	panel_style.content_margin_left = 30
	panel_style.content_margin_right = 30
	panel_style.content_margin_top = 26
	panel_style.content_margin_bottom = 26
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 16)
	panel.add_child(content)
	var title := Label.new()
	title.text = "ERRO TÉCNICO — RUN PRESERVADA"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 28)
	title.add_theme_color_override("font_color", Color("#f0b35b"))
	content.add_child(title)
	var details := Label.new()
	details.text = _technical_error_details(message, proposal)
	details.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	details.custom_minimum_size = Vector2(740.0, 190.0)
	content.add_child(details)
	if _technical_error_source != null:
		var return_button := Button.new()
		return_button.text = "VOLTAR À SALA CONCLUÍDA"
		return_button.custom_minimum_size = Vector2(300.0, 48.0)
		return_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		return_button.pressed.connect(_return_to_completed_room)
		content.add_child(return_button)
	elif allow_initial_retry:
		var retry_button := Button.new()
		retry_button.text = "TENTAR NOVAMENTE COM A MESMA SEED"
		retry_button.custom_minimum_size = Vector2(360.0, 48.0)
		retry_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		retry_button.pressed.connect(_retry_initial_load)
		content.add_child(retry_button)
	var restart_button := Button.new()
	restart_button.text = "REINICIAR RUN"
	restart_button.custom_minimum_size = Vector2(240.0, 42.0)
	restart_button.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	restart_button.pressed.connect(_restart_run)
	content.add_child(restart_button)

func _technical_error_details(message: String, proposal: Dictionary) -> String:
	var floor_index: int = int(proposal.get("floor", current_floor))
	var room_index: int = int(proposal.get("room", current_room))
	var descriptor: Dictionary = proposal.get("descriptor", {})
	var destination_text := "Andar %d, sala %d" % [floor_index, room_index]
	var family_text := String(descriptor.get("family", proposal.get("last_family", "indisponível")))
	var room_seed_text := "indisponível"
	if descriptor.has("room_seed"):
		room_seed_text = str(int(descriptor.get("room_seed", 0)))
	destination_text += " — família %s, seed da sala %s" % [family_text, room_seed_text]
	return "%s\n\nSeed da run: %d\nDestino: %s" % [message, _resolved_run_seed, destination_text]

func _dismiss_technical_error() -> void:
	if is_instance_valid(_technical_error_layer):
		_technical_error_layer.queue_free()
	_technical_error_layer = null
	_technical_error_source = null

func _release_technical_error_pause() -> void:
	if _technical_error_pause_owned and get_tree().paused:
		get_tree().paused = false
	_technical_error_pause_owned = false

func _return_to_completed_room() -> void:
	var source: Node = _technical_error_source
	if source == null or not is_instance_valid(source) or source != current_room_instance or not source.is_inside_tree():
		return
	_dismiss_technical_error()
	transition_pending = false
	_connect_room_progression_signal(source)
	_update_hud("SALA CONCLUÍDA — ATRAVESSE A SAÍDA PARA TENTAR DE NOVO")
	if is_instance_valid(_transition_fade_layer):
		_finish_managed_transition(true)
	else:
		_release_technical_error_pause()

func _retry_initial_load() -> void:
	if _technical_error_source != null:
		return
	var retry_kind: StringName = _technical_retry_kind
	var retry_proposal: Dictionary = _technical_retry_proposal.duplicate(true)
	_dismiss_technical_error()
	if retry_kind == &"floor_plan":
		if not _prepare_current_floor_plan():
			_present_technical_error(_initial_floor_plan_error, {}, null, &"floor_plan", true)
			return
		retry_proposal = _current_stage_proposal()
	if not bool(retry_proposal.get("valid", false)):
		retry_proposal = _current_stage_proposal()
	if not _load_current_encounter(retry_proposal):
		return
	_release_technical_error_pause()


func _unhandled_input(event: InputEvent) -> void:
	if not _run_ended or not event is InputEventKey:
		return
	var key_event := event as InputEventKey
	if key_event.pressed and not key_event.echo and key_event.keycode == KEY_R:
		get_viewport().set_input_as_handled()
		_restart_run()

func _restart_run() -> void:
	if (not _run_ended and not is_instance_valid(_technical_error_layer)) or _restart_in_progress:
		return
	_restart_in_progress = true
	_dismiss_technical_error()
	_technical_error_pause_owned = false
	_finish_managed_transition(false)
	get_tree().paused = false
	get_tree().reload_current_scene()
func _apply_reward(reward_name: String) -> void:
	match reward_name:
		"Núcleo de impacto":
			_damage_multiplier *= 1.25
		"Propulsor":
			_speed_multiplier *= 1.15
		"Esfera ampliada":
			_radius_multiplier *= 1.15


func _apply_run_upgrades(node: Node) -> void:
	if node is BallLauncher:
		(node as BallLauncher).set_run_reward_multipliers(
			_damage_multiplier,
			_speed_multiplier,
			_radius_multiplier
		)
	for child in node.get_children():
		_apply_run_upgrades(child)


func _find_player(node: Node) -> Player:
	if node is Player:
		return node as Player
	for child in node.get_children():
		var found := _find_player(child)
		if found != null:
			return found
	return null


func _on_room_player_died(room: Node) -> void:
	if room != current_room_instance or _run_ended:
		return
	_run_ended = true
	transition_pending = true
	_dismiss_technical_error()
	_technical_error_pause_owned = false
	_finish_managed_transition(false)
	if is_instance_valid(_active_reward_screen) and _active_reward_screen.has_method("cancel_offer"):
		_active_reward_screen.call("cancel_offer")
	call_deferred("_present_game_over_after_physics")

func _present_game_over_after_physics() -> void:
	_close_owned_reward_pause()
	if _run_ended:
		_show_game_over_screen()

func _close_owned_reward_pause() -> void:
	if _owned_reward_pause and not _run_ended and get_tree().paused:
		get_tree().paused = false
	_owned_reward_pause = false

func _on_room_health_changed(current_health: int, maximum_health: int, room: Node) -> void:
	if room != current_room_instance or not is_instance_valid(room):
		return
	_run_player_health = current_health
	_run_player_max_health = maximum_health

func _discard_current_room(message: String) -> void:
	var room_to_discard := current_room_instance
	current_room_instance = null
	if is_instance_valid(room_to_discard):
		if room_to_discard.is_inside_tree():
			room_container.remove_child(room_to_discard)
		room_to_discard.queue_free()
	_present_technical_error(message, _current_stage_proposal(), null, &"initial_load", true)

func _fail_run(message: String) -> void:
	push_error("RunController: " + message)
	_update_hud(message)
	_present_technical_error(message, _current_stage_proposal(), current_room_instance, &"initial_load", current_room_instance == null)
