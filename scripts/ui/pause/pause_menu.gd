extends CanvasLayer

const SETTINGS_PATH := "user://selenite_settings.cfg"
const SIZES := [Vector2i(1280, 720), Vector2i(1600, 900), Vector2i(1920, 1080)]
const BitmapText = preload("res://scripts/ui/hud/bitmap_text.gd")

class PauseArrowKey extends Control:
	var direction: Vector2i = Vector2i.UP

	func _ready() -> void:
		custom_minimum_size = Vector2(24, 28)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	func _draw() -> void:
		draw_rect(Rect2(Vector2(1, 1), size - Vector2(2, 2)), Color("#172a33"))
		draw_rect(Rect2(Vector2(1, 1), size - Vector2(2, 2)), Color("#829397"), false, 1.0)
		var arrow_color := Color("#e8d8b5")
		match direction:
			Vector2i.UP:
				draw_rect(Rect2(Vector2(10, 12), Vector2(4, 10)), arrow_color)
				draw_colored_polygon(PackedVector2Array([Vector2(12, 5), Vector2(5, 14), Vector2(9, 14), Vector2(9, 17), Vector2(15, 17), Vector2(15, 14), Vector2(19, 14)]), arrow_color)
			Vector2i.DOWN:
				draw_rect(Rect2(Vector2(10, 6), Vector2(4, 10)), arrow_color)
				draw_colored_polygon(PackedVector2Array([Vector2(9, 11), Vector2(15, 11), Vector2(15, 14), Vector2(19, 14), Vector2(12, 23), Vector2(5, 14), Vector2(9, 14)]), arrow_color)
			Vector2i.LEFT:
				draw_rect(Rect2(Vector2(12, 11), Vector2(9, 5)), arrow_color)
				draw_colored_polygon(PackedVector2Array([Vector2(5, 13), Vector2(13, 6), Vector2(13, 10), Vector2(17, 10), Vector2(17, 16), Vector2(13, 16), Vector2(13, 20)]), arrow_color)
			Vector2i.RIGHT:
				draw_rect(Rect2(Vector2(4, 11), Vector2(9, 5)), arrow_color)
				draw_colored_polygon(PackedVector2Array([Vector2(19, 13), Vector2(11, 6), Vector2(11, 10), Vector2(7, 10), Vector2(7, 16), Vector2(11, 16), Vector2(11, 20)]), arrow_color)


class PauseMouseKey extends Control:
	var active_button: int = -1

	func _ready() -> void:
		custom_minimum_size = Vector2(28, 34)
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	func _draw() -> void:
		draw_rect(Rect2(Vector2(4, 1), Vector2(20, 31)), Color("#b1884d"))
		draw_rect(Rect2(Vector2(5, 2), Vector2(18, 29)), Color("#172a33"))
		var left_color := Color("#3a5058")
		var right_color := Color("#3a5058")
		if active_button == 0:
			left_color = Color("#d2a75c")
		elif active_button == 1:
			right_color = Color("#d2a75c")
		draw_rect(Rect2(Vector2(6, 3), Vector2(7, 11)), left_color)
		draw_rect(Rect2(Vector2(15, 3), Vector2(7, 11)), right_color)
		draw_rect(Rect2(Vector2(13, 3), Vector2(2, 11)), Color("#829397"))
		draw_rect(Rect2(Vector2(12, 7), Vector2(4, 5)), Color("#e8d8b5"))
		draw_rect(Rect2(Vector2(7, 17), Vector2(14, 12)), Color("#203740"))


