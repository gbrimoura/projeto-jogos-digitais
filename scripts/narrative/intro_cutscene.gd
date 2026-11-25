extends Control

const LOBBY_PATH: String = "res://scenes/lobby.tscn"
const SESSION_INTRO_META: StringName = &"intro_completed_this_session"
const DESIGN_SIZE: Vector2 = Vector2(576.0, 324.0)
const INTRO_LINES: Array[Dictionary] = [
	{"beat": 0, "speaker": "ÍRIS", "text": "Ei. Sou Íris, da manutenção. Achei você debaixo daquela viga."},
	{"beat": 0, "speaker": "Você", "choices": ["O que aconteceu?", "Cadê minha encomenda?"]},
	{"beat": 1, "speaker": "ÍRIS", "replies": [
		"Ouvi a recepção fechar. Logo depois, parte do teto desabou.",
		"Bem aqui. Caiu perto da sua mão. O lacre está inteiro.",
	]},
	{"beat": 1, "speaker": "ÍRIS", "text": "A etiqueta diz Pecúnia. O prefeito está no alto da torre."},
	{"beat": 2, "speaker": "ÍRIS", "text": "Os robôs de Pendergast tomaram a recepção. Eu conheço outra entrada."},
	{"beat": 2, "speaker": "Você", "choices": ["Quem é Pendergast?", "Como entro na torre?"]},
	{"beat": 2, "speaker": "ÍRIS", "replies": [
		"Pendergast comanda os capangas. Deixou os robôs na entrada para barrar quem tenta subir.",
		"Vá pelo pátio. O elevador de serviço começa no primeiro andar.",
	]},
	{"beat": 3, "speaker": "ÍRIS", "text": "A passagem de serviço fica à direita. Por ali, a gente chega ao pátio."},
	{"beat": 4, "speaker": "ÍRIS", "text": "Minha oficina fica no pátio. Traga marcas da torre e eu reforço seu equipamento."},
]

@onready var _stage: Control = $Stage
@onready var _backdrop: TextureRect = $Stage/Backdrop
@onready var _warmth: ColorRect = $Stage/Warmth
@onready var _dimmer: ColorRect = $Stage/Dimmer
@onready var _guide: Sprite2D = $Stage/Iris
@onready var _player: Sprite2D = $Stage/Ampere
@onready var _package: Node2D = $Stage/Package
@onready var _dialogue_panel: Panel = $Stage/DialoguePanel
@onready var _portrait: Sprite2D = $Stage/DialoguePanel/IrisPortrait
@onready var _speaker_label: Label = $Stage/DialoguePanel/Speaker
@onready var _progress_label: Label = $Stage/DialoguePanel/Progress
@onready var _dialogue_label: Label = $Stage/DialoguePanel/Dialogue
@onready var _advance_button: Button = $Stage/DialoguePanel/AdvanceButton
@onready var _choice_buttons: Array[Button] = [$Stage/DialoguePanel/ChoiceFirst, $Stage/DialoguePanel/ChoiceSecond]
@onready var _input_hint: Label = $Stage/DialoguePanel/InputHint
@onready var _skip_button: Button = $Stage/SkipButton
@onready var _status_label: Label = $Stage/Status

var _line_index: int = -1
var _current_beat: int = -1
var _selected_reply: int = 0
var _line_ready: bool = false
var _scene_change_in_progress: bool = false
var _lobby_load_failed: bool = false
var _scene_tween: Tween

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_advance_button.pressed.connect(_advance_dialogue)
	_skip_button.pressed.connect(_finish_intro)
	_dialogue_panel.gui_input.connect(_on_dialogue_panel_gui_input)
	_style_button(_advance_button, true)
	_style_button(_skip_button, false)
	for i in _choice_buttons.size():
		var button := _choice_buttons[i]
		_style_button(button, false)
		button.pressed.connect(_choose_reply.bind(i))
		var other := _choice_buttons[1 - i]
		button.focus_neighbor_left = button.get_path_to(other)
		button.focus_neighbor_right = button.get_path_to(other)
		button.focus_previous = button.get_path_to(_skip_button if i == 0 else other)
		button.focus_next = button.get_path_to(_skip_button if i == 1 else other)
	_advance_button.disabled = true
	_skip_button.disabled = false
	_status_label.visible = false
	_advance_button.focus_next = _advance_button.get_path_to(_skip_button)
	_skip_button.focus_previous = _skip_button.get_path_to(_advance_button)
	_layout_stage()
	resized.connect(_layout_stage)
	_set_starting_composition()
	_play_opening()

