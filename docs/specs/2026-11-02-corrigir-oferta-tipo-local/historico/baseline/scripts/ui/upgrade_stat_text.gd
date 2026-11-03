class_name UpgradeStatText
extends HudBitmapText

var _character_colors: Array[Color] = []

func set_colored_text(value: String, colors: Array[Color]) -> void:
	_character_colors = colors.duplicate()
	text = value
	queue_redraw()

func _draw() -> void:
	if _font_atlas == null or _glyphs.is_empty() or _advance <= 0 or _line_height <= 0:
		return
	var lines: Array[String] = _make_lines()
	var character_offset := 0
	for line_index: int in range(lines.size()):
		var line: String = lines[line_index]
		var line_x: float = 0.0
		if center_text:
			var line_width: int = line.length() * _advance
			line_x = floorf((size.x - float(line_width)) * 0.5)
		elif right_align:
			var line_width: int = line.length() * _advance
			line_x = floorf(size.x - float(line_width))
		for char_index: int in range(line.length()):
			var character: String = line.substr(char_index, 1)
			var glyph_variant: Variant = _glyphs.get(character, null)
			if glyph_variant == null:
				if not _warned_missing_glyph:
					push_warning("Fonte bitmap do HUD sem glifo para: %s" % character)
					_warned_missing_glyph = true
				glyph_variant = _glyphs.get(" ", {})
			if typeof(glyph_variant) == TYPE_DICTIONARY:
				var glyph_data: Dictionary = glyph_variant
				var source_rect: Rect2i = glyph_data.get("rect", Rect2i())
				var source := Rect2(Vector2(source_rect.position), Vector2(source_rect.size))
				var destination := Rect2(
					Vector2(line_x + float(char_index * _advance), float(line_index * _line_height)),
					Vector2(source_rect.size)
				)
				var color := font_color
				if character_offset < _character_colors.size():
					color = _character_colors[character_offset]
				draw_texture_rect_region(_font_atlas, destination, source, color)
			character_offset += 1