class PauseRouteMap extends Control:
	const BitmapTextScript = preload("res://scripts/ui/hud/bitmap_text.gd")

	var _map_data: Dictionary = {}
	var _font_bundle: Dictionary = {}

	func _ready() -> void:
		mouse_filter = Control.MOUSE_FILTER_IGNORE
		texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		_font_bundle = BitmapTextScript.load_font_bundle()

	func configure(map_data: Dictionary) -> void:
		_map_data = map_data.duplicate(true)
		queue_redraw()

	func _notification(what: int) -> void:
		if what == NOTIFICATION_RESIZED:
			queue_redraw()

	func _draw() -> void:
		draw_rect(Rect2(Vector2.ZERO, size), Color("#0b1b23"))
		draw_rect(Rect2(Vector2.ZERO, size), Color("#405962"), false, 2.0)
		var raw_rooms: Variant = _map_data.get("rooms", [])
		if typeof(raw_rooms) != TYPE_ARRAY:
			return
		var room_descriptors: Array = raw_rooms
		var current_stage: int = maxi(int(_map_data.get("current_stage", _map_data.get("current_room", 1))), 1)
		var visible_count := mini(current_stage, room_descriptors.size())
		if visible_count <= 0:
			return
		var coordinates: Array[Vector2i] = []
		for index in range(visible_count):
			var descriptor_variant: Variant = room_descriptors[index]
			if typeof(descriptor_variant) != TYPE_DICTIONARY:
				return
			var descriptor: Dictionary = descriptor_variant
			var coordinate_variant: Variant = descriptor.get("coord", null)
			if typeof(coordinate_variant) != TYPE_VECTOR2I:
				return
			coordinates.append(coordinate_variant)
		var horizontal_sign := 1
		for index in range(1, coordinates.size()):
			if coordinates[index].x != coordinates[index - 1].x:
				horizontal_sign = 1 if coordinates[index].x > coordinates[index - 1].x else -1
				break
		var minimum_x := 0
		var maximum_x := 0
		var minimum_y := 0
		var maximum_y := 0
		for coordinate in coordinates:
			var progress_x := coordinate.x * horizontal_sign
			minimum_x = mini(minimum_x, progress_x)
			maximum_x = maxi(maximum_x, progress_x)
			minimum_y = mini(minimum_y, coordinate.y)
			maximum_y = maxi(maximum_y, coordinate.y)
		var span_x := maxi(maximum_x - minimum_x, 1)
		var span_y := maxi(maximum_y - minimum_y, 1)
		var step_x := minf(34.0, maxf(12.0, (size.x - 46.0) / float(span_x)))
		var step_y := minf(40.0, maxf(18.0, (size.y - 46.0) / float(span_y)))
		var room_size := Vector2(minf(22.0, step_x * 0.82), minf(20.0, step_y * 0.82))
		var route_size := Vector2(float(span_x) * step_x, float(span_y) * step_y)
		var origin := (size - route_size - room_size) * 0.5 + room_size * 0.5
		var points: Array[Vector2] = []
		for coordinate in coordinates:
			var progress_x := coordinate.x * horizontal_sign
			points.append(origin + Vector2(float(progress_x - minimum_x) * step_x, float(coordinate.y - minimum_y) * step_y))
		for index in range(points.size() - 1):
			draw_line(points[index], points[index + 1], Color("#5b9c98"), 3.0, false)
		var combat_number: int = 0
		for index in range(points.size()):
			var descriptor: Dictionary = room_descriptors[index]
			var room_kind := StringName(descriptor.get("room_kind", &"combat"))
			var is_shop := room_kind == &"shop"
			var is_boss := room_kind == &"boss"
			if not is_shop:
				combat_number += 1
			var fill_color := Color("#397b78")
			var border_color := Color("#76c9cf")
			if is_shop:
				fill_color = Color("#654727")
				border_color = Color("#d2a75c")
			elif is_boss:
				fill_color = Color("#594323")
				border_color = Color("#f4d59c")
			if index == visible_count - 1:
				fill_color = Color("#d2a75c")
				border_color = Color("#fff0ca")
			var rectangle := Rect2(points[index] - room_size * 0.5, room_size)
			draw_rect(rectangle, fill_color)
			draw_rect(rectangle, border_color, false, 2.0)
			var marker := "L" if is_shop else ("B" if is_boss else str(combat_number))
			_draw_room_number(marker, points[index], border_color)
	func _draw_room_number(value: String, center: Vector2, color: Color) -> void:
		if not bool(_font_bundle.get("valid", false)):
			return
		var atlas := _font_bundle.get("atlas") as Texture2D
		var glyphs := _font_bundle.get("glyphs", {}) as Dictionary
		var advance := int(_font_bundle.get("advance", 6))
		var line_height := int(_font_bundle.get("line_height", 12))
		if atlas == null or glyphs.is_empty() or advance <= 0 or line_height <= 0:
			return
		var text_width := value.length() * advance
		var start := center - Vector2(float(text_width) * 0.5, float(line_height) * 0.5)
		for index in range(value.length()):
			var character := value.substr(index, 1)
			var glyph_variant: Variant = glyphs.get(character, null)
			if typeof(glyph_variant) != TYPE_DICTIONARY:
				continue
			var glyph_data: Dictionary = glyph_variant
			var source_rect: Rect2i = glyph_data.get("rect", Rect2i())
			var source := Rect2(Vector2(source_rect.position), Vector2(source_rect.size))
			var destination := Rect2(start + Vector2(float(index * advance), 0), Vector2(source_rect.size))
			draw_texture_rect_region(atlas, destination, source, color)

