class_name HudBitmapText
extends Control

const FONT_METADATA_PATH: String = "res://assets/ui/hud_caldeira_v1/export/font.json"
const FONT_ATLAS_PATH: String = "res://assets/ui/hud_caldeira_v1/export/font-atlas.png"

@export var text: String = "":
	set(value):
		if text == value:
			return
		text = value
		queue_redraw()
@export var font_color: Color = Color("E8D8B5"):
	set(value):
		if font_color == value:
			return
		font_color = value
		queue_redraw()
@export_range(1, 4, 1) var max_lines: int = 1
@export var center_text: bool = false
@export var right_align: bool = false

var _font_atlas: Texture2D
var _glyphs: Dictionary = {}
var _advance: int = 6
var _line_height: int = 12
var _warned_missing_glyph: bool = false

static func load_font_bundle() -> Dictionary:
	if not ResourceLoader.exists(FONT_METADATA_PATH) or not ResourceLoader.exists(FONT_ATLAS_PATH):
		return {"valid": false, "reason": "fonte bitmap do HUD ausente"}
	var metadata_resource: Resource = ResourceLoader.load(FONT_METADATA_PATH)
	var atlas_resource: Resource = ResourceLoader.load(FONT_ATLAS_PATH)
	var metadata_json: JSON = metadata_resource as JSON
	var font_atlas: Texture2D = atlas_resource as Texture2D
	if metadata_json == null or font_atlas == null:
		return {"valid": false, "reason": "metadados ou atlas da fonte bitmap inválidos"}
	var raw_data: Variant = metadata_json.data
	if typeof(raw_data) != TYPE_DICTIONARY:
		return {"valid": false, "reason": "font.json não contém um objeto"}
	var font_data: Dictionary = raw_data as Dictionary
	var raw_glyphs: Variant = font_data.get("glyphs", null)
	if typeof(raw_glyphs) != TYPE_ARRAY:
		return {"valid": false, "reason": "font.json não contém a lista de glifos"}
	var glyphs: Dictionary = {}
	var glyph_list: Array = raw_glyphs as Array
	for glyph_variant: Variant in glyph_list:
		if typeof(glyph_variant) != TYPE_DICTIONARY:
			continue
		var glyph_data: Dictionary = glyph_variant as Dictionary
		var codepoint: int = int(glyph_data.get("codepoint", -1))
		var rect_variant: Variant = glyph_data.get("rect", null)
		if codepoint < 0 or typeof(rect_variant) != TYPE_DICTIONARY:
			continue
		var rect_data: Dictionary = rect_variant as Dictionary
		var glyph_rect: Rect2i = Rect2i(
			int(rect_data.get("x", -1)),
			int(rect_data.get("y", -1)),
			int(rect_data.get("w", 0)),
			int(rect_data.get("h", 0))
		)
		if glyph_rect.position.x < 0 or glyph_rect.position.y < 0 \
			or glyph_rect.size.x <= 0 or glyph_rect.size.y <= 0 \
			or glyph_rect.end.x > font_atlas.get_width() \
			or glyph_rect.end.y > font_atlas.get_height():
			continue
		glyphs[String.chr(codepoint)] = {
			"rect": glyph_rect,
			"advance": maxi(int(glyph_data.get("advance", 0)), 1),
		}
	var advance: int = int(font_data.get("advance", 0))
	var line_height: int = int(font_data.get("line_height", 0))
	if glyphs.is_empty() or advance <= 0 or line_height <= 0 or not glyphs.has(" "):
		return {"valid": false, "reason": "métricas incompletas da fonte bitmap"}
	return {"valid": true, "atlas": font_atlas, "glyphs": glyphs, "advance": advance, "line_height": line_height}

func configure_font(bundle: Dictionary) -> bool:
	if not bool(bundle.get("valid", false)):
		return false
	_font_atlas = bundle.get("atlas") as Texture2D
	_glyphs = bundle.get("glyphs", {}) as Dictionary
	_advance = int(bundle.get("advance", 6))
	_line_height = int(bundle.get("line_height", 12))
	var configured: bool = _font_atlas != null and not _glyphs.is_empty() and _advance > 0 and _line_height > 0
	visible = configured
	queue_redraw()
	return configured

func set_text(value: String) -> void:
	text = value

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if _font_atlas == null:
		configure_font(load_font_bundle())

func _draw() -> void:
	if _font_atlas == null or _glyphs.is_empty() or _advance <= 0 or _line_height <= 0:
		return
	var lines: Array[String] = _make_lines()
	for line_index: int in range(lines.size()):
		var line: String = lines[line_index]
		var line_width: int = line.length() * _advance
		var line_x: float = 0.0
		if center_text:
			line_x = floorf((size.x - float(line_width)) * 0.5)
		elif right_align:
			line_x = floorf(size.x - float(line_width))
		for char_index: int in range(line.length()):
			var character: String = line.substr(char_index, 1)
			var glyph_variant: Variant = _glyphs.get(character, null)
			if glyph_variant == null:
				if not _warned_missing_glyph:
					push_warning("Fonte bitmap do HUD sem glifo para: %s" % character)
					_warned_missing_glyph = true
				glyph_variant = _glyphs.get(" ", {})
			if typeof(glyph_variant) != TYPE_DICTIONARY:
				continue
			var glyph_data: Dictionary = glyph_variant as Dictionary
			var source_rect: Rect2i = glyph_data.get("rect", Rect2i())
			var source: Rect2 = Rect2(Vector2(source_rect.position), Vector2(source_rect.size))
			var destination: Rect2 = Rect2(
				Vector2(line_x + float(char_index * _advance), float(line_index * _line_height)),
				Vector2(source_rect.size)
			)
			draw_texture_rect_region(_font_atlas, destination, source, font_color)

func _make_lines() -> Array[String]:
	var result: Array[String] = []
	var max_chars: int = int(floor(size.x / float(_advance)))
	if max_chars <= 0:
		return result
	var source_lines: PackedStringArray = text.replace("—", "-").replace("–", "-").split("\n")
	for source_line: String in source_lines:
		var line: String = _normalize_line(source_line)
		if line.length() > max_chars:
			line = line.substr(0, max_chars)
			if max_chars > 1 and not line.ends_with("-"):
				line = line.substr(0, max_chars - 1) + "-"
		result.append(line)
		if result.size() >= max_lines:
			break
	return result

func _normalize_line(value: String) -> String:
	var normalized: String = ""
	for index: int in range(value.length()):
		var character: String = value.substr(index, 1)
		var prior_character: String = value.substr(index - 1, 1) if index > 0 else ""
		if character == "s" and prior_character >= "0" and prior_character <= "9":
			normalized += "s"
		else:
			normalized += character.to_upper()
	return normalized