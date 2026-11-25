extends Node

signal completed

const PORTRAIT_PATH: String = "res://assets/narrative/tutorial/faisca-portrait.png"
const STEP_COUNT: int = 5
const REQUIRED_MOVEMENT_DISTANCE: float = 36.0

var _active: bool = false
var _initialized: bool = false
var _summary_visible: bool = false
var _traveling: bool = false
var _step_index: int = 0
var _player: CharacterBody2D
var _movement: MovementController
var _launcher: BallLauncher
var _racket: RacketController
var _panel: PanelContainer
var _portrait: TextureRect
var _speaker_label: Label
var _progress_label: Label
var _dialogue_label: Label
var _hint_label: Label
var _movement_distance: float = 0.0
var _previous_player_x: float = 0.0
var _jump_started: bool = false
var _jump_saw_ground: bool = false
var _dash_step_saw_inactive: bool = false

func start(player: CharacterBody2D, overlay: CanvasLayer) -> void:
	if player == null or overlay == null:
		push_warning("Tutorial da Faísca não encontrou o jogador ou a camada de interface.")
		return

	if not ResourceLoader.exists(PORTRAIT_PATH):
		push_warning("Tutorial da Faísca não encontrou o retrato.")
		return

	_player = player
	_movement = player.get_node_or_null("MovementController") as MovementController
	_launcher = player.get_node_or_null("BallLauncher") as BallLauncher
	_racket = player.get_node_or_null("RacketController") as RacketController
	if _movement == null or _launcher == null or _racket == null:
		push_warning("Tutorial da Faísca não encontrou todos os controles do jogador.")
		return

	_previous_player_x = _player.global_position.x
	process_physics_priority = 1
	_launcher.launch_accepted.connect(_on_launch_accepted)
	_racket.swing_started.connect(_on_swing_started)
	_build_panel(overlay)
	_initialized = true
	_active = true
	_show_step()

func has_started() -> bool:
	return _initialized

func set_traveling(traveling: bool) -> void:
	if not _initialized:
		return
	_traveling = traveling
	if _traveling:
		_panel.hide()
	elif _active or _summary_visible:
		_panel.show()

func _physics_process(_delta: float) -> void:
	if not _active or _traveling or not is_instance_valid(_player):
		return

	match _step_index:
		0:
			var current_x: float = _player.global_position.x
			if _player.is_on_floor() and not _movement.is_dashing:
				_movement_distance += absf(current_x - _previous_player_x)
			_previous_player_x = current_x
			if _movement_distance >= REQUIRED_MOVEMENT_DISTANCE:
				_advance_step()
		1:
			if _player.is_on_floor():
				if _jump_started:
					_advance_step()
				else:
					_jump_saw_ground = true
			elif _jump_saw_ground and _player.velocity.y < -20.0:
				_jump_started = true
		2:
			if not _movement.is_dashing:
				_dash_step_saw_inactive = true
			elif _dash_step_saw_inactive:
				_advance_step()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is not InputEventKey:
		return
	var key_event: InputEventKey = event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	var is_tutorial_key: bool = key_event.keycode == KEY_F or key_event.physical_keycode == KEY_F
	if not is_tutorial_key or _traveling or (not _active and not _summary_visible):
		return
	get_viewport().set_input_as_handled()
	if _active:
		_finish_tutorial(false)
	elif _summary_visible:
		_summary_visible = false
		_panel.hide()