var _open := false
var _page := "controls"
var _confirmation := ""
var _root: ColorRect
var _body: VBoxContainer
var _first_button: Button
var _notice := ""
var _fullscreen := true
var _pixel := false
var _vsync := true
var _size_index := 2
var _volume := 100
var _muted := false
var _focus_setting := 1
var _native_scale_size: Vector2i
var _native_scale_mode: int

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 300
	_native_scale_size = get_window().content_scale_size
	_native_scale_mode = get_window().content_scale_mode
	_load_settings()
	_apply_settings()

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		var key := event as InputEventKey
		if key.keycode == KEY_ESCAPE and key.pressed:
			if key.echo:
				if _open:
					get_viewport().set_input_as_handled()
				return
			if _open:
				get_viewport().set_input_as_handled()
				if not _confirmation.is_empty():
					_confirmation = ""
					_rebuild()
				elif _page != "controls":
					_page = "controls"
					_rebuild()
				else:
					call_deferred("_resume")
			elif not get_tree().paused:
				var scene := get_tree().current_scene
				if scene != null and scene.has_method("is_pause_menu_available") and bool(scene.call("is_pause_menu_available")):
					get_viewport().set_input_as_handled()
					_open_menu()

func _open_menu() -> void:
	if _open or get_tree().paused:
		return
	_open = true
	_page = "controls"
	_confirmation = ""
	_notice = ""
	get_tree().paused = true
	_rebuild()

func _resume() -> void:
	if not _open:
		return
	_open = false
	if is_instance_valid(_root):
		_root.queue_free()
	_root = null
	for action in [&"move_left", &"move_right", &"jump", &"dash", &"launch_ball", &"parry", &"interact"]:
		Input.action_release(action)
	get_tree().paused = false

func _style(bg: String, border: String, margin: int = 10) -> StyleBoxFlat:
	var box := StyleBoxFlat.new()
	box.bg_color = Color(bg)
	box.border_color = Color(border)
	box.set_border_width_all(2)
	box.content_margin_left = margin
	box.content_margin_right = margin
	box.content_margin_top = margin
	box.content_margin_bottom = margin
	return box

func _label(parent: Node, text: String, size: int = 19, color: String = "#e8d8b5") -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", Color(color))
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	parent.add_child(label)
	return label

func _bitmap_line(parent: Node, text: String, color: String = "#e8d8b5", minimum_width: float = 0.0) -> Control:
	var line := Control.new()
	line.custom_minimum_size = Vector2(maxf(minimum_width, float(text.length() * 12)), 24)
	line.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(line)
	var glyphs := BitmapText.new()
	glyphs.text = text
	glyphs.font_color = Color(color)
	glyphs.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glyphs.size = Vector2(float(text.length() * 6), 12)
	glyphs.scale = Vector2(2, 2)
	line.add_child(glyphs)
	return line

func _small_bitmap_text(parent: Node, text: String, color: String = "#e8d8b5") -> HudBitmapText:
	var glyphs := BitmapText.new()
	glyphs.text = text
	glyphs.font_color = Color(color)
	glyphs.size = Vector2(float(text.length() * 6), 12)
	glyphs.custom_minimum_size = glyphs.size
	glyphs.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	glyphs.mouse_filter = Control.MOUSE_FILTER_IGNORE
	parent.add_child(glyphs)
	return glyphs