func _process(_delta: float) -> void:
	var clock: float = float(Time.get_ticks_msec()) / 1000.0
	_warmth.color = Color(1.0, 0.58, 0.24, 0.035 + 0.018 * (0.5 + 0.5 * sin(clock * 1.1)))

func _unhandled_input(event: InputEvent) -> void:
	if event is not InputEventKey:
		return
	var key_event: InputEventKey = event as InputEventKey
	if not key_event.pressed or key_event.echo:
		return
	var is_escape: bool = key_event.keycode == KEY_ESCAPE or key_event.physical_keycode == KEY_ESCAPE
	if is_escape:
		get_viewport().set_input_as_handled()
		_finish_intro()
		return
	if _is_choice_line() and _line_ready:
		var first: bool = key_event.keycode in [KEY_1, KEY_KP_1] or key_event.physical_keycode in [KEY_1, KEY_KP_1]
		var second: bool = key_event.keycode in [KEY_2, KEY_KP_2] or key_event.physical_keycode in [KEY_2, KEY_KP_2]
		if first or second:
			get_viewport().set_input_as_handled()
			_choose_reply(0 if first else 1)
		return
	var is_advance_key: bool = key_event.keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE] \
		or key_event.physical_keycode in [KEY_ENTER, KEY_KP_ENTER, KEY_SPACE]
	if is_advance_key and _line_ready:
		get_viewport().set_input_as_handled()
		_advance_dialogue()

func _on_dialogue_panel_gui_input(event: InputEvent) -> void:
	if event is not InputEventMouseButton:
		return
	var mouse_event: InputEventMouseButton = event as InputEventMouseButton
	if mouse_event.pressed and mouse_event.button_index == MOUSE_BUTTON_LEFT and _line_ready and not _is_choice_line():
		_dialogue_panel.accept_event()
		_advance_dialogue()

func _layout_stage() -> void:
	var fit: float = minf(size.x / DESIGN_SIZE.x, size.y / DESIGN_SIZE.y)
	if fit <= 0.0:
		return
	_stage.scale = Vector2.ONE * fit
	_stage.position = ((size - DESIGN_SIZE * fit) * 0.5).floor()

func _set_starting_composition() -> void:
	_guide.centered = false
	_guide.offset = Vector2(-48.0, -81.0)
	_guide.hframes = 6
	_guide.position = Vector2(244.0, 220.0)
	_guide.scale = Vector2(1.50, 1.50)
	_guide.modulate = Color.WHITE

	_player.centered = false
	_player.offset = Vector2(-48.0, -81.0)
	_player.hframes = 7
	_player.frame = 0
	_player.position = Vector2(308.0, 220.0)
	_player.scale = Vector2(1.25, 1.25)
	_player.modulate = Color(0.72, 0.77, 0.80, 1.0)

	_package.position = Vector2(349.0, 216.0)
	_package.modulate = Color.WHITE
	_package.visible = true
	_dialogue_panel.modulate.a = 0.0
	_dialogue_label.modulate.a = 1.0
	_dimmer.color = Color(0.018, 0.034, 0.052, 0.52)

