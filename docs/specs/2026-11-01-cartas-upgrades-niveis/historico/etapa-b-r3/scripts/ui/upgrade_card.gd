class_name UpgradeCard
extends Button

const HudBitmapTextScript = preload("res://scripts/ui/hud/bitmap_text.gd")
const CARD_FONT_ATLAS_PATH: String = "res://assets/ui/upgrade_cards_v1/export/card-font-atlas.png"
const CARD_FONT_ADDITIONS_PATH: String = "res://assets/ui/upgrade_cards_v1/export/card-font-additions.json"
const FRAME_NORMAL: Texture2D = preload("res://assets/ui/upgrade_cards_v1/export/frame_normal_160x240.png")
const FRAME_FOCUS: Texture2D = preload("res://assets/ui/upgrade_cards_v1/export/frame_focus_160x240.png")
const FRAME_PRESSED: Texture2D = preload("res://assets/ui/upgrade_cards_v1/export/frame_pressed_160x240.png")

@onready var _frame: TextureRect = $Frame
@onready var _illustration: TextureRect = $Illustration
@onready var _title: HudBitmapText = $Title
@onready var _summary: HudBitmapText = $Summary
@onready var _topic_lines: Array[HudBitmapText] = [
	$Topic0 as HudBitmapText,
	$Topic1 as HudBitmapText,
	$Topic2 as HudBitmapText,
]
@onready var _badge: HudBitmapText = $Badge

var _hovered: bool = false
var _pressed_visual: bool = false

static var _cached_card_font_bundle: Dictionary = {}

func _ready() -> void:
	flat = true
	focus_mode = Control.FOCUS_ALL
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)
	button_down.connect(_on_button_down)
	button_up.connect(_on_button_up)
	_apply_frame_state()

static func load_card_font_bundle() -> Dictionary:
	if bool(_cached_card_font_bundle.get("valid", false)):
		return _cached_card_font_bundle.duplicate(true)
	var bundle: Dictionary = HudBitmapTextScript.load_font_bundle()
	if not bool(bundle.get("valid", false)):
		return bundle
	var atlas: Texture2D = ResourceLoader.load(CARD_FONT_ATLAS_PATH) as Texture2D
	var additions_json: JSON = ResourceLoader.load(CARD_FONT_ADDITIONS_PATH) as JSON
	var additions_data: Variant = additions_json.data if additions_json != null else null
	if atlas == null or typeof(additions_data) != TYPE_DICTIONARY:
		return {"valid": false, "reason": "atlas local ou adições da fonte de cartas inválidos"}
	var additions: Dictionary = additions_data
	var glyphs: Dictionary = bundle.get("glyphs", {})
	var raw_glyphs: Variant = additions.get("glyphs", [])
	if typeof(raw_glyphs) != TYPE_ARRAY:
		return {"valid": false, "reason": "lista de glifos locais inválida"}
	for glyph_variant: Variant in raw_glyphs:
		if typeof(glyph_variant) != TYPE_DICTIONARY:
			continue
		var glyph_data: Dictionary = glyph_variant
		var character: String = String(glyph_data.get("character", ""))
		var rect_variant: Variant = glyph_data.get("rect", null)
		if character.is_empty() or typeof(rect_variant) != TYPE_DICTIONARY:
			continue
		var rect_data: Dictionary = rect_variant
		var glyph_rect := Rect2i(
			int(rect_data.get("x", -1)),
			int(rect_data.get("y", -1)),
			int(rect_data.get("w", 0)),
			int(rect_data.get("h", 0))
		)
		if glyph_rect.position.x < 0 or glyph_rect.position.y < 0 \
			or glyph_rect.size.x <= 0 or glyph_rect.size.y <= 0 \
			or glyph_rect.end.x > atlas.get_width() or glyph_rect.end.y > atlas.get_height():
			continue
		glyphs[character] = {
			"rect": glyph_rect,
			"advance": maxi(int(glyph_data.get("advance", 6)), 1),
		}
	bundle["atlas"] = atlas
	bundle["glyphs"] = glyphs
	_cached_card_font_bundle = bundle.duplicate(true)
	return _cached_card_font_bundle.duplicate(true)

func configure(row: Dictionary, font_bundle: Dictionary) -> bool:
	if not bool(font_bundle.get("valid", false)):
		return false
	var definition: UpgradeDefinitionResource = row.get("definition") as UpgradeDefinitionResource
	if definition == null:
		return false
	var illustration: Texture2D = row.get("icon", definition.icon) as Texture2D
	if illustration == null:
		return false
	if not _configure_text(_title, String(row.get("title", definition.title)), font_bundle, 1):
		return false
	var summary_lines := _wrap_text(String(row.get("effect_summary", "")).replace(";", "/"), 24, 2)
	if summary_lines.size() != 1 and summary_lines.size() != 2:
		return false
	if not _configure_text(_summary, "\n".join(PackedStringArray(summary_lines)), font_bundle, 2):
		return false
	var topic_lines: Array[String] = []
	var topics_variant: Variant = row.get("topics", definition.effect_topics)
	if typeof(topics_variant) == TYPE_PACKED_STRING_ARRAY or typeof(topics_variant) == TYPE_ARRAY:
		for topic_variant: Variant in topics_variant:
			var wrapped_topic := _wrap_text("- " + String(topic_variant), 24, 3)
			for line: String in wrapped_topic:
				topic_lines.append(line)
	if topic_lines.size() < 2 or topic_lines.size() > _topic_lines.size():
		return false
	for index in range(_topic_lines.size()):
		var line := topic_lines[index] if index < topic_lines.size() else ""
		if not _configure_text(_topic_lines[index], line, font_bundle, 1):
			return false
	if not _configure_text(_badge, String(row.get("rank_label", "")), font_bundle, 1):
		return false
	_illustration.texture = illustration
	_illustration.show()
	return true

func _configure_text(control: HudBitmapText, value: String, font_bundle: Dictionary, lines: int) -> bool:
	if control == null or not control.configure_font(font_bundle):
		return false
	control.max_lines = lines
	control.set_text(value)
	return true

func _wrap_text(value: String, maximum_characters: int, maximum_lines: int) -> Array[String]:
	var result: Array[String] = []
	var current := ""
	for word: String in value.replace("\n", " ").split(" ", false):
		if word.length() > maximum_characters:
			return []
		var candidate := word if current.is_empty() else current + " " + word
		if candidate.length() <= maximum_characters:
			current = candidate
			continue
		result.append(current)
		current = word
		if result.size() >= maximum_lines:
			return []
	if not current.is_empty():
		result.append(current)
	if result.size() > maximum_lines:
		return []
	return result

func _on_mouse_entered() -> void:
	_hovered = true
	_apply_frame_state()

func _on_mouse_exited() -> void:
	_hovered = false
	_apply_frame_state()

func _on_focus_entered() -> void:
	_apply_frame_state()

func _on_focus_exited() -> void:
	_apply_frame_state()

func _on_button_down() -> void:
	_pressed_visual = true
	_apply_frame_state()

func _on_button_up() -> void:
	_pressed_visual = false
	_apply_frame_state()

func _apply_frame_state() -> void:
	if _frame == null:
		return
	if _pressed_visual:
		_frame.texture = FRAME_PRESSED
	elif _hovered or has_focus():
		_frame.texture = FRAME_FOCUS
	else:
		_frame.texture = FRAME_NORMAL
