# Static review packet — five additional shop items

Scope is only the five additional items and their shop-card/gameplay integration. Do not edit files or run tests/Godot. Look for concrete correctness, compatibility, and balance-risk defects in this scope; ignore unrelated local changes. Return only actionable findings with file/function and severity, or state that no actionable findings were found.

Acceptance points: each item has the listed rarity/cap/effect and accurately worded card text; Catraca rewards once on a real ball return per room without double-counting Bolsa Magnetica; Rolamento affects return speed only; Turbina increases speed only on environmental rebounds, preserves accumulated speed across parries, and respects its per-shot cap; Bobina restores at most one air dash on the first airborne successful parry in a room; Fusivel triggers only on first accepted health damage (Aegis-blocked damage does not count); RunBuild accepts, validates, serializes, and restores the new IDs; the card resolves each PNG path and keeps old icons working. Values are provisional, not final balance.

## Catalog and persistence


### `scripts/progression/shop_item_catalog.gd`

```text
extends RefCounted

## Prototipo ajustavel em codigo; pesos e valores nao sao balanceamento final.
enum Rarity { COMUM, INCOMUM, RARO, EPICO, LENDARIO }

const ITEM_IDS: Array[StringName] = [
	&"bolsa_magnetica", &"mola_salto", &"punho_guarda", &"kit_remendo", &"fusivel_aegis",
	&"catraca_sucata", &"rolamento_livre", &"turbina_centrifuga", &"bobina_ritmo", &"fusivel_emergencia",
]
const RARITY_LABELS: Array[String] = ["COMUM", "INCOMUM", "RARO", "EPICO", "LENDARIO"]
const RARITY_COLORS: Array[Color] = [
	Color("#B6BEC3"), Color("#62C6A5"), Color("#52BAC7"), Color("#BD83D4"), Color("#D2A75C")
]

static func known_item_ids() -> Array[StringName]:
	return ITEM_IDS.duplicate()

static func is_known_item_id(item_id: Variant) -> bool:
	return (typeof(item_id) == TYPE_STRING or typeof(item_id) == TYPE_STRING_NAME) and ITEM_IDS.has(StringName(item_id))

static func max_level_for(item_id: StringName) -> int:
	match item_id:
		&"bolsa_magnetica": return 3
		&"mola_salto": return 1
		&"punho_guarda": return 2
		&"kit_remendo": return 3
		&"fusivel_aegis": return 1
		&"catraca_sucata": return 1
		&"rolamento_livre": return 2
		&"turbina_centrifuga": return 2
		&"bobina_ritmo": return 1
		&"fusivel_emergencia": return 1
	return 0

static func rarity_for(item_id: StringName) -> int:
	match item_id:
		&"bolsa_magnetica": return Rarity.COMUM
		&"mola_salto": return Rarity.INCOMUM
		&"punho_guarda": return Rarity.RARO
		&"kit_remendo": return Rarity.EPICO
		&"fusivel_aegis": return Rarity.LENDARIO
		&"catraca_sucata": return Rarity.COMUM
		&"rolamento_livre": return Rarity.INCOMUM
		&"turbina_centrifuga": return Rarity.RARO
		&"bobina_ritmo": return Rarity.EPICO
		&"fusivel_emergencia": return Rarity.LENDARIO
	return -1

static func rarity_label(rarity: int) -> String:
	return RARITY_LABELS[rarity] if rarity >= 0 and rarity < RARITY_LABELS.size() else ""

static func rarity_color(rarity: int) -> Color:
	return RARITY_COLORS[rarity] if rarity >= 0 and rarity < RARITY_COLORS.size() else Color.WHITE

static func display_name(item_id: StringName) -> String:
	match item_id:
		&"bolsa_magnetica": return "BOLSA MAGNETICA"
		&"mola_salto": return "MOLA DE SALTO"
		&"punho_guarda": return "PUNHO DE GUARDA"
		&"kit_remendo": return "KIT DE REMENDO"
		&"fusivel_aegis": return "FUSIVEL AEGIS"
		&"catraca_sucata": return "CATRACA SUCATA"
		&"rolamento_livre": return "ROLAMENTO LIVRE"
		&"turbina_centrifuga": return "TURBINA CENTRIFUGA"
		&"bobina_ritmo": return "BOBINA RITMO"
		&"fusivel_emergencia": return "FUSIVEL EMERGENCIA"
	return ""

static func description(item_id: StringName) -> String:
	match item_id:
		&"bolsa_magnetica": return "Imas ajudam a recolher sucata"
		&"mola_salto": return "Uma mola reserva para o ar"
		&"punho_guarda": return "Um punho reforcado para rebater"
		&"kit_remendo": return "Remendos para recuperar entre lutas"
		&"fusivel_aegis": return "Um fusivel que segura um impacto"
		&"catraca_sucata": return "A bola que volta rende sucata"
		&"rolamento_livre": return "A bola volta mais rapido"
		&"turbina_centrifuga": return "A cada rebote no cenario, a bola acelera"
		&"bobina_ritmo": return "Rebate no ar recupera dash"
		&"fusivel_emergencia": return "Dano reduz a recarga do dash"
	return ""

static func topics(item_id: StringName) -> PackedStringArray:
	match item_id:
		&"bolsa_magnetica": return PackedStringArray(["Sucata: +1 por coleta", "Limite: 3 niveis"])
		&"mola_salto": return PackedStringArray(["Dash aereo: +1", "Limite: 1 nivel"])
		&"punho_guarda": return PackedStringArray(["Arco: +8 graus", "Limite: 2 niveis"])
		&"kit_remendo": return PackedStringArray(["Cura combate: +1 HP", "Limite: 3 niveis"])
		&"fusivel_aegis": return PackedStringArray(["Bloqueia 1 dano/sala", "Limite: 1 nivel"])
		&"catraca_sucata": return PackedStringArray(["Retorno: +1 sucata", "1 vez por sala"])
		&"rolamento_livre": return PackedStringArray(["Retorno: +25%/nivel", "Maximo: +50%"])
		&"turbina_centrifuga": return PackedStringArray(["Cenario: +8%/nivel", "Maximo: +40% por tiro", "Limite: 2 niveis"])
		&"bobina_ritmo": return PackedStringArray(["Ar: parry +1 dash", "1 vez por sala"])
		&"fusivel_emergencia": return PackedStringArray(["Dano: -0.5s na recarga", "1 vez por sala", "Aegis nao conta"])
	return PackedStringArray()

static func rarity_unlock_floor(rarity: int) -> int:
	match rarity:
		Rarity.COMUM, Rarity.INCOMUM: return 1
		Rarity.RARO: return 2
		Rarity.EPICO: return 3
		Rarity.LENDARIO: return 4
	return 1073741824

static func rarity_weight(rarity: int, floor_index: int) -> int:
	match floor_index:
		1:
			match rarity:
				Rarity.COMUM: return 75
				Rarity.INCOMUM: return 25
		2:
			match rarity:
				Rarity.COMUM: return 60
				Rarity.INCOMUM: return 30
				Rarity.RARO: return 10
		3:
			match rarity:
				Rarity.COMUM: return 45
				Rarity.INCOMUM: return 30
				Rarity.RARO: return 20
				Rarity.EPICO: return 5
		_:
			match rarity:
				Rarity.COMUM: return 30
				Rarity.INCOMUM: return 27
				Rarity.RARO: return 22
				Rarity.EPICO: return 15
				Rarity.LENDARIO: return 6
	return 0

static func card_preview(item_id: StringName, current_level: int) -> Dictionary:
	if not is_known_item_id(item_id) or current_level < 0 or current_level >= max_level_for(item_id):
		return {}
	var rarity := rarity_for(item_id)
	return {
		"item_id": item_id, "title": display_name(item_id), "description": description(item_id),
		"topics": topics(item_id), "rank_before": current_level, "rank_after": current_level + 1,
		"rank_max": max_level_for(item_id), "rarity": rarity,
		"rarity_label": rarity_label(rarity), "rarity_color": rarity_color(rarity),
	}

static func build_offer(item_levels_by_id: Dictionary, seed_value: int, floor_index: int) -> Dictionary:
	var eligible_by_rarity: Dictionary = {}
	for item_id in ITEM_IDS:
		var level: Variant = item_levels_by_id.get(item_id, item_levels_by_id.get(String(item_id), 0))
		if typeof(level) != TYPE_INT or int(level) < 0 or int(level) >= max_level_for(item_id):
			continue
		var rarity := rarity_for(item_id)
		if floor_index < rarity_unlock_floor(rarity):
			continue
		if not eligible_by_rarity.has(rarity):
			eligible_by_rarity[rarity] = []
		eligible_by_rarity[rarity].append(item_id)
	if eligible_by_rarity.is_empty():
		return {}
	var rarities: Array = eligible_by_rarity.keys()
	rarities.sort()
	var total_weight := 0
	for rarity in rarities:
		total_weight += rarity_weight(int(rarity), floor_index)
	if total_weight <= 0:
		return {}
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var roll := rng.randi_range(1, total_weight)
	var selected_rarity := -1
	for rarity in rarities:
		roll -= rarity_weight(int(rarity), floor_index)
		if roll <= 0:
			selected_rarity = int(rarity)
			break
	if selected_rarity < 0:
		return {}
	var candidates: Array = eligible_by_rarity[selected_rarity]
	var selected_item: StringName = candidates[rng.randi_range(0, candidates.size() - 1)]
	var current_level := int(item_levels_by_id.get(selected_item, item_levels_by_id.get(String(selected_item), 0)))
	return card_preview(selected_item, current_level)

```