func _play_opening() -> void:
	_set_line_content(0)
	var wake: Tween = create_tween()
	_scene_tween = wake
	wake.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	wake.tween_property(_dimmer, "color:a", 0.0, 0.72)
	wake.parallel().tween_property(_player, "modulate", Color.WHITE, 0.72)
	wake.tween_property(_dialogue_panel, "modulate:a", 1.0, 0.16)
	wake.tween_callback(func() -> void:
		_guide.frame = 1
		_guide.position.x = 249.0
	)
	wake.tween_property(_guide, "position:x", 244.0, 0.15)
	wake.tween_interval(0.08)
	wake.tween_callback(func() -> void:
		_player.frame = 1
		_guide.frame = 2
	)
	wake.tween_interval(0.18)
	wake.tween_callback(func() -> void: _player.frame = 2)
	wake.tween_interval(0.20)
	wake.tween_callback(func() -> void: _player.frame = 3)
	wake.tween_interval(0.22)
	wake.tween_callback(func() -> void:
		_player.frame = 4
	)
	wake.tween_interval(0.12)
	wake.tween_callback(func() -> void:
		_current_beat = 0
		_unlock_line()
	)

func _show_line(index: int) -> void:
	if _scene_change_in_progress:
		return
	var target_beat := _set_line_content(index)
	var beat_changed: bool = target_beat != _current_beat
	_advance_button.disabled = true
	_line_ready = false
	_dialogue_panel.modulate.a = 0.0

	var reveal: Tween = create_tween()
	_scene_tween = reveal
	reveal.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	reveal.tween_property(_dialogue_panel, "modulate:a", 1.0, 0.11)
	if beat_changed:
		_append_beat_action(reveal, target_beat)
	reveal.tween_callback(func() -> void:
		_current_beat = target_beat
		_unlock_line()
	)

func _set_line_content(index: int) -> int:
	_line_index = clampi(index, 0, INTRO_LINES.size() - 1)
	var line: Dictionary = INTRO_LINES[_line_index]
	var beat: int = int(line["beat"])
	_speaker_label.text = String(line["speaker"])
	_portrait.visible = _speaker_label.text == "ÍRIS"
	_speaker_label.position.x = 76.0 if _portrait.visible else 14.0
	if _portrait.visible:
		if line.has("replies"):
			_portrait.frame = (0 if beat == 1 else 2) + _selected_reply
		else:
			_portrait.frame = [0, 1, 2, 3, 3][beat]
	if line.has("replies"):
		var replies: Array = line["replies"]
		_dialogue_label.text = String(replies[_selected_reply])
	else:
		_dialogue_label.text = String(line.get("text", ""))
	var choices: Array = line.get("choices", [])
	_advance_button.visible = choices.is_empty()
	_dialogue_label.visible = choices.is_empty()
	_input_hint.text = "1 / 2 OU CLIQUE" if not choices.is_empty() else "ESPAÇO / ENTER"
	for i in _choice_buttons.size():
		var button := _choice_buttons[i]
		button.visible = i < choices.size()
		button.disabled = true
		if button.visible:
			button.text = "%d. %s" % [i + 1, choices[i]]
	_skip_button.focus_previous = _skip_button.get_path_to(_advance_button if choices.is_empty() else _choice_buttons[-1])
	_skip_button.focus_next = _skip_button.get_path_to(_advance_button if choices.is_empty() else _choice_buttons[0])
	_progress_label.text = str(beat + 1, " / 5")
	_set_speaker_tint(String(line["speaker"]))
	_advance_button.text = "ENTRAR NO PÁTIO" if _line_index == INTRO_LINES.size() - 1 else "CONTINUAR"
	return beat

func _append_beat_action(tween: Tween, beat: int) -> void:
	match beat:
		1:
			tween.tween_callback(func() -> void: _player.frame = 3)
			tween.tween_interval(0.13)
			tween.tween_callback(func() -> void:
				_package.visible = false
				_player.frame = 5
			)
			tween.tween_interval(0.08)
		2:
			tween.tween_callback(func() -> void:
				_guide.frame = 3
				_player.frame = 6
			)
			tween.tween_property(_guide, "position:y", 216.0, 0.12)
			tween.tween_callback(func() -> void: _guide.frame = 4)
			tween.tween_property(_guide, "position:y", 220.0, 0.14)
		3:
			tween.tween_callback(func() -> void: _guide.frame = 5)
		4:
			tween.tween_callback(func() -> void: _guide.frame = 5)
			tween.tween_property(_guide, "position:x", 249.0, 0.14)
			tween.tween_property(_guide, "position:x", 244.0, 0.12)

