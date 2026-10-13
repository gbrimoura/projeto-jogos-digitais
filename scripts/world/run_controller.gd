extends Node2D

@export_range(1, 20, 1)
var floors_per_run: int = 8

@export_range(1, 10, 1)
var common_rooms_per_floor: int = 3

@export_range(0.2, 10.0, 0.1)
var transition_delay: float = 1.5

@export var common_room_scene: PackedScene
@export var boss_room_scene: PackedScene

@onready var room_container: Node2D = $RoomContainer
@onready var progress_label: Label = $HUD/ProgressLabel
@onready var status_label: Label = $HUD/StatusLabel

var current_floor: int = 1
var current_room: int = 1
var current_room_instance: Node
var transition_pending: bool = false
var _damage_multiplier: float = 1.0
var _speed_multiplier: float = 1.0
var _radius_multiplier: float = 1.0
var _run_player_health: int = -1


func _ready() -> void:
	if common_room_scene == null:
		push_error("RunController: defina a cena de sala comum no Inspector.")
		status_label.text = "ERRO: cena de sala comum não definida."
		return

	if boss_room_scene == null:
		push_error("RunController: defina a cena de chefe no Inspector.")
		status_label.text = "ERRO: cena de chefe não definida."
		return

	_load_current_encounter()


func _is_boss_room() -> bool:
	return current_room > common_rooms_per_floor


func _is_final_boss() -> bool:
	return current_floor == floors_per_run and _is_boss_room()


func _load_current_encounter() -> void:
	var packed_scene: PackedScene

	if _is_boss_room():
		packed_scene = boss_room_scene
	else:
		packed_scene = common_room_scene

	var next_room: Node = packed_scene.instantiate()
	_apply_run_upgrades(next_room)
	var combat_room: Node = next_room.get_node_or_null("CombatRoom")

	if combat_room == null:
		push_error(
			"RunController: a cena carregada não tem um nó chamado CombatRoom."
		)
		next_room.free()
		status_label.text = "ERRO: a cena não contém CombatRoom."
		return

	if not combat_room.has_signal("room_cleared"):
		push_error(
			"RunController: CombatRoom não possui o sinal room_cleared."
		)
		next_room.free()
		status_label.text = "ERRO: sinal room_cleared não encontrado."
		return

	combat_room.connect("room_cleared", _on_room_cleared)
	room_container.add_child(next_room)
	current_room_instance = next_room
	var player := _find_player(next_room)
	if player != null:
		player.health_changed.connect(_on_player_health_changed)

		if _run_player_health < 0:
			_run_player_health = player.health
		else:
			player.restore_health(_run_player_health)

	player.died.connect(_on_player_died, CONNECT_ONE_SHOT)
	if player != null:
		player.died.connect(_on_player_died, CONNECT_ONE_SHOT)
		
	_update_hud("ENCONTRO ATIVO")


func _on_room_cleared() -> void:
	
	if transition_pending:
		return

	transition_pending = true
	if _is_boss_room():
		var reward_screen: CanvasLayer = preload(
			"res://scripts/ui/reward_screen.gd"
		).new()
		add_child(reward_screen)

		var selected_reward: String = await reward_screen.reward_chosen
		_apply_reward(selected_reward)
		print("Recompensa escolhida: ", selected_reward)
		reward_screen.queue_free()

	if _is_final_boss():
		_show_victory_screen()
		return

	status_label.text = "SALA CONCLUÍDA. PRÓXIMA ETAPA EM %.1f s." % transition_delay
	await get_tree().create_timer(transition_delay).timeout

	var old_room: Node = current_room_instance
	current_room_instance = null

	if is_instance_valid(old_room):
		old_room.queue_free()

	await get_tree().process_frame

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
	var stage_text: String

	if _is_boss_room():
		stage_text = "CHEFE"
	else:
		stage_text = "SALA %d/%d" % [
			current_room,
			common_rooms_per_floor
		]

	progress_label.text = "ANDAR %02d/%02d | %s" % [
		current_floor,
		floors_per_run,
		stage_text
	]
	status_label.text = status_text
	
func _show_victory_screen() -> void:
	var overlay := CanvasLayer.new()
	overlay.name = "VictoryOverlay"
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


func _restart_run() -> void:
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
		var launcher := node as BallLauncher

		if launcher.projectile_config != null:
			var upgraded_config := (
				launcher.projectile_config.duplicate(true) as ProjectileConfig
			)
			upgraded_config.damage = maxi(
				roundi(float(upgraded_config.damage) * _damage_multiplier),
				1
			)
			upgraded_config.speed *= _speed_multiplier
			upgraded_config.collision_radius *= _radius_multiplier
			launcher.projectile_config = upgraded_config

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
	if transition_pending:
		return

	transition_pending = true
	_show_game_over_screen()


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
	restart_button.pressed.connect(_restart_after_defeat)
	content.add_child(restart_button)

	get_tree().paused = true


func _restart_after_defeat() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()
	
func _on_player_health_changed(current_health: int, _maximum_health: int) -> void:
	_run_player_health = current_health
