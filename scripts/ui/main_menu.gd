extends Control

const LOBBY_PATH := "res://scenes/lobby.tscn"
const INTRO_PATH := "res://scenes/narrative/intro_cutscene.tscn"
const SESSION_INTRO_META: StringName = &"intro_completed_this_session"
const BitmapText = preload("res://scripts/ui/hud/bitmap_text.gd")
const DESIGN_SIZE := Vector2(576, 324)

@onready var _stage: Control = $Stage
var _menu: VBoxContainer
var _exit_prompt: VBoxContainer
var _play_button: Button
var _settings_button: Button
var _exit_button: Button
var _cancel_button: Button
var _status: Label
var _font_bundle: Dictionary
var _starting: bool = false

func _ready() -> void:
	_font_bundle = BitmapText.load_font_bundle()

	_menu = _make_action_list()
	_play_button = _make_button(_menu, "JOGAR", _play, true)
	_settings_button = _make_button(_menu, "CONFIGURAÇÕES", _open_settings)
	_exit_button = _make_button(_menu, "SAIR", _show_exit_prompt)
	_link_vertical([_play_button, _settings_button, _exit_button])

	_exit_prompt = _make_action_list()
	var prompt := _make_label("Fechar o jogo?", Color("#f3dbac"), 14)
	_exit_prompt.add_child(prompt)
	var quit_button := _make_button(_exit_prompt, "CONFIRMAR SAÍDA", _quit)
	_cancel_button = _make_button(_exit_prompt, "VOLTAR", _hide_exit_prompt, true)
	_link_vertical([quit_button, _cancel_button])
	_exit_prompt.hide()

	_status = _make_label("", Color("#ffb178"), 12)
	_status.position = Vector2(36, 276)
	_stage.add_child(_status)
	resized.connect(_layout)
	_layout()
	_play_button.grab_focus()

func _layout() -> void:
	var fit := minf(size.x / DESIGN_SIZE.x, size.y / DESIGN_SIZE.y)
	if fit <= 0.0:
		return
	_stage.scale = Vector2.ONE * fit
	_stage.position = ((size - DESIGN_SIZE * fit) * 0.5).floor()

func _make_action_list() -> VBoxContainer:
	var list := VBoxContainer.new()
	list.position = Vector2(36, 156)
	list.size.x = 188
	list.add_theme_constant_override("separation", 6)
	list.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_stage.add_child(list)
	return list

func _make_label(text: String, tint: Color, font_size: int) -> Label:
	var label := Label.new()
	label.text = text
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.add_theme_color_override("font_color", tint)
	label.add_theme_font_size_override("font_size", font_size)
	return label

func _make_button(list: VBoxContainer, text: String, action: Callable, primary: bool = false) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(188, 30)
	button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
	button.add_theme_stylebox_override("normal", _plate("#aa763e" if primary else "#142a37", "#e6af63" if primary else "#47616b"))
	button.add_theme_stylebox_override("hover", _plate("#cf9452" if primary else "#23414c", "#f5cb89"))
	button.add_theme_stylebox_override("pressed", _plate("#976234" if primary else "#0e2330", "#f0b35b"))
	var focus := _plate("#00000000", "#ffdfab")
	focus.draw_center = false
	focus.set_border_width_all(2)
	button.add_theme_stylebox_override("focus", focus)
	list.add_child(button)
	var glyphs := BitmapText.new() as HudBitmapText
	glyphs.text = text
	glyphs.font_color = Color("#121b22") if primary else Color("#f5e5c7")
	glyphs.position = Vector2(12, 7)
	glyphs.size = Vector2(110, 12)
	glyphs.scale = Vector2(1.5, 1.5)
	glyphs.mouse_filter = Control.MOUSE_FILTER_IGNORE
	button.add_child(glyphs)
	if glyphs.configure_font(_font_bundle):
		for color_name: String in ["font_color", "font_hover_color", "font_hover_pressed_color", "font_pressed_color", "font_focus_color", "font_disabled_color"]:
			button.add_theme_color_override(color_name, Color.TRANSPARENT)
	button.pressed.connect(action)
	return button

func _plate(fill: String, edge: String) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(fill)
	box.border_color = Color(edge)
	box.set_border_width_all(1)
	return box

func _link_vertical(buttons: Array[Button]) -> void:
	for index in buttons.size():
		var button := buttons[index]
		var previous := button.get_path_to(buttons[posmod(index - 1, buttons.size())])
		var next := button.get_path_to(buttons[(index + 1) % buttons.size()])
		button.focus_neighbor_top = previous
		button.focus_neighbor_bottom = next
		button.focus_previous = previous
		button.focus_next = next

func _play() -> void:
	if _starting:
		return
	_starting = true
	var tree := get_tree()
	if not tree.has_meta(SESSION_INTRO_META) and tree.change_scene_to_file(INTRO_PATH) == OK:
		return
	if tree.change_scene_to_file(LOBBY_PATH) != OK:
		_starting = false
		_status.text = "Não foi possível abrir o pátio."

func _open_settings() -> void:
	PauseMenu.open_title_settings()

func restore_menu_focus() -> void:
	if is_instance_valid(_settings_button):
		_settings_button.grab_focus()

func _show_exit_prompt() -> void:
	_menu.hide()
	_exit_prompt.show()
	_cancel_button.grab_focus()

func _hide_exit_prompt() -> void:
	_exit_prompt.hide()
	_menu.show()
	_exit_button.grab_focus()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed(&"ui_cancel") and _exit_prompt.visible:
		get_viewport().set_input_as_handled()
		_hide_exit_prompt()

func _quit() -> void:
	get_tree().quit()