func _keycap(parent: Node, text: String) -> void:
	var cap := PanelContainer.new()
	cap.custom_minimum_size = Vector2(maxf(22.0, float(text.length() * 6 + 8)), 28)
	cap.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	cap.add_theme_stylebox_override("panel", _style("#172a33", "#829397", 3))
	parent.add_child(cap)
	var center := CenterContainer.new()
	cap.add_child(center)
	var glyphs := _small_bitmap_text(center, text)
	glyphs.size = Vector2(float(text.length() * 6), 12)

func _binding_token(parent: Node, token: String) -> void:
	if token == "MOUSE" or token == "MOUSE_LEFT" or token == "MOUSE_RIGHT":
		var mouse := PauseMouseKey.new()
		mouse.active_button = 0 if token == "MOUSE_LEFT" else (1 if token == "MOUSE_RIGHT" else -1)
		parent.add_child(mouse)
		return
	if token.begins_with("ARROW_"):
		var direction_keys := {
			"ARROW_UP": Vector2i.UP,
			"ARROW_DOWN": Vector2i.DOWN,
			"ARROW_LEFT": Vector2i.LEFT,
			"ARROW_RIGHT": Vector2i.RIGHT,
		}
		var arrow := PauseArrowKey.new()
		arrow.direction = direction_keys.get(token, Vector2i.UP)
		parent.add_child(arrow)
		return
	_keycap(parent, token)

func _control_card(parent: Node, action: String, bindings: Array[String]) -> void:
	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(0, 56)
	card.add_theme_stylebox_override("panel", _style("#142832", "#405962", 6))
	parent.add_child(card)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation", 4)
	card.add_child(stack)
	_small_bitmap_text(stack, action, "#d2a75c")
	var tokens := HBoxContainer.new()
	tokens.add_theme_constant_override("separation", 3)
	stack.add_child(tokens)
	for binding in bindings:
		_binding_token(tokens, binding)

func _map_legend_item(parent: Node, label: String, color: String) -> void:
	var item := HBoxContainer.new()
	item.add_theme_constant_override("separation", 4)
	parent.add_child(item)
	var swatch := ColorRect.new()
	swatch.color = Color(color)
	swatch.custom_minimum_size = Vector2(10, 10)
	swatch.size = Vector2(10, 10)
	swatch.mouse_filter = Control.MOUSE_FILTER_IGNORE
	item.add_child(swatch)
	_small_bitmap_text(item, label, "#c4d0cd")

func _get_minimap_data() -> Dictionary:
	var scene := get_tree().current_scene
	if scene == null or not scene.has_method("get_pause_minimap_data"):
		return {}
	var value: Variant = scene.call("get_pause_minimap_data")
	if typeof(value) != TYPE_DICTIONARY:
		return {}
	return value

func _build_controls() -> void:
	_bitmap_line(_body, "CONTROLES", "#d2a75c")
	var map_data := _get_minimap_data()
	var has_map := not map_data.is_empty()
	var columns := HBoxContainer.new()
	columns.add_theme_constant_override("separation", 10)
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_body.add_child(columns)

	var controls := VBoxContainer.new()
	controls.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	controls.size_flags_vertical = Control.SIZE_EXPAND_FILL
	controls.add_theme_constant_override("separation", 8)
	if has_map:
		controls.custom_minimum_size.x = 344
	columns.add_child(controls)

	var grid := GridContainer.new()
	grid.columns = 2 if has_map else 3
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 7)
	grid.add_theme_constant_override("v_separation", 6)
	controls.add_child(grid)
	_control_card(grid, "MOVIMENTO", ["A", "D", "ARROW_LEFT", "ARROW_RIGHT"])
	_control_card(grid, "PULAR", ["ESPAÇO", "W", "ARROW_UP"])
	_control_card(grid, "DASH", ["SHIFT"])
	_control_card(grid, "MIRAR", ["MOUSE"])
	_control_card(grid, "DISPARAR", ["MOUSE_LEFT"])
	_control_card(grid, "REBATER", ["MOUSE_RIGHT"])
	_control_card(grid, "INTERAGIR", ["E"])
	_control_card(grid, "NAVEGAR", ["TAB", "ARROW_UP", "ARROW_DOWN", "ENTER"])
	_control_card(grid, "VOLTAR AO JOGO", ["ESC"])
	var return_hint := HBoxContainer.new()
	return_hint.add_theme_constant_override("separation", 6)
	controls.add_child(return_hint)
	_keycap(return_hint, "R")
	var return_hint_label := _label(return_hint, "Voltar no resultado ou reiniciar o treino.", 14, "#a8bbc0")
	return_hint_label.custom_minimum_size.x = 96
	return_hint_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_label(controls, "Portas da torre e elevador são automáticos.", 14, "#a8bbc0")

	if has_map:
		_build_minimap(columns, map_data)

