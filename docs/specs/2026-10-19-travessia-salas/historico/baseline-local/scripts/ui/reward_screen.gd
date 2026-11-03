extends CanvasLayer

signal reward_chosen(reward_name: String)

var _resolved: bool = false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	var backdrop := ColorRect.new()
	backdrop.color = Color(0.03, 0.05, 0.09, 0.92)
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(backdrop)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.add_child(center)

	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(820, 360)
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color("#101c2c")
	panel_style.border_color = Color("#f0b35b")
	panel_style.set_border_width_all(2)
	panel_style.set_corner_radius_all(12)
	panel_style.content_margin_left = 26
	panel_style.content_margin_right = 26
	panel_style.content_margin_top = 22
	panel_style.content_margin_bottom = 22
	panel.add_theme_stylebox_override("panel", panel_style)
	center.add_child(panel)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 18)
	panel.add_child(content)

	var title := Label.new()
	title.text = "CHEFE DERROTADO"
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 30)
	title.add_theme_color_override("font_color", Color("#f0b35b"))
	content.add_child(title)

	var subtitle := Label.new()
	subtitle.text = "Escolha uma recompensa para continuar"
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	subtitle.add_theme_font_size_override("font_size", 18)
	content.add_child(subtitle)

	var cards := HBoxContainer.new()
	cards.add_theme_constant_override("separation", 14)
	content.add_child(cards)

	var rewards := [
		{"name": "Núcleo de impacto", "description": "Dano da bolinha +25%"},
		{"name": "Propulsor", "description": "Velocidade da bolinha +15%"},
		{"name": "Esfera ampliada", "description": "Raio de colisão da bolinha +15%"},
	]
	for reward in rewards:
		var card := Button.new()
		card.text = "%s\n\n%s" % [reward["name"], reward["description"]]
		card.custom_minimum_size = Vector2(235, 170)
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.add_theme_font_size_override("font_size", 18)
		card.add_theme_color_override("font_color", Color("#f3eadb"))

		var normal := StyleBoxFlat.new()
		normal.bg_color = Color("#243447")
		normal.border_color = Color("#60758a")
		normal.set_border_width_all(1)
		normal.set_corner_radius_all(10)
		normal.content_margin_left = 14
		normal.content_margin_right = 14
		normal.content_margin_top = 14
		normal.content_margin_bottom = 14
		card.add_theme_stylebox_override("normal", normal)

		var hover := StyleBoxFlat.new()
		hover.bg_color = Color("#354b60")
		hover.border_color = Color("#f0b35b")
		hover.set_border_width_all(2)
		hover.set_corner_radius_all(10)
		card.add_theme_stylebox_override("hover", hover)
		card.pressed.connect(_choose_reward.bind(reward["name"]))
		cards.add_child(card)


func _choose_reward(reward_name: String) -> void:
	if _resolved:
		return
	_resolved = true
	reward_chosen.emit(reward_name)


func cancel_offer() -> void:
	if _resolved:
		return
	_resolved = true
	reward_chosen.emit("")
