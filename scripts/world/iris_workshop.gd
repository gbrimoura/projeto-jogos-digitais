extends Node2D

const WorkshopSave = preload("res://scripts/progression/workshop_save.gd")
const IRIS_POSITION := Vector2(349, 560)
const IRIS_TEXTURE = preload("res://assets/narrative/iris_workshop/iris-workshop.png")
const IRIS_PORTRAIT = preload("res://assets/narrative/iris_workshop/iris-portrait.png")

var _iris: Sprite2D
var _idle_time: float = 0.0
var _overlay: CanvasLayer
var _content: VBoxContainer
var _prompt: PanelContainer
var _owned_pause := false
var _message := ""
var _dialogue_response := ""

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

	_prompt = PanelContainer.new()
	_prompt.name = "WorkshopPrompt"
	_prompt.position = Vector2(278, 426)
	_prompt.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var plate := StyleBoxFlat.new()
	plate.bg_color = Color(0.047, 0.071, 0.086, 0.94)
	plate.border_color = Color("#746E56")
	plate.set_border_width_all(1)
	plate.content_margin_left = 8.0
	plate.content_margin_right = 8.0
	plate.content_margin_top = 4.0
	plate.content_margin_bottom = 4.0
	_prompt.add_theme_stylebox_override("panel", plate)
	add_child(_prompt)

	var prompt_row := HBoxContainer.new()
	prompt_row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	prompt_row.add_theme_constant_override("separation", 6)
	_prompt.add_child(prompt_row)

	var keycap := PanelContainer.new()
	keycap.custom_minimum_size = Vector2(22.0, 22.0)
	keycap.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var keycap_style := StyleBoxFlat.new()
	keycap_style.bg_color = Color("#1C2C31")
	keycap_style.border_color = Color("#8C805F")
	keycap_style.set_border_width_all(1)
	keycap_style.content_margin_left = 4.0
	keycap_style.content_margin_right = 4.0
	keycap_style.content_margin_top = 1.0
	keycap_style.content_margin_bottom = 1.0
	keycap.add_theme_stylebox_override("panel", keycap_style)
	var keycap_label := Label.new()
	keycap_label.text = "E"
	keycap_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	keycap_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	keycap_label.add_theme_font_size_override("font_size", 13)
	keycap_label.add_theme_color_override("font_color", Color("#D2B778"))
	keycap_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	keycap.add_child(keycap_label)
	prompt_row.add_child(keycap)

	var prompt_action := Label.new()
	prompt_action.text = "FALAR COM ÍRIS"
	prompt_action.add_theme_font_size_override("font_size", 12)
	prompt_action.add_theme_color_override("font_color", Color("#D1C5A5"))
	prompt_action.mouse_filter = Control.MOUSE_FILTER_IGNORE
	prompt_row.add_child(prompt_action)
	_prompt.hide()


func _process(delta: float) -> void:
	_idle_time = fmod(_idle_time + delta, 4.0)
	if _idle_time >= 3.55:
		_iris.frame = 3
	elif _idle_time >= 2.9 and _idle_time < 3.05:
		_iris.frame = 2
	else:
		_iris.frame = 1 if _idle_time >= 1.2 and _idle_time < 1.65 else 0

func update_near(player: CharacterBody2D, available: bool) -> void:
	_prompt.visible = available and is_instance_valid(player) and player.is_on_floor() and player.global_position.distance_to(IRIS_POSITION) < 90.0 and not is_open() and not get_tree().paused
	if _prompt.visible:
		_iris.flip_h = player.global_position.x < IRIS_POSITION.x

func can_open() -> bool:
	return _prompt.visible and not is_open() and not get_tree().paused

func is_open() -> bool:
	return is_instance_valid(_overlay)

func open_workshop() -> void:
	if not can_open():
		return
	_message = ""
	_dialogue_response = ""
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
	var preferred_button: Button
	var pending := WorkshopSave.pending_marks(get_tree())
	var state := WorkshopSave.read_state()
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
	heading.add_theme_constant_override("separation", 4)
	title_row.add_child(heading)
	heading.add_child(_label("Oficina de Íris", 25, Color("#D2A75C")))
	var dialogue_text := _dialogue_response if not _dialogue_response.is_empty() else _opening_dialogue(state, pending)
	var dialogue_color := Color("#B6BEC3")
	if not bool(state.get("valid", false)):
		dialogue_color = Color("#D69A8F")
	if not _message.is_empty():
		dialogue_text = _message
		dialogue_color = Color("#D69A8F")
	var dialogue := _label(dialogue_text, 15, dialogue_color)
	dialogue.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	heading.add_child(dialogue)

	if pending > 0:
		_content.add_child(_label("%d marcas pendentes nesta sessão." % pending, 16, Color("#E86B69")))
	if bool(state.get("valid", false)):
		_content.add_child(_label("Marcas da Oficina: %d" % int(state.marks), 21, Color("#E8D8B5")))
		var health_button := _add_upgrade(state, "health", "Reforço de estrutura", "+1 de vida inicial e máxima por nível")
		var scrap_button := _add_upgrade(state, "scrap", "Bolsa de sucata", "+2 de sucata inicial por nível")
		if preferred_key == "health":
			preferred_button = health_button
		elif preferred_key == "scrap":
			preferred_button = scrap_button

	var close := Button.new()
	close.text = "FECHAR  [ESC]"
	close.custom_minimum_size.y = 40
	close.pressed.connect(close_workshop)
	_content.add_child(close)
	if is_instance_valid(preferred_button) and not preferred_button.disabled:
		preferred_button.grab_focus()
	else:
		close.grab_focus()

func _opening_dialogue(state: Dictionary, pending: int) -> String:
	if not bool(state.get("valid", false)):
		return "Oi, Ampère. Não consigo ler o progresso da oficina. Não posso confirmar compras agora."
	if pending > 0:
		return "Oi, Ampère. Há marcas pendentes nesta sessão. O saldo abaixo mostra o que já foi salvo."
	var marks: int = int(state.get("marks", 0))
	var health_rank: int = int(state.get("health", 0))
	var scrap_rank: int = int(state.get("scrap", 0))
	var both_maxed: bool = health_rank >= WorkshopSave.MAX_RANK and scrap_rank >= WorkshopSave.MAX_RANK
	if both_maxed:
		return "Oi, Ampère! Os dois reforços já chegaram ao máximo. Obrigada por confiar em mim."
	var has_available_upgrade: bool = (
		(health_rank < WorkshopSave.MAX_RANK and marks >= WorkshopSave.price_for(health_rank))
		or (scrap_rank < WorkshopSave.MAX_RANK and marks >= WorkshopSave.price_for(scrap_rank))
	)
	if has_available_upgrade:
		return "Oi, Ampère! Separei alguns reforços para sua próxima subida."
	if marks == 0:
		return "Oi, Ampère! Traga marcas da torre e eu preparo um reforço."
	return "Ainda faltam marcas para esses reforços. Traga mais da torre e voltamos a conversar."

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
	var purchase_confirmed: bool = WorkshopSave.buy(key)
	if purchase_confirmed:
		_message = ""
		if key == "health":
			_dialogue_response = "Concluído, Ampère. Reforcei sua estrutura. Você terá +1 PV inicial e máximo na próxima subida."
		else:
			_dialogue_response = "Concluído, Ampère. Preparei +2 de sucata inicial para a próxima subida."
	else:
		_message = "Não consegui confirmar a compra. Tente outra vez, Ampère."
		_dialogue_response = ""
	_rebuild(key)