### `scripts/progression/run_build.gd`

```text
class_name RunBuild
extends RefCounted

## State that lasts for one run. Catalogs own effects and limits.
const UpgradeCatalogScript = preload("res://scripts/progression/upgrade_catalog.gd")
const ShopItemCatalogScript = preload("res://scripts/progression/shop_item_catalog.gd")
const IMPACTO_REFORCADO: StringName = &"impacto_reforcado"
const MOTOR_ACELERADO: StringName = &"motor_acelerado"
const CARGA_REATIVA: StringName = &"carga_reativa"
const MAX_UPGRADES: int = UpgradeCatalogScript.MAX_RUN_ACQUISITIONS

var _counts_by_id: Dictionary = {}
var _item_levels_by_id: Dictionary = {}

func _init() -> void:
	_clear_state()

func add_upgrade(upgrade_id: StringName) -> bool:
	var current_rank := count_for(upgrade_id)
	if total_count() >= MAX_UPGRADES or not UpgradeCatalogScript.can_acquire(upgrade_id, current_rank):
		return false
	_counts_by_id[upgrade_id] = current_rank + 1
	return true

func add_item(item_id: StringName) -> bool:
	var current_level := item_level_for(item_id)
	var maximum_level := ShopItemCatalogScript.max_level_for(item_id)
	if not ShopItemCatalogScript.is_known_item_id(item_id) or current_level >= maximum_level:
		return false
	_item_levels_by_id[item_id] = current_level + 1
	return true

func has_upgrade(upgrade_id: StringName) -> bool:
	return count_for(upgrade_id) > 0

func count_for(upgrade_id: StringName) -> int:
	return int(_counts_by_id.get(upgrade_id, 0)) if is_known_upgrade_id(upgrade_id) else 0

func item_level_for(item_id: StringName) -> int:
	return int(_item_levels_by_id.get(item_id, 0)) if ShopItemCatalogScript.is_known_item_id(item_id) else 0

func total_count() -> int:
	return UpgradeCatalogScript.total_rank_count(_counts_by_id)

func get_upgrade_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for upgrade_id in known_upgrade_ids():
		if count_for(upgrade_id) > 0:
			result.append(upgrade_id)
	return result

func get_item_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for item_id in ShopItemCatalogScript.known_item_ids():
		if item_level_for(item_id) > 0:
			result.append(item_id)
	return result

## Legacy snapshots omit item fields. Validate all supplied ids and ranks before mutation.
func replace_state(
	upgrade_ids: Variant,
	counts_by_id: Variant,
	item_ids: Variant = [],
	item_levels_by_id: Variant = {}
) -> bool:
	if typeof(upgrade_ids) != TYPE_ARRAY or typeof(counts_by_id) != TYPE_DICTIONARY:
		return false
	if typeof(item_ids) != TYPE_ARRAY or typeof(item_levels_by_id) != TYPE_DICTIONARY:
		return false

	var normalized_ids: Array[StringName] = []
	for raw_id in upgrade_ids:
		if typeof(raw_id) != TYPE_STRING and typeof(raw_id) != TYPE_STRING_NAME:
			return false
		var upgrade_id := StringName(raw_id)
		if not is_known_upgrade_id(upgrade_id) or normalized_ids.has(upgrade_id):
			return false
		normalized_ids.append(upgrade_id)

	var normalized_counts: Dictionary = {}
	var seen_count_ids: Dictionary = {}
	for upgrade_id in known_upgrade_ids():
		normalized_counts[upgrade_id] = 0
	for raw_id in counts_by_id.keys():
		if typeof(raw_id) != TYPE_STRING and typeof(raw_id) != TYPE_STRING_NAME:
			return false
		var upgrade_id := StringName(raw_id)
		if not is_known_upgrade_id(upgrade_id) or seen_count_ids.has(upgrade_id):
			return false
		var raw_count: Variant = counts_by_id[raw_id]
		if typeof(raw_count) != TYPE_INT:
			return false
		var rank := int(raw_count)
		var cap := UpgradeCatalogScript.max_rank_for(upgrade_id)
		if rank < 0 or rank > cap:
			return false
		seen_count_ids[upgrade_id] = true
		normalized_counts[upgrade_id] = rank

	var ids_from_counts: Array[StringName] = []
	for upgrade_id in known_upgrade_ids():
		if int(normalized_counts[upgrade_id]) > 0:
			ids_from_counts.append(upgrade_id)
	if ids_from_counts.size() != normalized_ids.size():
		return false
	for upgrade_id in normalized_ids:
		if not ids_from_counts.has(upgrade_id):
			return false
	if UpgradeCatalogScript.total_rank_count(normalized_counts) > MAX_UPGRADES:
		return false

	var normalized_item_ids: Array[StringName] = []
	for raw_id in item_ids:
		if typeof(raw_id) != TYPE_STRING and typeof(raw_id) != TYPE_STRING_NAME:
			return false
		var item_id := StringName(raw_id)
		if not ShopItemCatalogScript.is_known_item_id(item_id) or normalized_item_ids.has(item_id):
			return false
		normalized_item_ids.append(item_id)

	var normalized_items: Dictionary = {}
	var seen_item_ids: Dictionary = {}
	for item_id in ShopItemCatalogScript.known_item_ids():
		normalized_items[item_id] = 0
	for raw_id in item_levels_by_id.keys():
		if typeof(raw_id) != TYPE_STRING and typeof(raw_id) != TYPE_STRING_NAME:
			return false
		var item_id := StringName(raw_id)
		if not ShopItemCatalogScript.is_known_item_id(item_id) or seen_item_ids.has(item_id):
			return false
		var raw_level: Variant = item_levels_by_id[raw_id]
		if typeof(raw_level) != TYPE_INT:
			return false
		var level := int(raw_level)
		if level < 0 or level > ShopItemCatalogScript.max_level_for(item_id):
			return false
		seen_item_ids[item_id] = true
		normalized_items[item_id] = level

	var ids_from_items: Array[StringName] = []
	for item_id in ShopItemCatalogScript.known_item_ids():
		if int(normalized_items[item_id]) > 0:
			ids_from_items.append(item_id)
	if ids_from_items.size() != normalized_item_ids.size():
		return false
	for item_id in normalized_item_ids:
		if not ids_from_items.has(item_id):
			return false

	_counts_by_id = normalized_counts
	_item_levels_by_id = normalized_items
	return true

func to_snapshot_data() -> Dictionary:
	var id_strings: Array[String] = []
	var counts: Dictionary = {}
	for upgrade_id in known_upgrade_ids():
		var rank := count_for(upgrade_id)
		counts[String(upgrade_id)] = rank
		if rank > 0:
			id_strings.append(String(upgrade_id))
	var item_id_strings: Array[String] = []
	var item_levels: Dictionary = {}
	for item_id in ShopItemCatalogScript.known_item_ids():
		var level := item_level_for(item_id)
		item_levels[String(item_id)] = level
		if level > 0:
			item_id_strings.append(String(item_id))
	return {
		"upgrade_ids": id_strings,
		"counts_by_id": counts,
		"item_ids": item_id_strings,
		"item_levels_by_id": item_levels,
	}

func clear() -> void:
	_clear_state()

static func is_known_upgrade_id(upgrade_id: Variant) -> bool:
	return UpgradeCatalogScript.is_known_upgrade_id(upgrade_id)

static func known_upgrade_ids() -> Array[StringName]:
	return UpgradeCatalogScript.known_upgrade_ids()

func _clear_state() -> void:
	_counts_by_id.clear()
	for upgrade_id in known_upgrade_ids():
		_counts_by_id[upgrade_id] = 0
	_item_levels_by_id.clear()
	for item_id in ShopItemCatalogScript.known_item_ids():
		_item_levels_by_id[item_id] = 0

```