func _build_panel(overlay: CanvasLayer) -> void:
	var root := Control.new()
	root.name = "FaiscaTutorialOverlay"
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(root)

	_panel = PanelContainer.new()
	_panel.name = "TutorialCard"
	_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_panel.custom_minimum_size = Vector2(0.0, 108.0)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#0C1B29")
	style.border_color = Color("#D2A75C")
	style.set_border_width_all(2)
	style.content_margin_left = 12.0
	style.content_margin_right = 12.0
	style.content_margin_top = 8.0
	style.content_margin_bottom = 8.0
	_panel.add_theme_stylebox_override("panel", style)
	root.add_child(_panel)
	_panel.minimum_size_changed.connect(_fit_panel_height, CONNECT_DEFERRED)

	var row := HBoxContainer.new()
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	row.add_theme_constant_override("separation", 12)
	_panel.add_child(row)

	_portrait = TextureRect.new()
	_portrait.name = "FaiscaPortrait"
	_portrait.custom_minimum_size = Vector2(48.0, 48.0)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_portrait.texture = load(PORTRAIT_PATH) as Texture2D
	row.add_child(_portrait)

	var copy := VBoxContainer.new()
	copy.mouse_filter = Control.MOUSE_FILTER_IGNORE
	copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	copy.add_theme_constant_override("separation", 3)
	row.add_child(copy)

	var title_row := HBoxContainer.new()
	title_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	copy.add_child(title_row)

	_speaker_label = Label.new()
	_speaker_label.text = "FAÍSCA"
	_speaker_label.add_theme_font_size_override("font_size", 14)
	_speaker_label.add_theme_color_override("font_color", Color("#B9D65B"))
	_speaker_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_row.add_child(_speaker_label)

	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	spacer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_row.add_child(spacer)

	_progress_label = Label.new()
	_progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	_progress_label.add_theme_font_size_override("font_size", 12)
	_progress_label.add_theme_color_override("font_color", Color("#D2A75C"))
	_progress_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	title_row.add_child(_progress_label)

	_dialogue_label = Label.new()
	_dialogue_label.add_theme_font_size_override("font_size", 15)
	_dialogue_label.add_theme_color_override("font_color", Color("#F2E9D6"))
	_dialogue_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_dialogue_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_dialogue_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	copy.add_child(_dialogue_label)

	_hint_label = Label.new()
	_hint_label.add_theme_font_size_override("font_size", 11)
	_hint_label.add_theme_color_override("font_color", Color("#91A7A8"))
	_hint_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_hint_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	copy.add_child(_hint_label)

	var viewport: Viewport = get_viewport()
	if viewport != null:
		viewport.size_changed.connect(_layout_panel)
	_layout_panel()

func _layout_panel() -> void:
	if _panel == null:
		return
	var viewport: Viewport = get_viewport()
	if viewport == null:
		return
	var viewport_size: Vector2 = viewport.get_visible_rect().size
	var panel_width: float = minf(maxf(viewport_size.x - 24.0, 1.0), 780.0)
	_panel.position = Vector2((viewport_size.x - panel_width) * 0.5, 14.0)
	_panel.size = Vector2(panel_width, 108.0)
	call_deferred("_fit_panel_height")

func _fit_panel_height() -> void:
	if not is_instance_valid(_panel):
		return
	_panel.size.y = maxf(108.0, _panel.get_combined_minimum_size().y)

func _show_step() -> void:
	var instruction: String = ""
	match _step_index:
		0:
			instruction = "Oi, Ampère! Sou Faísca, a voz da sua bola. Dê uma caminhada curta com A/D ou ←/→."
		1:
			instruction = "Agora pule e pouse de volta: Espaço, W ou ↑."
		2:
			instruction = "Use Shift para dar um dash. Segure uma direção para escolher o lado."
		3:
			instruction = "Mire com o mouse e clique com o botão esquerdo para lançar a bola."
		4:
			instruction = "Clique com o botão direito para praticar o golpe da raquete, Ampère!"
	_progress_label.text = "TREINO %d / %d" % [_step_index + 1, STEP_COUNT]
	_dialogue_label.text = instruction
	_hint_label.text = "F  PULAR TUTORIAL     •     E  OFICINA PERTO DA ÍRIS     •     ESC  PAUSA"
	call_deferred("_fit_panel_height")
	_panel.show()

func _advance_step() -> void:
	_step_index += 1
	if _step_index == 1:
		_jump_saw_ground = _player.is_on_floor()
		_jump_started = false
	elif _step_index == 2:
		_dash_step_saw_inactive = not _movement.is_dashing
	if _step_index >= STEP_COUNT:
		_finish_tutorial(true)
		return
	_show_step()

func _finish_tutorial(show_summary: bool) -> void:
	if not _active:
		return
	_active = false
	_summary_visible = show_summary
	completed.emit()
	if not show_summary:
		_panel.hide()
		return
	_progress_label.text = "CONCLUÍDO"
	_dialogue_label.text = "Boa, Ampère! Siga até o elevador e aperte E para subir. A oficina da Íris também fica neste pátio."
	_hint_label.text = "E  OFICINA DA ÍRIS     •     E  ELEVADOR     •     F  FECHAR"
	call_deferred("_fit_panel_height")

func _on_launch_accepted(_spawn_position: Vector2, _direction: Vector2) -> void:
	if _active and _step_index == 3:
		_advance_step()

func _on_swing_started(_direction: Vector2, _duration: float) -> void:
	if _active and _step_index == 4:
		_advance_step()