func _build_minimap(parent: Node, map_data: Dictionary) -> void:
	var panel := PanelContainer.new()
	panel.custom_minimum_size.x = 242
	panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	panel.add_theme_stylebox_override("panel", _style("#10232d", "#567780", 8))
	parent.add_child(panel)
	var layout := VBoxContainer.new()
	layout.add_theme_constant_override("separation", 7)
	panel.add_child(layout)
	_bitmap_line(layout, "ROTA VISITADA", "#d2a75c", 0.0)
	var floor_index := int(map_data.get("floor", 1))
	var floor_count := int(map_data.get("floor_count", 1))
	_bitmap_line(layout, "ANDAR %02d / %02d" % [floor_index, floor_count], "#e8d8b5")
	var current_kind := StringName(map_data.get("current_room_kind", &"combat"))
	if current_kind == &"shop":
		_bitmap_line(layout, "ETAPA ATUAL: LOJA", "#d2a75c")
	elif current_kind == &"boss":
		_bitmap_line(layout, "ETAPA ATUAL: CHEFE", "#d2a75c")
	else:
		_bitmap_line(layout, "SALA ATUAL %02d / %02d" % [int(map_data.get("current_room", 1)), int(map_data.get("common_rooms", 10))], "#78b5b9")
	var route_map := PauseRouteMap.new()
	route_map.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	route_map.size_flags_vertical = Control.SIZE_EXPAND_FILL
	route_map.custom_minimum_size = Vector2(210, 250)
	layout.add_child(route_map)
	route_map.configure(map_data)
	var legend := HBoxContainer.new()
	legend.add_theme_constant_override("separation", 12)
	layout.add_child(legend)
	_map_legend_item(legend, "PASSOU", "#397b78")
	_map_legend_item(legend, "ATUAL", "#d2a75c")
	_map_legend_item(legend, "LOJA", "#d2a75c")
	_map_legend_item(legend, "CHEFE", "#f4d59c")