### `scripts/ui/shop_item_card.gd`

```text
class_name ShopItemCard
extends UpgradeCard

const ShopItemCatalogScript = preload("res://scripts/progression/shop_item_catalog.gd")
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
	_rarity_label.set_text(ShopItemCatalogScript.rarity_label(int(rarity)))
	_illustration.texture = _build_item_icon(item_id)
	_illustration.show()
	return true

func _build_item_icon(item_id: StringName) -> Texture2D:
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

```

### `scenes/shop/shop_item_card.tscn`

```text
[gd_scene load_steps=4 format=3]

[ext_resource type="PackedScene" path="res://scenes/ui/upgrade_card.tscn" id="1_base"]
[ext_resource type="Script" path="res://scripts/ui/shop_item_card.gd" id="2_script"]
[ext_resource type="Script" path="res://scripts/ui/hud/bitmap_text.gd" id="3_bitmap_text"]

[node name="ShopItemCard" instance=ExtResource("1_base")]
script = ExtResource("2_script")

[node name="RarityChip" type="ColorRect" parent="."]
offset_left = 48.0
offset_top = 23.0
offset_right = 56.0
offset_bottom = 31.0
mouse_filter = 2
color = Color(0.823529, 0.654902, 0.360784, 1)

[node name="RarityLabel" type="Control" parent="."]
offset_left = 60.0
offset_top = 22.0
offset_right = 100.0
offset_bottom = 32.0
mouse_filter = 2
texture_filter = 1
script = ExtResource("3_bitmap_text")
center_text = true
max_lines = 1
font_color = Color(0.823529, 0.654902, 0.360784, 1)

```

### `scripts/ui/shop_offer.gd`

