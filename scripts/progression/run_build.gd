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
var _rolamento_livre_damage_pending: bool = false

func _init() -> void:
	_clear_state()

func add_upgrade(upgrade_id: StringName) -> bool:
	var current_rank := count_for(upgrade_id)
	if total_count() >= MAX_UPGRADES or not UpgradeCatalogScript.can_acquire(upgrade_id, current_rank):
		return false
	if not UpgradeCatalogScript.prerequisites_met(upgrade_id, _counts_by_id):
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

func mark_rolamento_livre_damage_pending() -> bool:
	if item_level_for(&"rolamento_livre") <= 0:
		return false
	_rolamento_livre_damage_pending = true
	return true

func has_rolamento_livre_damage_pending() -> bool:
	return _rolamento_livre_damage_pending and item_level_for(&"rolamento_livre") > 0

func consume_rolamento_livre_damage_pending() -> bool:
	if not has_rolamento_livre_damage_pending():
		return false
	_rolamento_livre_damage_pending = false
	return true

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
	item_levels_by_id: Variant = {},
	rolamento_livre_damage_pending: bool = false
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

	for upgrade_id in normalized_ids:
		if not UpgradeCatalogScript.prerequisites_met(upgrade_id, normalized_counts):
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
	if rolamento_livre_damage_pending and int(normalized_items.get(&"rolamento_livre", 0)) <= 0:
		return false

	_counts_by_id = normalized_counts
	_item_levels_by_id = normalized_items
	_rolamento_livre_damage_pending = rolamento_livre_damage_pending
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
		"rolamento_livre_damage_pending": has_rolamento_livre_damage_pending(),
	}

func clear() -> void:
	_clear_state()

static func is_known_upgrade_id(upgrade_id: Variant) -> bool:
	return UpgradeCatalogScript.is_known_upgrade_id(upgrade_id)

static func known_upgrade_ids() -> Array[StringName]:
	return UpgradeCatalogScript.known_upgrade_ids()

func _clear_state() -> void:
	_rolamento_livre_damage_pending = false
	_counts_by_id.clear()
	for upgrade_id in known_upgrade_ids():
		_counts_by_id[upgrade_id] = 0
	_item_levels_by_id.clear()
	for item_id in ShopItemCatalogScript.known_item_ids():
		_item_levels_by_id[item_id] = 0