func _button(parent: Node, text: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size = Vector2(0, 42)
	button.focus_mode = Control.FOCUS_ALL
	button.add_theme_font_size_override("font_size", 18)
	button.add_theme_color_override("font_color", Color.TRANSPARENT)
	button.add_theme_color_override("font_hover_color", Color.TRANSPARENT)
	button.add_theme_color_override("font_pressed_color", Color.TRANSPARENT)
	button.add_theme_color_override("font_focus_color", Color.TRANSPARENT)
	button.add_theme_color_override("font_disabled_color", Color.TRANSPARENT)
	button.add_theme_stylebox_override("normal", _style("#1b3541", "#516f77", 7))
	button.add_theme_stylebox_override("hover", _style("#314349", "#d2a75c", 7))
	button.add_theme_stylebox_override("pressed", _style("#102a36", "#f4d59c", 7))
	var focus := _style("#00000000", "#76c9cf", 0)
	focus.draw_center = false
	button.add_theme_stylebox_override("focus", focus)
	parent.add_child(button)
	var display_text := text.replace("×", "X").replace("—", "-").replace("(", "").replace(")", "").replace("?", "")
	var glyphs := BitmapText.new()
	glyphs.text = display_text
	glyphs.mouse_filter = Control.MOUSE_FILTER_IGNORE
	glyphs.scale = Vector2(2, 2)
	glyphs.set_anchors_preset(Control.PRESET_CENTER)
	glyphs.offset_left = -float(display_text.length() * 6)
	glyphs.offset_top = -12
	glyphs.offset_right = glyphs.offset_left + float(display_text.length() * 6)
	glyphs.offset_bottom = 0
	button.add_child(glyphs)
	button.custom_minimum_size.x = float(display_text.length() * 12 + 24)
	button.pressed.connect(action)
	return button

func _set_vertical_focus(container: Container) -> void:
	var buttons: Array[Button] = []
	for child in container.get_children():
		if child is Button and not child.disabled:
			buttons.append(child)
	for i in range(buttons.size()):
		buttons[i].focus_neighbor_top = buttons[i].get_path_to(buttons[(i + buttons.size() - 1) % buttons.size()])
		buttons[i].focus_neighbor_bottom = buttons[i].get_path_to(buttons[(i + 1) % buttons.size()])

func _rebuild() -> void:
	if is_instance_valid(_root):
		remove_child(_root)
		_root.queue_free()
	_root = ColorRect.new()
	_root.color = Color(0.015, 0.025, 0.035, 0.86)
	_root.mouse_filter = Control.MOUSE_FILTER_STOP
	add_child(_root)
	_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	_root.add_child(center)
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(960, 545)
	panel.add_theme_stylebox_override("panel", _style("#101f28", "#b1884d", 16))
	center.add_child(panel)
	var vertical := VBoxContainer.new()
	vertical.add_theme_constant_override("separation", 10)
	panel.add_child(vertical)
	var header := HBoxContainer.new()
	vertical.add_child(header)
	var title := Control.new()
	title.custom_minimum_size = Vector2(420, 32)
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	header.add_child(title)
	var bitmap := BitmapText.new()
	bitmap.text = "JOGO PAUSADO"
	bitmap.scale = Vector2(2, 2)
	bitmap.size = Vector2(250, 12)
	title.add_child(bitmap)
	_label(header, "ESC  /  VOLTAR", 16, "#78b5b9").autowrap_mode = TextServer.AUTOWRAP_OFF
	var columns := HBoxContainer.new()
	columns.size_flags_vertical = Control.SIZE_EXPAND_FILL
	columns.add_theme_constant_override("separation", 14)
	vertical.add_child(columns)
	var left_panel := PanelContainer.new()
	left_panel.custom_minimum_size.x = 264
	left_panel.add_theme_stylebox_override("panel", _style("#182d36", "#4b6267", 12))
	columns.add_child(left_panel)
	var menu := VBoxContainer.new()
	menu.add_theme_constant_override("separation", 10)
	left_panel.add_child(menu)
	_bitmap_line(menu, "PAINEL DE CALDEIRA", "#d2a75c")
	_first_button = _button(menu, "RETOMAR JOGO", func(): call_deferred("_resume"))
	var controls_button := _button(menu, "CONTROLES", func(): _page = "controls"; _confirmation = ""; _rebuild())
	var settings_button := _button(menu, "CONFIGURAÇÕES", func(): _page = "settings"; _confirmation = ""; _rebuild())
	var exit_button := _button(menu, "SAIR DO JOGO", func(): _confirmation = "exit"; _rebuild())
	if not _confirmation.is_empty():
		_first_button.disabled = true
		controls_button.disabled = true
		settings_button.disabled = true
		exit_button.disabled = true
	var right_panel := PanelContainer.new()
	right_panel.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	right_panel.add_theme_stylebox_override("panel", _style("#112630", "#567780", 16))
	columns.add_child(right_panel)
	_body = VBoxContainer.new()
	_body.add_theme_constant_override("separation", 7)
	right_panel.add_child(_body)
	if not _confirmation.is_empty():
		_build_confirmation()
	elif _page == "settings":
		_build_settings()
	else:
		_build_controls()
	_set_vertical_focus(menu)
	_set_vertical_focus(_body)
	if not _notice.is_empty():
		_label(vertical, _notice, 15, "#e8b765")
	if _confirmation.is_empty():
		if _page == "settings" and _focus_setting < _body.get_child_count():
			_body.get_child(_focus_setting).call_deferred("grab_focus")
		else:
			_first_button.call_deferred("grab_focus")


func _build_settings() -> void:
	_bitmap_line(_body, "CONFIGURAÇÕES", "#d2a75c")
	_button(_body, "TELA: " + ("TELA CHEIA" if _fullscreen else "JANELA"), func(): _fullscreen = not _fullscreen; _focus_setting = 1; _change_settings(true))
	_button(_body, "JANELA: %d × %d" % [SIZES[_size_index].x, SIZES[_size_index].y], func(): _size_index = (_size_index + 1) % SIZES.size(); _focus_setting = 2; _change_settings(not _fullscreen))
	_label(_body, "A resolução escolhida vale em janela; tela cheia usa o monitor.", 14, "#a8bbc0")
	_button(_body, "QUALIDADE: " + ("PIXEL (ESCALA INTERNA)" if _pixel else "NATIVA"), func(): _pixel = not _pixel; _focus_setting = 4; _change_settings())
	_button(_body, "VSYNC: " + ("LIGADO" if _vsync else "DESLIGADO"), func(): _vsync = not _vsync; _focus_setting = 5; _change_settings())
	_button(_body, "VOLUME GERAL: %d%%" % _volume, func(): _volume = (_volume + 10) % 110; _focus_setting = 6; _change_settings())
	_button(_body, "ÁUDIO: " + ("MUDO" if _muted else "LIGADO"), func(): _muted = not _muted; _focus_setting = 7; _change_settings())
	var future_save := _button(_body, "LIMPAR SAVE — INDISPONÍVEL", func(): pass)
	future_save.disabled = true
	_label(_body, "Progresso permanente ainda não disponível.", 14, "#a8bbc0")

func _build_confirmation() -> void:
	_bitmap_line(_body, "SAIR DO JOGO", "#e8b765")
	_label(_body, "A tentativa ativa será perdida. Deseja fechar o jogo?", 20)
	var cancel := _button(_body, "CANCELAR", func(): _confirmation = ""; _rebuild())
	_button(_body, "CONFIRMAR SAÍDA", func(): get_tree().quit())
	cancel.call_deferred("grab_focus")

func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) != OK:
		return
	var v: Variant = cfg.get_value("video", "fullscreen", true)
	if typeof(v) == TYPE_BOOL: _fullscreen = v
	v = cfg.get_value("video", "pixel", false)
	if typeof(v) == TYPE_BOOL: _pixel = v
	v = cfg.get_value("video", "vsync", true)
	if typeof(v) == TYPE_BOOL: _vsync = v
	v = cfg.get_value("video", "size_index", 2)
	if typeof(v) == TYPE_INT and v >= 0 and v < SIZES.size(): _size_index = v
	v = cfg.get_value("audio", "volume", 100)
	if typeof(v) == TYPE_INT and v >= 0 and v <= 100: _volume = v
	v = cfg.get_value("audio", "muted", false)
	if typeof(v) == TYPE_BOOL: _muted = v