```text
class_name ShopOffer
extends CanvasLayer

signal closed

const UpgradeCatalogScript = preload("res://scripts/progression/upgrade_catalog.gd")
const UpgradeCardScene: PackedScene = preload("res://scenes/ui/upgrade_card.tscn")
const ShopItemCardScene: PackedScene = preload("res://scenes/shop/shop_item_card.tscn")
const ShopItemCatalogScript = preload("res://scripts/progression/shop_item_catalog.gd")
const STAGE_SIZE: Vector2 = Vector2(576.0, 324.0)

@onready var _stage: Control = $Stage
@onready var _heading: HudBitmapText = $Stage/Heading
@onready var _hint: HudBitmapText = $Stage/Hint
@onready var _cards_row: HBoxContainer = $Stage/Cards
@onready var _price_labels: Array[HudBitmapText] = [
	$Stage/Prices/Price0 as HudBitmapText,
	$Stage/Prices/Price1 as HudBitmapText,
	$Stage/Prices/Price2 as HudBitmapText,
]

var _controller: Node
var _room: Node
var _player: Node
var _font_bundle: Dictionary = {}
var _rows: Array[Dictionary] = []
var _cards: Array[UpgradeCard] = []
var _open: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	layer = 40
	set_process_unhandled_key_input(false)
	_font_bundle = UpgradeCard.load_card_font_bundle()
	if bool(_font_bundle.get("valid", false)):
		_heading.configure_font(_font_bundle)
		_hint.configure_font(_font_bundle)
	for price_label in _price_labels:
		if bool(_font_bundle.get("valid", false)):
			price_label.configure_font(_font_bundle)
		price_label.center_text = true
		price_label.max_lines = 1
	var viewport := get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_layout_stage):
		viewport.size_changed.connect(_layout_stage)
	_layout_stage()
	hide()

func present(controller: Node, room: Node, player: Node, state: Dictionary) -> bool:
	var raw_offers: Variant = state.get("offers", [])
	if (
		typeof(raw_offers) != TYPE_ARRAY or raw_offers.size() > 3
		or not bool(_font_bundle.get("valid", false))
	):
		return false
	var next_rows: Array[Dictionary] = []
	var next_ids: Array[StringName] = []
	for raw_offer: Variant in raw_offers:
		if typeof(raw_offer) != TYPE_DICTIONARY:
			return false
		var offer: Dictionary = raw_offer
		var row_variant: Variant = offer.get("row", {})
		if typeof(row_variant) != TYPE_DICTIONARY:
			return false
		var row: Dictionary = row_variant
		var kind: StringName = StringName(offer.get("kind", &"upgrade"))
		var offer_id: StringName = StringName(offer.get("offer_id", offer.get("upgrade_id", &"")))
		if (
			offer_id.is_empty() or next_ids.has(offer_id)
			or typeof(offer.get("price")) != TYPE_INT or int(offer.get("price", -1)) < 0
		):
			return false
		if kind == &"item":
			var item_id: StringName = StringName(offer.get("item_id", &""))
			if (
				item_id != offer_id or not ShopItemCatalogScript.is_known_item_id(item_id)
				or StringName(row.get("item_id", &"")) != item_id
			):
				return false
		elif kind == &"upgrade":
			var definition: UpgradeDefinitionResource = row.get("definition") as UpgradeDefinitionResource
			if definition == null or definition.upgrade_id != offer_id:
				return false
		else:
			return false
		next_rows.append(offer.duplicate(true))
		next_ids.append(offer_id)
	_controller = controller
	_room = room
	_player = player
	_rows = next_rows
	_clear_cards()
	for index in range(_rows.size()):
		var offer: Dictionary = _rows[index]
		var row: Dictionary = offer.get("row", {})
		var kind: StringName = StringName(offer.get("kind", &"upgrade"))
		var card: UpgradeCard
		if kind == &"item":
			card = ShopItemCardScene.instantiate() as UpgradeCard
		else:
			card = UpgradeCardScene.instantiate() as UpgradeCard
		if card == null:
			_clear_cards()
			return false
		_cards_row.add_child(card)
		var configured := bool(card.call("configure_item", row, _font_bundle)) if kind == &"item" 			else card.configure(row, _font_bundle)
		if not configured:
			_cards_row.remove_child(card)
			card.queue_free()
			_clear_cards()
			return false
		card.pressed.connect(_on_card_pressed.bind(index))
		card.disabled = bool(offer.get("purchased", false))
		_cards.append(card)
		var price_label: HudBitmapText = _price_labels[index]
		price_label.font_color = Color("#62c6a5") if card.disabled else Color("#d2a75c")
		price_label.set_text("COMPRADO" if card.disabled else "PREÇO %d" % int(offer.get("price", 0)))
		price_label.show()
	for index in range(_rows.size(), _price_labels.size()):
		_price_labels[index].hide()
	_set_balance(int(state.get("scrap", 0)))
	_hint.set_text("ESTOQUE ESGOTADO - E/ESC PARA FECHAR" if _rows.is_empty() else "ESCOLHA UMA MELHORIA E SIGA SUBINDO")
	_open = true
	set_process_unhandled_key_input(true)
	show()
	_layout_stage()
	for card in _cards:
		if not card.disabled:
			card.grab_focus()
			break
	return true
func close_offer(emit_closed: bool = true) -> void:
	if not _open and not visible:
		return
	_open = false
	set_process_unhandled_key_input(false)
	for card in _cards:
		if is_instance_valid(card):
			card.disabled = true
	hide()
	if emit_closed:
		closed.emit()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and (event as InputEventKey).echo:
		return
	if event.is_action_pressed(&"interact") or event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		close_offer()

func _on_card_pressed(index: int) -> void:
	if not _open or index < 0 or index >= _rows.size() or index >= _cards.size():
		return
	if not is_instance_valid(_controller) or not is_instance_valid(_room) or not is_instance_valid(_player):
		close_offer()
		return
	var offer: Dictionary = _rows[index]
	var offer_id: StringName = StringName(offer.get("offer_id", offer.get("upgrade_id", &"")))
	var offer_kind: StringName = StringName(offer.get("kind", &"upgrade"))
	var price: int = int(offer.get("price", -1))
	var purchased: bool = bool(_controller.call("purchase_shop_offer", _room, index, offer_id, price))
	if purchased:
		_cards[index].disabled = true
		_price_labels[index].font_color = Color("#62c6a5")
		_price_labels[index].set_text("COMPRADO")
		var current_scrap: int = int(_controller.get("temporary_scrap"))
		var refreshed_variant: Variant = _controller.call("get_shop_offer_state", _room)
		if typeof(refreshed_variant) == TYPE_DICTIONARY:
			var refreshed: Dictionary = refreshed_variant
			current_scrap = int(refreshed.get("scrap", current_scrap))
		_set_balance(current_scrap)
		_hint.set_text("ITEM ADICIONADO" if offer_kind == &"item" else "MELHORIA ADICIONADA")
		return
	var current_scrap: int = int(_controller.get("temporary_scrap"))
	if current_scrap < price:
		_hint.set_text("SUCATA INSUFICIENTE")
	else:
		_hint.set_text("OFERTA INDISPONÍVEL")
func _set_balance(value: int) -> void:
	_heading.set_text("LOJA - SUCATA %d" % maxi(value, 0))

func _clear_cards() -> void:
	_cards.clear()
	for child: Node in _cards_row.get_children():
		_cards_row.remove_child(child)
		child.queue_free()

func _layout_stage() -> void:
	if _stage == null or get_viewport() == null:
		return
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var integer_scale: int = maxi(floori(minf(viewport_size.x / STAGE_SIZE.x, viewport_size.y / STAGE_SIZE.y)), 1)
	var scaled_size: Vector2 = STAGE_SIZE * float(integer_scale)
	_stage.scale = Vector2.ONE * float(integer_scale)
	_stage.position = ((viewport_size - scaled_size) * 0.5).floor()

func _exit_tree() -> void:
	close_offer(false)
```

## Gameplay integration excerpts

### `scripts/player/ball_launcher.gd` — `is_launch_available`

```gdscript
func is_launch_available() -> bool:
	if _racket_controller == null or _racket_controller.is_swing_active():
		return false
	if _aim_controller == null or _shot_origin == null:
		return false
	if projectile_scene == null or _base_projectile_config == null or _projectile_parent == null:
		return false
	if _active_ball == null:
		return true
	if is_instance_valid(_active_ball):
		return false
	_active_ball = null
	return true
```

