class_name UpgradeCard
extends Button

const HudBitmapTextScript = preload("res://scripts/ui/hud/bitmap_text.gd")
const UpgradeStatTextScript = preload("res://scripts/ui/upgrade_stat_text.gd")
const CARD_FONT_ATLAS_PATH: String = "res://assets/ui/upgrade_cards_v1/export/card-font-atlas.png"
const CARD_FONT_ADDITIONS_PATH: String = "res://assets/ui/upgrade_cards_v1/export/card-font-additions.json"
const FRAME_NORMAL: Texture2D = preload("res://assets/ui/upgrade_cards_v1/export/frame_normal_160x240.png")
const FRAME_FOCUS: Texture2D = preload("res://assets/ui/upgrade_cards_v1/export/frame_focus_160x240.png")
const FRAME_PRESSED: Texture2D = preload("res://assets/ui/upgrade_cards_v1/export/frame_pressed_160x240.png")
const TOPIC_TEXT_COLOR: Color = Color("B6BEC3")
const TOPIC_DASH_COLOR: Color = Color("52BAC7")
const TOPIC_VALUE_COLOR: Color = Color("D2A75C")
const TOPIC_CONTENT_WIDTH: int = 22

@onready var _frame: TextureRect = $Frame
@onready var _illustration: TextureRect = $Illustration
@onready var _title: HudBitmapText = $Title
@onready var _summary: HudBitmapText = $Summary
@onready var _topic_lines: Array[UpgradeStatTextScript] = [
	$Topic0 as UpgradeStatTextScript,
	$Topic1 as UpgradeStatTextScript,
	$Topic2 as UpgradeStatTextScript,
]
@onready var _rank_status: UpgradeStatTextScript = $RankStatus as UpgradeStatTextScript
@onready var _rank_counter: UpgradeStatTextScript = $RankCounter as UpgradeStatTextScript

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
	var summary_text := String(row.get("description", definition.description))
	if summary_text.is_empty():
		summary_text = definition.description
	var summary_lines := _wrap_text(summary_text, 24, 2)
	if summary_lines.size() != 1 and summary_lines.size() != 2:
		return false
	if not _configure_text(_summary, "\n".join(PackedStringArray(summary_lines)), font_bundle, 2):
		return false
	var topic_lines: Array[Dictionary] = []
	var topics_variant: Variant = row.get("topics", definition.effect_topics)
	if typeof(topics_variant) == TYPE_PACKED_STRING_ARRAY or typeof(topics_variant) == TYPE_ARRAY:
		for topic_variant: Variant in topics_variant:
			var wrapped_topic := _wrap_topic(String(topic_variant))
			if wrapped_topic.is_empty():
				return false
			topic_lines.append_array(wrapped_topic)
	if topic_lines.is_empty() or topic_lines.size() > _topic_lines.size():
		return false
	for index in range(_topic_lines.size()):
		var line_text := ""
		var line_colors: Array[Color] = []
		if index < topic_lines.size():
			var line_data: Dictionary = topic_lines[index]
			line_text = String(line_data.get("text", ""))
			var colors_variant: Variant = line_data.get("colors", [])
			if typeof(colors_variant) == TYPE_ARRAY:
				for color_variant: Variant in colors_variant:
					if color_variant is Color:
						line_colors.append(color_variant)
		if not _configure_topic_text(_topic_lines[index], line_text, line_colors, font_bundle):
			return false
	var rank_before := int(row.get("rank_before", -1))
	var rank_after := int(row.get("rank_after", -1))
	var rank_max := int(row.get("rank_max", -1))
	var rank_status := String(row.get("rank_status", row.get("rank_label", "")))
	var rank_is_maximum := bool(row.get("rank_is_maximum", false))
	var reward_kind: StringName = StringName(row.get("reward_kind", definition.reward_kind))
	if rank_before < 0 or rank_after <= rank_before or rank_max < rank_after or rank_status.is_empty():
		return false
	if not _configure_rank_status(rank_status, rank_is_maximum, font_bundle):
		return false
	if not _configure_rank_counter(rank_before, rank_after, rank_max, reward_kind, font_bundle):
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

func _configure_topic_text(control: UpgradeStatTextScript, value: String, colors: Array[Color], font_bundle: Dictionary) -> bool:
	if control == null or not control.configure_font(font_bundle):
		return false
	control.max_lines = 1
	control.set_colored_text(value, colors)
	return true

func _configure_rank_status(value: String, reaches_maximum: bool, font_bundle: Dictionary) -> bool:
	var status_color := TOPIC_VALUE_COLOR if reaches_maximum else TOPIC_DASH_COLOR
	var colors: Array[Color] = []
	for _index in range(value.length()):
		colors.append(status_color)
	return _configure_footer_text(_rank_status, value, colors, font_bundle)

