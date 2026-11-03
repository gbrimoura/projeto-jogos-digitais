extends Node2D

const RunBuild = preload("res://scripts/progression/run_build.gd")
const RoomTransition = preload("res://scripts/world/room_transition.gd")
const RewardScreenScript = preload("res://scripts/ui/reward_screen.gd")

@export_range(1, 20) var floors_per_run: int = 8
@export_range(1, 10) var common_rooms_per_floor: int = 3
@export_range(0.2, 10.0, 0.1) var transition_delay: float = 1.5
@export var common_room_scene: PackedScene
@export var boss_room_scene: PackedScene

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
var _restart_in_progress: bool = false


func _ready() -> void:
	# The run controller must handle overlays and progression while gameplay is paused.
	process_mode = Node.PROCESS_MODE_ALWAYS
	RoomTransition.clear_pending_snapshot()
	if common_room_scene == null:
		_fail_run("ERRO: cena de sala comum não definida.")
		return
	if boss_room_scene == null:
		_fail_run("ERRO: cena de chefe não definida.")
		return
	_load_current_encounter()


func _is_boss_room() -> bool:
	return current_room > common_rooms_per_floor


func _is_final_boss() -> bool:
	return current_floor == floors_per_run and _is_boss_room()


func _load_current_encounter() -> void:
	if _run_ended:
		return

	var packed_scene: PackedScene = boss_room_scene if _is_boss_room() else common_room_scene
	var next_room := packed_scene.instantiate()
	# RunRoot processes while paused; room descendants must still stop with gameplay.
	next_room.process_mode = Node.PROCESS_MODE_PAUSABLE
	if not next_room.has_method("configure_run_managed"):
		next_room.free()
		_fail_run("ERRO: a cena de sala não oferece integração gerenciada.")
		return
	if not next_room.has_signal("run_progression_ready"):
		next_room.free()
		_fail_run("ERRO: a sala não oferece o sinal run_progression_ready.")
		return
	var should_offer_build_upgrade := _run_build.total_count() == 0
	if not bool(next_room.call("configure_run_managed", _run_build, should_offer_build_upgrade)):
		next_room.free()
		_fail_run("ERRO: não foi possível configurar a sala para esta run.")
		return

	var progression_callback := Callable(self, "_on_room_progression_ready").bind(next_room)
	next_room.connect("run_progression_ready", progression_callback, CONNECT_ONE_SHOT)
	room_container.add_child(next_room)
	current_room_instance = next_room

	var player := _find_player(next_room)
	if player == null or player.health == null:
		_discard_current_room("ERRO: a sala não contém um jogador com PlayerHealth.")
		return

	if _run_player_health < 0:
		_run_player_health = player.current_health
		_run_player_max_health = player.maximum_health
	else:
		if _run_player_health <= 0 or _run_player_max_health <= 0:
			_discard_current_room("ERRO: HP inválido; a run não pode continuar.")
			return
		if not player.health.restore_health_for_room_transition(
			_run_player_health,
			_run_player_max_health
		):
			_discard_current_room("ERRO: não foi possível restaurar o HP da run.")
			return

	if not player.health_changed.is_connected(_on_player_health_changed):
		player.health_changed.connect(_on_player_health_changed)
	if not player.died.is_connected(_on_player_died):
		player.died.connect(_on_player_died)
	_on_player_health_changed(player.current_health, player.maximum_health)

	# Main._ready reapplies the shared RunBuild; branch modifiers are installed
	# afterward and are applied to each derived projectile config at launch.
	_apply_run_upgrades(next_room)
	_update_hud("ENCONTRO ATIVO")


func _on_room_progression_ready(room: Node) -> void:
	if _run_ended or transition_pending or room != current_room_instance:
		return
	transition_pending = true
	call_deferred("_advance_after_room", room)


func _advance_after_room(completed_room: Node) -> void:
	if _run_ended or completed_room != current_room_instance:
		return

	if _is_boss_room():
		var reward_screen: Variant = RewardScreenScript.new()
		if reward_screen == null:
			_fail_run("ERRO: não foi possível abrir a recompensa do chefe.")
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
		if _run_ended or selected_reward.is_empty():
			return
		_apply_reward(selected_reward)

	if _is_final_boss():
		_run_ended = true
		_show_victory_screen()
		return

	_update_hud("SALA CONCLUÍDA. PRÓXIMA ETAPA EM %.1f s." % transition_delay)
	await get_tree().create_timer(maxf(transition_delay, 0.0)).timeout
	if _run_ended or completed_room != current_room_instance:
		return

	current_room_instance = null
	if is_instance_valid(completed_room):
		completed_room.queue_free()
	await get_tree().process_frame
	if _run_ended:
		return

	_advance_stage()
	transition_pending = false
	_load_current_encounter()


func _advance_stage() -> void:
	if _is_boss_room():
		current_floor += 1
		current_room = 1
	else:
		current_room += 1


func _update_hud(status_text: String) -> void:
	var stage_text := (
		"CHEFE"
		if _is_boss_room()
		else "SALA %d/%d" % [current_room, common_rooms_per_floor]
	)
	if progress_label != null:
		progress_label.text = "ANDAR %02d/%02d | %s" % [
			current_floor,
			floors_per_run,
			stage_text,
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


func _show_game_over_screen() -> void:
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
	message.text = "O robô ficou sem energia."
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


func _unhandled_input(event: InputEvent) -> void:
	if not _run_ended or not event is InputEventKey:
		return
	var key_event := event as InputEventKey
	if key_event.pressed and not key_event.echo and key_event.keycode == KEY_R:
		get_viewport().set_input_as_handled()
		_restart_run()

func _restart_run() -> void:
	if not _run_ended or _restart_in_progress:
		return
	_restart_in_progress = true
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


func _on_player_died() -> void:
	if _run_ended:
		return
	_run_ended = true
	transition_pending = true
	if is_instance_valid(_active_reward_screen) and _active_reward_screen.has_method("cancel_offer"):
		_active_reward_screen.call("cancel_offer")
	call_deferred("_present_game_over_after_physics")


func _present_game_over_after_physics() -> void:
	_close_owned_reward_pause()
	if _run_ended:
		_show_game_over_screen()


func _close_owned_reward_pause() -> void:
	if _owned_reward_pause and get_tree().paused:
		get_tree().paused = false
	_owned_reward_pause = false


func _on_player_health_changed(current_health: int, maximum_health: int) -> void:
	_run_player_health = current_health
	_run_player_max_health = maximum_health


func _discard_current_room(message: String) -> void:
	var room_to_discard := current_room_instance
	current_room_instance = null
	_run_ended = true
	transition_pending = true
	if is_instance_valid(room_to_discard):
		room_to_discard.queue_free()
	_fail_run(message)


func _fail_run(message: String) -> void:
	_run_ended = true
	transition_pending = true
	push_error("RunController: " + message)
	_update_hud(message)