### `scripts/player/ball_launcher.gd` — `_on_ball_finished`

```gdscript
func _on_ball_finished(reason: String, ball: RicochetBall) -> void:
	if reason == "returned":
		_register_catraca_scrap()
	if ball == _active_ball:
		_active_ball = null
```

### `scripts/player/ball_launcher.gd` — `_register_catraca_scrap`

```gdscript
func _register_catraca_scrap() -> void:
	if _catraca_scrap_registered or _run_build == null or _run_build.item_level_for(&"catraca_sucata") <= 0:
		return
	if not is_instance_valid(_player):
		return
	var scene_tree := _player.get_tree()
	if scene_tree == null:
		return
	for controller: Node in scene_tree.get_nodes_in_group("run_controller"):
		if not is_instance_valid(controller) or not controller.has_method("register_temporary_scrap"):
			continue
		var accepted: Variant = controller.call("register_temporary_scrap", 1, false)
		if typeof(accepted) == TYPE_BOOL and bool(accepted):
			_catraca_scrap_registered = true
			return
```

### `scripts/player/ball_launcher.gd` — `get_projectile_config_snapshot`

```gdscript
func get_projectile_config_snapshot() -> ProjectileConfig:
	if _base_projectile_config == null:
		return null
	var derived_config := _base_projectile_config.duplicate(true) as ProjectileConfig
	if _run_build != null:
		var return_bearing_level := _run_build.item_level_for(&"rolamento_livre")
		derived_config.return_speed_multiplier = 1.0 + 0.25 * float(return_bearing_level)
		var turbine_level := _run_build.item_level_for(&"turbina_centrifuga")
		derived_config.environmental_bounce_speed_bonus_per_bounce = 0.08 * float(turbine_level)
		derived_config.max_environmental_bounce_speed_multiplier = 1.4 if turbine_level > 0 else 1.0
		derived_config.impact_rank = _run_build.count_for(&"impacto_reforcado")
		derived_config.charge_rank = _run_build.count_for(&"carga_reativa")
		derived_config.pressure_rank = _run_build.count_for(&"ricochete_pressao")
		var charge_definition := UpgradeCatalogScript.definition_for(&"carga_reativa")
		derived_config.reactive_charge_enabled = derived_config.charge_rank > 0 \
			and charge_definition != null and charge_definition.reactive_charge_enabled
		derived_config.charged_damage_bonus = derived_config.charge_rank * (
			charge_definition.charged_damage_bonus_per_rank if charge_definition != null else 0
		)
		derived_config.max_bounces += UpgradeCatalogScript.projectile_bounce_bonus(
			_run_build.count_for(&"mola_retorno")
		)
		derived_config.lifetime += UpgradeCatalogScript.projectile_lifetime_bonus(
			_run_build.count_for(&"mola_retorno")
		)
	# Run rewards derive from the already-upgraded copy; the base Resource stays unchanged.
	derived_config.damage = maxi(roundi(float(derived_config.damage) * _run_damage_multiplier), 1)
	if _run_build != null:
		derived_config.speed *= UpgradeCatalogScript.projectile_speed_multiplier_for_rank(
			_run_build.count_for(&"ajuste_velocidade_bola")
		)
	derived_config.speed *= _run_speed_multiplier
	derived_config.collision_radius *= _run_radius_multiplier
	return derived_config
```

### `scripts/player/movement_controller.gd` — `reduce_dash_cooldown_remaining`

```gdscript
func reduce_dash_cooldown_remaining(seconds: float) -> float:
	if _dash_state != DashState.COOLDOWN or seconds <= 0.0:
		return _dash_cooldown_timer
	_dash_cooldown_timer = maxf(_dash_cooldown_timer - seconds, 0.0)
	if _dash_cooldown_timer <= 0.0:
		_dash_state = DashState.READY
	return _dash_cooldown_timer
```

### `scripts/player/movement_controller.gd` — `restore_air_dashes`

```gdscript
func restore_air_dashes(amount: int) -> int:
	if _config == null or amount <= 0:
		return _air_dashes_remaining
	_air_dashes_remaining = mini(_air_dashes_remaining + amount, maxi(_config.max_air_dashes, 0))
	return _air_dashes_remaining
```

### `scripts/player/player.gd` — `apply_run_build`

```gdscript
func apply_run_build(
	build: RunBuild,
	acquired_upgrade_id: StringName = &"",
	previous_rank: int = 0
) -> void:
	if _base_movement_config == null:
		return
	_emergency_fuse_level = build.item_level_for(&"fusivel_emergencia") if build != null else 0
	var derived_config := _base_movement_config.duplicate(true) as MovementConfig
	if build != null:
		derived_config.dash_cooldown = UpgradeCatalogScript.dash_cooldown_with_adjustment(
			build.count_for(&"motor_acelerado"),
			build.count_for(&"ajuste_recarga_dash")
		)
	if build != null:
		derived_config.max_air_dashes = _base_movement_config.max_air_dashes + build.item_level_for(&"mola_salto")
	movement_controller.update_config_preserving_state(derived_config)
	ball_launcher.apply_run_build(build)
	if racket_controller != null:
		racket_controller.apply_run_build(build)
	if health != null:
		health.apply_run_build(build, acquired_upgrade_id, previous_rank)
```

### `scripts/player/player.gd` — `_on_damage_accepted`

```gdscript
func _on_damage_accepted(_amount: int, _current: int, _maximum: int) -> void:
	if _emergency_fuse_level > 0 and not _emergency_fuse_used_this_room:
		_emergency_fuse_used_this_room = true
		if movement_controller != null:
			movement_controller.reduce_dash_cooldown_remaining(0.5)
	if health.is_dead:
		return
	player_visual.play_hurt()
```

### `scripts/player/racket_controller.gd` — `register_parry_success`

```gdscript
func register_parry_success(swing_id: int) -> void:
	if swing_id != _swing_id:
		return
	_success_flash_remaining = 0.18
	if swing_id != _last_rewarded_swing_id:
		_last_rewarded_swing_id = swing_id
		var player := get_parent()
		var player_body := player as CharacterBody2D
		var movement := player.get_node_or_null("MovementController") if player != null else null
		if _dash_cooldown_refund > 0.0 \
			and movement != null and movement.has_method("reduce_dash_cooldown_remaining"):
			movement.call("reduce_dash_cooldown_remaining", _dash_cooldown_refund)
		if _rhythm_coil_level > 0 and not _rhythm_coil_used_this_room \
			and player_body != null and not player_body.is_on_floor() \
			and movement != null and movement.has_method("restore_air_dashes"):
			_rhythm_coil_used_this_room = true
			movement.call("restore_air_dashes", 1)
	_update_feedback()
```

### `scripts/player/racket_controller.gd` — `apply_run_build`