func _change_settings(update_window: bool = false) -> void:
	_apply_settings(update_window)
	var cfg := ConfigFile.new()
	cfg.set_value("video", "fullscreen", _fullscreen)
	cfg.set_value("video", "pixel", _pixel)
	cfg.set_value("video", "vsync", _vsync)
	cfg.set_value("video", "size_index", _size_index)
	cfg.set_value("audio", "volume", _volume)
	cfg.set_value("audio", "muted", _muted)
	_notice = "Ajustes salvos." if cfg.save(SETTINGS_PATH) == OK else "Não foi possível salvar os ajustes."
	_rebuild()

func _apply_settings(update_window: bool = true) -> void:
	var window := get_window()
	window.content_scale_size = Vector2i(1152, 648) if _pixel else _native_scale_size
	window.content_scale_mode = Window.CONTENT_SCALE_MODE_VIEWPORT if _pixel else _native_scale_mode
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if _vsync else DisplayServer.VSYNC_DISABLED)
	if update_window:
		if _fullscreen:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		else:
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
			var usable := DisplayServer.screen_get_usable_rect(DisplayServer.window_get_current_screen())
			var requested: Vector2i = SIZES[_size_index]
			var factor := minf(1.0, minf(float(usable.size.x) / requested.x, float(usable.size.y) / requested.y))
			var actual := Vector2i(maxi(1, int(requested.x * factor)), maxi(1, int(requested.y * factor)))
			DisplayServer.window_set_size(actual)
			DisplayServer.window_set_position(usable.position + (usable.size - actual) / 2)
	var bus := AudioServer.get_bus_index("Master")
	if bus >= 0:
		AudioServer.set_bus_volume_db(bus, linear_to_db(maxf(float(_volume) / 100.0, 0.0001)))
		AudioServer.set_bus_mute(bus, _muted or _volume == 0)
