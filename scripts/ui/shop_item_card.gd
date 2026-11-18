class_name ShopItemCard
extends UpgradeCard

const ShopItemCatalogScript = preload("res://scripts/progression/shop_item_catalog.gd")
const ELEMENT_ICON_DIR := "res://assets/ui/upgrade_cards_v1/export/"
const CUSTOM_ITEM_ICON_DIRECTORY: String = "res://assets/shop/items/"

@onready var _rarity_chip: ColorRect = $RarityChip
@onready var _rarity_label: HudBitmapText = $RarityLabel

func configure_item(row: Dictionary, font_bundle: Dictionary) -> bool:
	if not bool(font_bundle.get("valid", false)):
		return false
	var item_id: StringName = StringName(row.get("item_id", &""))
	var rank_before: Variant = row.get("rank_before", -1)
	var rank_after: Variant = row.get("rank_after", -1)
	var rank_max: Variant = row.get("rank_max", -1)
	var rarity: Variant = row.get("rarity", -1)
	if (
		not ShopItemCatalogScript.is_known_item_id(item_id)
		or typeof(rank_before) != TYPE_INT or typeof(rank_after) != TYPE_INT
		or typeof(rank_max) != TYPE_INT or typeof(rarity) != TYPE_INT
		or int(rank_before) < 0 or int(rank_after) != int(rank_before) + 1
		or int(rank_max) != ShopItemCatalogScript.max_level_for(item_id)
		or int(rank_after) > int(rank_max) or int(rarity) != ShopItemCatalogScript.rarity_for(item_id)
	):
		return false
	if not _configure_text(_title, String(row.get("title", "")), font_bundle, 1):
		return false
	var summary_lines := _wrap_text(String(row.get("description", "")), 24, 2)
	if summary_lines.is_empty() or summary_lines.size() > 2:
		return false
	if not _configure_text(_summary, "\n".join(PackedStringArray(summary_lines)), font_bundle, 2):
		return false
	var topics_variant: Variant = row.get("topics", [])
	if typeof(topics_variant) != TYPE_ARRAY and typeof(topics_variant) != TYPE_PACKED_STRING_ARRAY:
		return false
	var topic_lines: Array[Dictionary] = []
	for topic in topics_variant:
		topic_lines.append_array(_wrap_topic(String(topic)))
	if topic_lines.is_empty() or topic_lines.size() > 3:
		return false
	for index in range(3):
		var value := ""
		var colors: Array[Color] = []
		if index < topic_lines.size():
			value = String(topic_lines[index].get("text", ""))
			for color_variant in topic_lines[index].get("colors", []):
				if color_variant is Color:
					colors.append(color_variant)
		if not _configure_topic_text(_topic_lines[index], value, colors, font_bundle):
			return false
	var level_before := int(rank_before)
	var level_after := int(rank_after)
	var maximum_level := int(rank_max)
	if (
		not _configure_rank_status("NOVO" if level_before == 0 else "EVOLUIR", false, font_bundle)
		or not _configure_rank_counter(level_before, level_after, maximum_level, &"item", font_bundle)
		or not _rank_prisms.configure_rank(level_before, level_after, maximum_level, &"item")
	):
		return false
	var rarity_color: Color = row.get("rarity_color", ShopItemCatalogScript.rarity_color(int(rarity)))
	if _rarity_label == null or not _rarity_label.configure_font(font_bundle):
		return false
	_rarity_chip.color = rarity_color
	_rarity_label.font_color = rarity_color
	_rarity_label.max_lines = 1
	_rarity_label.set_text("%s / %s" % [ShopItemCatalogScript.rarity_label(int(rarity)), String(row.get("family", ""))])
	_illustration.texture = _build_item_icon(item_id)
	_illustration.show()
	return true

func _build_item_icon(item_id: StringName) -> Texture2D:
	if item_id == &"camara_termica":
		return load(ELEMENT_ICON_DIR + "bola_incandescente_128x80.png") as Texture2D
	if item_id == &"nucleo_indutor":
		return load(ELEMENT_ICON_DIR + "bola_magnetica_128x80.png") as Texture2D
	var custom_icon_path := _custom_item_icon_path(item_id)
	if not custom_icon_path.is_empty() and ResourceLoader.exists(custom_icon_path):
		var custom_icon := load(custom_icon_path) as Texture2D
		if custom_icon != null:
			return custom_icon
	var image := Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color(0, 0, 0, 0))
	match item_id:
		&"bolsa_magnetica":
			_draw_block(image, 6, 7, 5, 16, Color("#D2A75C"))
			_draw_block(image, 21, 7, 5, 16, Color("#D2A75C"))
			_draw_block(image, 6, 18, 20, 5, Color("#D2A75C"))
			_draw_block(image, 6, 4, 5, 5, Color("#E86B69"))
			_draw_block(image, 21, 4, 5, 5, Color("#E86B69"))
			_draw_block(image, 11, 7, 3, 9, Color("#E8D8B5"))
		&"mola_salto":
			_draw_block(image, 6, 24, 20, 4, Color("#59636B"))
			_draw_block(image, 9, 20, 6, 4, Color("#D2A75C"))
			_draw_block(image, 16, 16, 6, 4, Color("#D2A75C"))
			_draw_block(image, 9, 12, 6, 4, Color("#D2A75C"))
			_draw_block(image, 16, 8, 6, 4, Color("#D2A75C"))
			_draw_block(image, 11, 4, 10, 4, Color("#52BAC7"))
		&"punho_guarda":
			_draw_block(image, 9, 4, 14, 5, Color("#52BAC7"))
			_draw_block(image, 5, 9, 22, 10, Color("#52BAC7"))
			_draw_block(image, 8, 19, 16, 5, Color("#52BAC7"))
			_draw_block(image, 12, 24, 8, 4, Color("#52BAC7"))
			_draw_block(image, 12, 9, 8, 10, Color("#142C40"))
		&"kit_remendo":
			_draw_block(image, 6, 6, 20, 20, Color("#59636B"))
			_draw_block(image, 9, 9, 14, 14, Color("#E8D8B5"))
			_draw_block(image, 14, 10, 4, 12, Color("#E86B69"))
			_draw_block(image, 10, 14, 12, 4, Color("#E86B69"))
		&"fusivel_aegis":
			_draw_block(image, 9, 4, 14, 5, Color("#52BAC7"))
			_draw_block(image, 5, 9, 22, 10, Color("#52BAC7"))
			_draw_block(image, 8, 19, 16, 5, Color("#52BAC7"))
			_draw_block(image, 12, 24, 8, 4, Color("#52BAC7"))
			_draw_block(image, 14, 8, 4, 13, Color("#D2A75C"))
			_draw_block(image, 12, 12, 8, 4, Color("#E86B69"))
	return ImageTexture.create_from_image(image)

func _custom_item_icon_path(item_id: StringName) -> String:
	match item_id:
		&"catraca_sucata", &"rolamento_livre", &"turbina_centrifuga", &"bobina_ritmo", &"fusivel_emergencia":
			return CUSTOM_ITEM_ICON_DIRECTORY + String(item_id) + ".png"
	return ""

func _draw_block(image: Image, x: int, y: int, width: int, height: int, color: Color) -> void:
	for py in range(y, y + height):
		for px in range(x, x + width):
			image.set_pixel(px, py, color)