func _set_speaker_tint(speaker: String) -> void:
	var tint: Color = Color("#f3b562")
	match speaker:
		"Você":
			tint = Color("#c8e5e6")
	_speaker_label.add_theme_color_override("font_color", tint)

func _unlock_line() -> void:
	_line_ready = true
	if _is_choice_line():
		for button in _choice_buttons:
			button.disabled = false
		_choice_buttons[0].grab_focus()
	else:
		_advance_button.disabled = false
		_advance_button.grab_focus()

func _is_choice_line() -> bool:
	return not _lobby_load_failed and _line_index >= 0 and INTRO_LINES[_line_index].has("choices")

func _choose_reply(index: int) -> void:
	if not _line_ready or _scene_change_in_progress or not _is_choice_line():
		return
	_selected_reply = index
	_show_line(_line_index + 1)

func _advance_dialogue() -> void:
	if _lobby_load_failed:
		_finish_intro()
		return
	if not _line_ready or _scene_change_in_progress or _is_choice_line():
		return
	if _line_index >= INTRO_LINES.size() - 1:
		_finish_intro()
		return
	_show_line(_line_index + 1)

func _finish_intro() -> void:
	if _scene_change_in_progress:
		return
	_scene_change_in_progress = true
	_line_ready = false
	_advance_button.disabled = true
	_skip_button.disabled = true
	_status_label.visible = false
	if _scene_tween != null and _scene_tween.is_running():
		_scene_tween.kill()
	var tree: SceneTree = get_tree()
	var change_error: Error = tree.change_scene_to_file(LOBBY_PATH)
	if change_error == OK:
		tree.set_meta(SESSION_INTRO_META, true)
		return
	_scene_change_in_progress = false
	_lobby_load_failed = true
	_line_ready = true
	_status_label.text = "Não foi possível abrir o pátio. Tente continuar."
	_status_label.visible = true
	_dialogue_panel.modulate.a = 1.0
	for button in _choice_buttons:
		button.hide()
	_advance_button.show()
	_skip_button.focus_previous = _skip_button.get_path_to(_advance_button)
	_skip_button.focus_next = _skip_button.get_path_to(_advance_button)
	_input_hint.text = "ESPAÇO / ENTER"
	_dialogue_label.show()
	_advance_button.text = "TENTAR DE NOVO"
	_advance_button.disabled = false
	_advance_button.grab_focus()
	_skip_button.disabled = false

func _style_button(button: Button, primary: bool) -> void:
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_font_size_override("font_size", 9 if primary else 8)
	button.add_theme_color_override("font_color", Color("#f5e5c7"))
	button.add_theme_color_override("font_hover_color", Color("#fff0c9"))
	button.add_theme_color_override("font_pressed_color", Color("#f0b35b"))
	button.add_theme_color_override("font_disabled_color", Color("#829397"))
	var normal: StyleBoxFlat = _plate("#aa763e" if primary else "#142a37", "#e6af63" if primary else "#47616b")
	var hover: StyleBoxFlat = _plate("#cf9452" if primary else "#23414c", "#f5cb89")
	var pressed: StyleBoxFlat = _plate("#976234" if primary else "#0e2330", "#f0b35b")
	var focus: StyleBoxFlat = _plate("#00000000", "#ffdfab")
	focus.draw_center = false
	focus.set_border_width_all(2)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", focus)

func _plate(fill: String, edge: String) -> StyleBoxFlat:
	var box: StyleBoxFlat = StyleBoxFlat.new()
	box.bg_color = Color(fill)
	box.border_color = Color(edge)
	box.set_border_width_all(1)
	return box