func _configure_rank_counter(rank_before: int, rank_after: int, rank_max: int, reward_kind: StringName, font_bundle: Dictionary) -> bool:
	if reward_kind == &"recovery":
		var recovery_text := "CURA ATÉ 1 VIDA"
		var recovery_colors: Array[Color] = []
		for _index in range(recovery_text.length()):
			recovery_colors.append(TOPIC_VALUE_COLOR)
		return _configure_footer_text(_rank_counter, recovery_text, recovery_colors, font_bundle)
	var prefix := "NÍVEL %d > " % rank_before
	var target := str(rank_after)
	var suffix := " / %d" % rank_max
	var value := prefix + target + suffix
	var colors: Array[Color] = []
	for _index in range(prefix.length()):
		colors.append(TOPIC_TEXT_COLOR)
	for _index in range(target.length()):
		colors.append(TOPIC_VALUE_COLOR)
	for _index in range(suffix.length()):
		colors.append(TOPIC_TEXT_COLOR)
	return _configure_footer_text(_rank_counter, value, colors, font_bundle)

func _configure_footer_text(control: UpgradeStatTextScript, value: String, colors: Array[Color], font_bundle: Dictionary) -> bool:
	if control == null or not control.configure_font(font_bundle):
		return false
	control.max_lines = 1
	control.set_colored_text(value, colors)
	return true
func _wrap_topic(value: String) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if value.is_empty():
		return result
	var source_colors := _topic_colors(value)
	var content := ""
	var content_colors: Array[Color] = []
	var source_offset := 0
	for word: String in value.split(" ", false):
		if word.length() > TOPIC_CONTENT_WIDTH:
			return []
		var word_start := value.find(word, source_offset)
		if word_start < 0:
			return []
		var needs_space := not content.is_empty()
		if needs_space and content.length() + 1 + word.length() > TOPIC_CONTENT_WIDTH:
			result.append(_make_topic_line(content, content_colors, result.is_empty()))
			content = word
			content_colors = []
			for color_index in range(word_start, word_start + word.length()):
				content_colors.append(source_colors[color_index])
		else:
			if needs_space:
				content += " "
				content_colors.append(TOPIC_TEXT_COLOR)
			content += word
			for color_index in range(word_start, word_start + word.length()):
				content_colors.append(source_colors[color_index])
		source_offset = word_start + word.length()
	if not content.is_empty():
		result.append(_make_topic_line(content, content_colors, result.is_empty()))
	return result

func _make_topic_line(content: String, content_colors: Array[Color], first_line: bool) -> Dictionary:
	var prefix := "- " if first_line else "  "
	var colors: Array[Color] = [TOPIC_DASH_COLOR, TOPIC_TEXT_COLOR] if first_line else [TOPIC_TEXT_COLOR, TOPIC_TEXT_COLOR]
	colors.append_array(content_colors)
	return {"text": prefix + content, "colors": colors}

func _topic_colors(value: String) -> Array[Color]:
	var colors: Array[Color] = []
	for _index in range(value.length()):
		colors.append(TOPIC_TEXT_COLOR)
	if value.begins_with("Até ") or value.begins_with("Uma vez"):
		return colors
	var number_start := -1
	var number_end := -1
	var comparison_index := value.find(">")
	var search_start := 0
	if comparison_index >= 0:
		search_start = comparison_index + 1
		while search_start < value.length() and value.substr(search_start, 1) == " ":
			search_start += 1
		if search_start < value.length():
			if _is_sign(value.substr(search_start, 1)):
				number_start = search_start
				search_start += 1
			elif _is_digit(value.substr(search_start, 1)):
				number_start = search_start
	else:
		for index in range(value.length()):
			if _is_digit(value.substr(index, 1)):
				number_start = index
				if index > 0 and _is_sign(value.substr(index - 1, 1)):
					number_start = index - 1
				search_start = index
				break
	if number_start < 0:
		return colors
	number_end = search_start
	while number_end < value.length():
		var character := value.substr(number_end, 1)
		if _is_digit(character) or character == "," or character == ".":
			number_end += 1
		else:
			break
	if number_end == search_start:
		return colors
	if number_end < value.length() and value.substr(number_end, 1).to_lower() == "s":
		number_end += 1
	for index in range(number_start, number_end):
		colors[index] = TOPIC_VALUE_COLOR
	return colors

func _is_digit(value: String) -> bool:
	return value >= "0" and value <= "9"

func _is_sign(value: String) -> bool:
	return value == "+" or value == "-"

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