```gdscript
func apply_run_build(build: RunBuild) -> void:
	var rank := build.count_for(&"dinamo_defesa") if build != null else 0
	_rhythm_coil_level = build.item_level_for(&"bobina_ritmo") if build != null else 0
	_dash_cooldown_refund = UpgradeCatalogScript.dash_refund_seconds(rank)
	arc_degrees = _base_arc_degrees + 8.0 * float(build.item_level_for(&"punho_guarda") if build != null else 0)
```

### `scripts/player/player_health.gd` — `apply_run_build`

```gdscript
func apply_run_build(build: RunBuild, acquired_upgrade_id: StringName = &"", previous_rank: int = 0) -> void:
	var chassis_rank := build.count_for(&"chassi_reforcado") if build != null else 0
	maximum_health = UpgradeCatalogScript.maximum_health(_base_maximum_health, chassis_rank)
	current_health = clampi(current_health, 0, maximum_health)
	if not acquired_upgrade_id.is_empty() and current_health > 0:
		var recovered := UpgradeCatalogScript.acquisition_heal(
			acquired_upgrade_id,
			previous_rank,
			build.count_for(acquired_upgrade_id) if build != null else previous_rank
		)
		current_health = mini(current_health + recovered, maximum_health)
	var aegis_rank := build.item_level_for(&"fusivel_aegis") if build != null else 0
	if aegis_rank > _aegis_rank_applied:
		_aegis_blocks_remaining = mini(_aegis_blocks_remaining + aegis_rank - _aegis_rank_applied, aegis_rank)
	elif aegis_rank < _aegis_rank_applied:
		_aegis_blocks_remaining = 0
	_aegis_rank_applied = aegis_rank
	health_changed.emit(current_health, maximum_health)
```

### `scripts/player/player_health.gd` — `take_damage`

```gdscript
func take_damage(amount: int, _source: Node = null) -> bool:
	if amount <= 0 or is_dead or is_invulnerable:
		return false
	if _aegis_blocks_remaining > 0:
		_aegis_blocks_remaining -= 1
		_invulnerability_remaining = maxf(invulnerability_duration, 0.0)
		return false
	current_health = maxi(current_health - amount, 0)
	_invulnerability_remaining = maxf(invulnerability_duration, 0.0)
	health_changed.emit(current_health, maximum_health)
	damage_accepted.emit(amount, current_health, maximum_health)
	if is_dead:
		died.emit()
	return true
```

### `scripts/projectile/ricochet_ball.gd` — `launch`

```gdscript
func launch(direction: Vector2, config: ProjectileConfig) -> void:
	if _has_launched or _has_finished or config == null:
		return

	_config = config
	_config.lifetime = 5.0 # alteração temporária dps a gente vê a duração do projétil
	var launch_direction := direction.normalized()
	if launch_direction.is_zero_approx():
		launch_direction = Vector2.RIGHT
	_environmental_bounce_speed_multiplier = 1.0
	velocity = launch_direction * _current_projectile_speed()
	_lifetime_remaining = _config.lifetime
	_has_launched = true
	_is_returning = false
	_stop_sweep_requested = false
	_set_charge_state(ChargeState.INACTIVE)
	_bounce_count = 0
	_environmental_bounce_count = 0
	_pending_motion = Vector2.ZERO
	_parry_release_pending = true
	if is_instance_valid(collision_shape):
		collision_shape.set_deferred("disabled", false)
	_apply_collision_radius()
	queue_redraw()
```

### `scripts/projectile/ricochet_ball.gd` — `_return_to_player`

```gdscript
func _return_to_player(delta: float) -> void:
	if not is_instance_valid(_return_target):
		_finish("return_target_missing")
		return

	var destination := _return_target.global_position
	var capture_distance := maxf(_projectile_radius() + 8.0, 14.0)
	if global_position.distance_to(destination) <= capture_distance:
		global_position = destination
		_finish("returned")
		return

	var return_speed_multiplier := clampf(_config.return_speed_multiplier, 1.0, 1.5)
	var return_speed := maxf(_current_projectile_speed() * 1.5 * return_speed_multiplier, 150.0)
	global_position = global_position.move_toward(destination, return_speed * delta)
```

### `scripts/projectile/ricochet_ball.gd` — `_current_projectile_speed`

```gdscript
func _current_projectile_speed() -> float:
	if _config == null:
		return 0.0
	var multiplier_cap := maxf(_config.max_environmental_bounce_speed_multiplier, 1.0)
	var multiplier := clampf(_environmental_bounce_speed_multiplier, 1.0, multiplier_cap)
	return maxf(_config.speed, 0.0) * multiplier
```

### `scripts/projectile/ricochet_ball.gd` — `_record_environmental_bounce`

```gdscript
func _record_environmental_bounce() -> void:
	_environmental_bounce_count += 1
	if _config == null:
		return
	var speed_cap := maxf(_config.max_environmental_bounce_speed_multiplier, 1.0)
	var speed_bonus := maxf(_config.environmental_bounce_speed_bonus_per_bounce, 0.0)
	_environmental_bounce_speed_multiplier = minf(
		maxf(_environmental_bounce_speed_multiplier, 1.0) + speed_bonus,
		speed_cap
	)
```

### `scripts/projectile/ricochet_ball.gd` — `_apply_impact_damage`

```gdscript
func _apply_impact_damage(collider: Object, impact_position: Vector2, feedback_scene_root: Node) -> void:
	if _config == null or _config.damage <= 0 or not collider is Node:
		return

	var target := collider as Node
	if not target.is_in_group("damageable") or not target.has_method("take_damage"):
		return
	if _damaged_targets_this_tick.has(target):
		return

	_damaged_targets_this_tick[target] = true
	var was_charged := _charge_state == ChargeState.CHARGED
	var damage_amount := UpgradeCatalogScript.projectile_damage(
		_config.damage,
		_config.impact_rank,
		_config.charge_rank,
		was_charged and _config.reactive_charge_enabled,
		_config.pressure_rank,
		_environmental_bounce_count
	)
	var damage_result: Variant = target.call("take_damage", damage_amount, self)
	var damage_was_accepted := typeof(damage_result) == TYPE_BOOL and bool(damage_result)
	if not damage_was_accepted:
		return
	var effect_kind: int = (
		CombatFeedbackScript.EffectKind.CHARGED_HIT
		if was_charged
		else CombatFeedbackScript.EffectKind.ENEMY_HIT
	)
	CombatFeedbackScript.enqueue(feedback_scene_root, impact_position, effect_kind)
	if was_charged and _charge_state == ChargeState.CHARGED:
		_set_charge_state(ChargeState.CONSUMED)
```

### `scripts/world/run_controller.gd` — `register_temporary_scrap`

