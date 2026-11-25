extends Node2D

const WorkshopSave = preload("res://scripts/progression/workshop_save.gd")
const IRIS_POSITION := Vector2(349, 560)
const IRIS_TEXTURE = preload("res://assets/narrative/iris_workshop/iris-workshop.png")
const IRIS_PORTRAIT = preload("res://assets/narrative/iris_workshop/iris-portrait.png")

var _iris: Sprite2D
var _idle_time: float = 0.0
var _overlay: CanvasLayer
var _content: VBoxContainer
var _prompt: Label
var _owned_pause := false
var _message := ""

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_iris = Sprite2D.new()
	_iris.name = "Iris"
	_iris.position = IRIS_POSITION
	_iris.centered = false
	_iris.offset = Vector2(-32, -58)
	_iris.scale = Vector2.ONE * 1.65
	_iris.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_iris.texture = IRIS_TEXTURE
	_iris.hframes = 4
	add_child(_iris)
	_prompt = Label.new()
	_prompt.position = Vector2(291, 443)
	_prompt.text = "E  OFICINA DE ÍRIS"
	_prompt.add_theme_color_override("font_color", Color("#F4E7C7"))
	_prompt.add_theme_font_size_override("font_size", 15)
	_prompt.add_theme_color_override("font_shadow_color", Color("#06121D"))
	_prompt.add_theme_constant_override("shadow_offset_x", 2)
	_prompt.add_theme_constant_override("shadow_offset_y", 2)
	_prompt.hide()
	add_child(_prompt)

func _process(delta: float) -> void:
	_idle_time = fmod(_idle_time + delta, 4.0)
	if _idle_time >= 3.55:
		_iris.frame = 3
	elif _idle_time >= 2.9 and _idle_time < 3.05:
		_iris.frame = 2
	else:
		_iris.frame = 1 if _idle_time >= 1.2 and _idle_time < 1.65 else 0

func update_near(player: CharacterBody2D, available: bool) -> void:
	_prompt.visible = available and is_instance_valid(player) and player.is_on_floor() and player.global_position.distance_to(IRIS_POSITION) < 90.0
	if _prompt.visible:
		_iris.flip_h = player.global_position.x < IRIS_POSITION.x

func can_open() -> bool:
	return _prompt.visible and not is_open() and not get_tree().paused

func is_open() -> bool:
	return is_instance_valid(_overlay)

func open_workshop() -> void:
	if not can_open():
		return
	_owned_pause = not get_tree().paused
	if _owned_pause:
		get_tree().paused = true
	_prompt.hide()
	WorkshopSave.save_pending_rewards(get_tree())
	_overlay = CanvasLayer.new()
	_overlay.layer = 80
	_overlay.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(_overlay)
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.02, 0.04, 0.06, 0.86)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	_overlay.add_child(backdrop)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size.x = clampf(get_viewport_rect().size.x - 48.0, 300.0, 580.0)
	var style := StyleBoxFlat.new()
	style.bg_color = Color("#0C1B29")
	style.border_color = Color("#D2A75C")
	style.set_border_width_all(3)
	style.content_margin_left = 26
	style.content_margin_right = 26
	style.content_margin_top = 20
	style.content_margin_bottom = 20
	panel.add_theme_stylebox_override("panel", style)
	center.add_child(panel)
	_content = VBoxContainer.new()
	_content.add_theme_constant_override("separation", 12)
	panel.add_child(_content)
	_rebuild()

func _input(event: InputEvent) -> void:
	if is_open() and event is InputEventKey and event.pressed and not event.echo and event.keycode == KEY_ESCAPE:
		get_viewport().set_input_as_handled()
		call_deferred("close_workshop")

func close_workshop() -> void:
	if not is_open():
		return
	_overlay.queue_free()
	_overlay = null
	if _owned_pause:
		get_tree().paused = false
	_owned_pause = false

func _label(text: String, size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", size)
	label.add_theme_color_override("font_color", color)
	label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	return label

func _rebuild(preferred_key: String = "") -> void:
	for child in _content.get_children():
		_content.remove_child(child)
		child.queue_free()
	var title_row := HBoxContainer.new()
	title_row.add_theme_constant_override("separation", 16)
	_content.add_child(title_row)
	var portrait := TextureRect.new()
	portrait.texture = IRIS_PORTRAIT
	portrait.custom_minimum_size = Vector2(96, 96)
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	title_row.add_child(portrait)
	var heading := VBoxContainer.new()
	heading.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.alignment = BoxContainer.ALIGNMENT_CENTER
	title_row.add_child(heading)
	heading.add_child(_label("Oficina de Íris", 28, Color("#D2A75C")))
	heading.add_child(_label("Melhorias permanentes para as próximas subidas.", 16, Color("#B6BEC3")))
	var preferred_button: Button
	var pending := WorkshopSave.pending_marks(get_tree())
	if pending > 0:
		_content.add_child(_label("%d marcas pendentes nesta sessão." % pending, 16, Color("#E86B69")))
	var state := WorkshopSave.read_state()
	if not bool(state.get("valid", false)):
		_content.add_child(_label("Não foi possível ler o progresso da oficina. O arquivo foi preservado.", 18, Color("#E86B69")))
	else:
		_content.add_child(_label("Marcas da Oficina: %d" % int(state.marks), 21, Color("#E8D8B5")))
		var health_button := _add_upgrade(state, "health", "Reforço de estrutura", "+1 de vida inicial e máxima por nível")
		var scrap_button := _add_upgrade(state, "scrap", "Bolsa de sucata", "+2 de sucata inicial por nível")
		if preferred_key == "health":
			preferred_button = health_button
		elif preferred_key == "scrap":
			preferred_button = scrap_button
	if not _message.is_empty():
		_content.add_child(_label(_message, 17, Color("#E86B69")))
	var close := Button.new()
	close.text = "FECHAR  [ESC]"
	close.custom_minimum_size.y = 40
	close.pressed.connect(close_workshop)
	_content.add_child(close)
	if is_instance_valid(preferred_button) and not preferred_button.disabled:
		preferred_button.grab_focus()
	else:
		close.grab_focus()

func _add_upgrade(state: Dictionary, key: String, title: String, effect: String) -> Button:
	var rank: int = state[key]
	var row := VBoxContainer.new()
	_content.add_child(row)
	row.add_child(_label("%s   ·   Nível %d/%d" % [title, rank, WorkshopSave.MAX_RANK], 20, Color("#E8D8B5")))
	row.add_child(_label(effect, 16, Color("#B6BEC3")))
	var button := Button.new()
	var price := WorkshopSave.price_for(rank)
	button.text = "MÁXIMO" if rank >= WorkshopSave.MAX_RANK else "COMPRAR — %d MARCAS" % price
	button.disabled = rank >= WorkshopSave.MAX_RANK or int(state.marks) < price
	button.custom_minimum_size.y = 38
	button.pressed.connect(_buy.bind(key))
	row.add_child(button)
	return button

func _buy(key: String) -> void:
	_message = "" if WorkshopSave.buy(key) else "Não foi possível salvar a compra. Tente novamente."
	_rebuild(key)