```gdscript
func register_temporary_scrap(amount: int, apply_magnetic_bonus: bool = true) -> bool:
	if amount <= 0 or _run_ended or _returning_to_lobby:
		return false
	var scrap_delta: int = amount + (_run_build.item_level_for(&"bolsa_magnetica") if apply_magnetic_bonus else 0)
	temporary_scrap += scrap_delta
	temporary_scrap_changed.emit(temporary_scrap, scrap_delta)
	return true
```

### `scripts/world/run_controller.gd` — `_prepare_room_candidate`

```gdscript
func _prepare_room_candidate(proposal: Dictionary) -> Dictionary:
	if not bool(proposal.get("valid", false)):
		return {"valid": false, "error": String(proposal.get("error", "proposta de sala inválida"))}
	var target_room: int = int(proposal.get("room", 0))
	var packed_scene: PackedScene = boss_room_scene if target_room > common_rooms_per_floor else common_room_scene
	if packed_scene == null:
		return {"valid": false, "error": "ERRO: cena de sala destino não definida."}
	var next_room: Node = packed_scene.instantiate()
	if next_room == null:
		return {"valid": false, "error": "ERRO: não foi possível instanciar a cena destino."}
	next_room.process_mode = Node.PROCESS_MODE_DISABLED
	if not next_room.has_method("configure_run_managed"):
		next_room.free()
		return {"valid": false, "error": "ERRO: a cena de sala não oferece integração gerenciada."}
	if not next_room.has_signal("run_progression_ready"):
		next_room.free()
		return {"valid": false, "error": "ERRO: a sala não oferece o sinal run_progression_ready."}
	var descriptor: Dictionary = proposal.get("descriptor", {}).duplicate(true)
	var floor_index: int = int(proposal.get("floor", current_floor))
	var room_index: int = int(proposal.get("room", current_room))
	var room_ordinal: int = 1 + (floor_index - 1) * (common_rooms_per_floor + 1) + (room_index - 1)
	descriptor["enemy_level"] = 1 if StringName(descriptor.get("room_kind", &"combat")) == &"shop" else maxi(room_ordinal, 1)
	var requested_seed: int = int(descriptor.get("room_seed", 0))
	if not bool(next_room.call("configure_run_managed", _run_build, true, requested_seed, descriptor, enemy_level_config)):
		var layout_error := ""
		if next_room.has_method("get_authored_layout_error"):
			layout_error = String(next_room.call("get_authored_layout_error"))
		next_room.free()
		var failure := "ERRO: não foi possível configurar a sala para esta run."
		if not layout_error.is_empty():
			failure += " Layout: " + layout_error
		return {"valid": false, "error": failure}
	return {"valid": true, "room": next_room}
```

## Projectile configuration

```gdscript
class_name ProjectileConfig
extends Resource

@export_range(100.0, 2000.0, 10.0)
var speed: float = 760.0

@export_range(0.1, 10.0, 0.1)
var lifetime: float = 2.2

@export_range(2.0, 16.0, 0.5)
var collision_radius: float = 8.0

@export_range(0.0, 80.0, 0.5)
var spawn_offset: float = 48.0

@export_range(0, 6, 1)
var max_bounces: int = 3

## Per-shot item modifiers, derived by BallLauncher from RunBuild.
var return_speed_multiplier: float = 1.0
var environmental_bounce_speed_bonus_per_bounce: float = 0.0
var max_environmental_bounce_speed_multiplier: float = 1.0

@export_range(1, 100, 1)
var damage: int = 1

## Preparação tipada para a fase C; a etapa A não executa a carga.
@export var reactive_charge_enabled: bool = false
@export_range(0, 100, 1)
var charged_damage_bonus: int = 0

## Rank data is filled into each launch snapshot by BallLauncher.
var impact_rank: int = 0
var charge_rank: int = 0
var pressure_rank: int = 0

## World (layer 1) plus Damageable (layer 4).
@export_flags_2d_physics
var collision_mask: int = 9

@export_range(0.0, 4.0, 0.1)
var collision_skin: float = 1.0

@export_range(0.01, 0.5, 0.01)
var collision_safe_margin: float = 0.08

@export_range(1, 4, 1)
var max_collisions_per_tick: int = 2

```

## User-facing item record and asset audit

```text
 — 17/11/2026

Os cinco itens existentes e seus IDs permanecem validos. O catalogo agora inclui cinco opcoes provisórias adicionais, mantendo as faixas e os pesos de raridade atuais:

- COMUM `catraca_sucata` (maximo 1): a primeira bola que retorna concede +1 sucata por instância/sala; a Bolsa Magnetica nao amplia esse premio.
- INCOMUM `rolamento_livre` (maximo 2): a velocidade de retorno aumenta 25% por nivel.
- RARO `turbina_centrifuga` (maximo 2): cada rebote ambiental concede +8% de velocidade por nivel, limitado a +40% sobre a velocidade inicial do disparo. Parry e rebotes seguintes preservam o multiplicador acumulado.
- EPICO `bobina_ritmo` (maximo 1): a primeira rebatida bem-sucedida no ar restitui 1 dash aereo, limitado ao maximo atual, uma vez por sala.
- LENDARIO `fusivel_emergencia` (maximo 1): o primeiro dano aceito por sala reduz em 0,5 s o cooldown restante do dash. O Aegis bloqueia dano antes do sinal de dano aceito e nao consome este efeito.

Os itens raros, epicos e lendarios usam os andares minimos ja definidos para suas faixas; os pesos permanecem provisórios. Como cada sala instancia um jogador novo, os efeitos limitados por sala ficam no launcher, controlador de rebatida e jogador dessa instância. `RunBuild` passa a validar e serializar os novos IDs pelo catalogo; snapshots antigos sem campos de item continuam usando os defaults legados.

`ShopItemCard` carrega os PNGs em `assets/shop/items/<id>.png` para esses cinco IDs; os cinco ícones procedurais existentes permanecem. A integração de código foi revisada estaticamente, sem execução de Godot ou testes.

A revisão Muse R1 do pacote de raridades encontrou quatro pontos acionáveis (ordenação única das ofertas, quantidade configurável de lojas, estado sem estoque e descrição desatualizada). Os quatro foram corrigidos antes da revisão R2; resposta original em `pareceres/raridades-r1-muse.jsonl`. A resposta da R2 registra a revisão do estado corrigido. A configuração negou as ferramentas; modelUsage não expôs metadados efetivos de modelo/variante. Gemini 4 Hydrogen (High) permanece pendente porque não foi possível verificar isolamento do revisor. Nenhum teste ou comando Godot foi executado nesta etapa.


#### Arte dos itens

Cada novo item tem um ícone independente 32×32 em `assets/shop/items/`, conceito original em `source/`, ampliação nearest 8× em `preview/` e o prompt usado ao lado do PNG final. Os arquivos finais foram reduzidos à paleta local de 19 cores, com alfa somente 0/255; `quality_audit.py` passou nos cinco ícones sem pixels semitransparentes ou isolados. Aseprite não estava disponível neste ambiente, então não há fontes `.aseprite` para estes ícones.

A inspiração foi a leitura de relíquias com efeitos de build distintos em *Rogue Legacy 2* e de efeitos/afixos associados ao equipamento em *Dead Cells*. Usei esses referenciais para separar as funções por silhueta e efeito, sem reproduzir seus assets: [notas oficiais de atualização de Rogue Legacy 2](https://www.cellardoorgames.com/roguelegacy2-patch/v020), [outra atualização oficial sobre raridade e impacto dos relics](https://www.cellardoorgames.com/roguelegacy2-patch/v070), [referência de afixos de Dead Cells](https://deadcells.wiki.gg/wiki/Affixes).

Os conceitos foram gerados pelo modo integrado `image_gen`; essa ferramenta não disponibiliza seleção nem metadados que confirmem GPT-6.1 Sol Medium. Portanto, o modelo solicitado não pôde ser verificado. A composição foi redimensionada com vizinho mais próximo e remapeada à paleta HUD Caldeira local.

```

### `docs/README.md` shop summary

```text


- Loja de sucata: salas após os combates 3 e 7 por andar, vendedor pixelado com retrato de fala, compras com sucata temporária, pausa, saída e minimapa integrados. Arte separada: atlas de cinco expressões mais amigáveis, guiado por retratos de Stardew Valley (quadros ainda sem integração no runtime). Registro e pareceres: specs/2026-11-17-loja-sucata/implementacao.md. Muse R5 da loja, R3 do retrato e R4 da arte amigável aprovado em 48/64 px; 32 px foi stress visual. Sem testes/Godot.

- Itens de loja com raridades: duas lojas após os combates 3 e 7; dez itens em cinco faixas provisórias, com cartas e perks por nível. Cinco novos itens adicionam sucata por retorno, velocidade de retorno, aceleração por rebote no cenário, restituição de dash no ar e redução de cooldown após dano aceito. Efeitos e economia ainda precisam de balanceamento. Detalhes: specs/2026-11-17-loja-sucata/implementacao.md.

```

## Item art artifacts (SHA-256)

[
  {
    "path": "assets/shop/items/bobina_ritmo-prompt.txt",
    "sha256": "17f652534a497323b4c54e55bf66650210dea6fde2811ba111bad310ebf07947",
    "bytes": 1014
  },
  {
    "path": "assets/shop/items/bobina_ritmo.png",
    "sha256": "c4f6d9272d29c95334edf1d10a63e49093b5a71f64c539b06e4d06c9d2bbb869",
    "bytes": 824
  },
  {
    "path": "assets/shop/items/catraca_sucata-prompt.txt",
    "sha256": "9c66d5e3aa12b7d7a31cbfe678d4b8fdc7d766f7c14c3e35378824834c2cd2d7",
    "bytes": 992
  },
  {
    "path": "assets/shop/items/catraca_sucata.png",
    "sha256": "c5a2d53e3437ac0427e0718b70dc847710bc5aa6805508c708345d5b9e7397a2",
    "bytes": 1050
  },
  {
    "path": "assets/shop/items/fusivel_emergencia-prompt.txt",
    "sha256": "5c18664f28b0df1527e3a3076b735c8eb83711b2f7dc5c35285d52b4efd625e7",
    "bytes": 1048
  },
  {
    "path": "assets/shop/items/fusivel_emergencia.png",
    "sha256": "fdd2a8750cc529cb592ad20ab4259f0f3a6a477bb4b2313450bc1928726acded",
    "bytes": 525
  },
  {
    "path": "assets/shop/items/preview/bobina_ritmo-8x.png",
    "sha256": "afa5e80b36e9346352eb32bc59f316574a2b5f0e7b86637c283f4e5404293032",
    "bytes": 1910
  },
  {
    "path": "assets/shop/items/preview/catraca_sucata-8x.png",
    "sha256": "0fd1ab67a61243574782540ddcc0004bbbd1ff96aa43ef1536ff8f2f54f2c24c",
    "bytes": 2306
  },
  {
    "path": "assets/shop/items/preview/fusivel_emergencia-8x.png",
    "sha256": "92e5fccc2e681fb4dc6a3b222970c6b24c2971ce4efdf51e3b4b058455ce6322",
    "bytes": 1499
  },
  {
    "path": "assets/shop/items/preview/rolamento_livre-8x.png",
    "sha256": "91ef21c501740f63945319f40302249e00f9f1450c368e3fc0b375a579af7152",
    "bytes": 1950
  },
  {
    "path": "assets/shop/items/preview/turbina_centrifuga-8x.png",
    "sha256": "5005bdd605cb37e7ef7a6da566cc3b143d5e63a89be72a36ab80d4c3f9a2982d",
    "bytes": 2132
  },
  {
    "path": "assets/shop/items/rolamento_livre-prompt.txt",
    "sha256": "a7f704a1315a0af0d1e907d9c2c41bce0c1d1f8d67102e7a2141e3d1bc0ca2f8",
    "bytes": 1046
  },
  {
    "path": "assets/shop/items/rolamento_livre.png",
    "sha256": "d80dcfcd5482a57232b7dedf7a192aac3d8722cd5143894f551179e61db1d508",
    "bytes": 799
  },
  {
    "path": "assets/shop/items/source/bobina_ritmo-concept.png",
    "sha256": "94a74704c7971b921e27fe14b58b6bed14209ce788f99d0c599f7e78abf1f17b",
    "bytes": 811935
  },
  {
    "path": "assets/shop/items/source/catraca_sucata-concept.png",
    "sha256": "70bc71c8e2b21921e35d95a8d5a353459672bf217c57a251a2bc040cd16300fb",
    "bytes": 870371
  },
  {
    "path": "assets/shop/items/source/fusivel_emergencia-concept.png",
    "sha256": "c93c1988fdcae99b0f81a942a8a7a259bcdd449e0c047c8696536d617f3cb674",
    "bytes": 588553
  },
  {
    "path": "assets/shop/items/source/rolamento_livre-concept.png",
    "sha256": "158d027d1741c62996938897a3b2e163c3dd24a542283214d79ccb0595851772",
    "bytes": 1182350
  },
  {
    "path": "assets/shop/items/source/turbina_centrifuga-concept.png",
    "sha256": "86204a7f88eddc52a204b2aad06cb0a907a647b31da42c7bd9048c4e94b6c8d8",
    "bytes": 950527
  },
  {
    "path": "assets/shop/items/turbina_centrifuga-prompt.txt",
    "sha256": "52e83f738b4b5dd563f3a1437533cf419355e9d764fbe9fb670491c01a06c655",
    "bytes": 1001
  },
  {
    "path": "assets/shop/items/turbina_centrifuga.png",
    "sha256": "4555c8ce1edba4ef872ced31c01359958b59c68898c9c7e0491f2dbaed8bd37c",
    "bytes": 910
  }
]
