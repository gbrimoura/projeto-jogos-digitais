class_name RunBuild
extends RefCounted

## Estado temporário da run. Snapshots usam somente Strings, ints, Arrays e
## Dictionaries; efeitos e limites pertencem ao catálogo.

const UpgradeCatalogScript = preload("res://scripts/progression/upgrade_catalog.gd")
const IMPACTO_REFORCADO: StringName = &"impacto_reforcado"
const MOTOR_ACELERADO: StringName = &"motor_acelerado"
const CARGA_REATIVA: StringName = &"carga_reativa"
const MAX_UPGRADES: int = UpgradeCatalogScript.MAX_RUN_ACQUISITIONS

var _counts_by_id: Dictionary = {}

func _init() -> void:
	_clear_counts()

func add_upgrade(upgrade_id: StringName) -> bool:
	var current_rank := count_for(upgrade_id)
	if total_count() >= MAX_UPGRADES or not UpgradeCatalogScript.can_acquire(upgrade_id, current_rank):
		return false
	_counts_by_id[upgrade_id] = current_rank + 1
	return true

func has_upgrade(upgrade_id: StringName) -> bool:
	return count_for(upgrade_id) > 0

func count_for(upgrade_id: StringName) -> int:
	return int(_counts_by_id.get(upgrade_id, 0)) if is_known_upgrade_id(upgrade_id) else 0

func total_count() -> int:
	return UpgradeCatalogScript.total_rank_count(_counts_by_id)

func get_upgrade_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for upgrade_id in known_upgrade_ids():
		if count_for(upgrade_id) > 0:
			result.append(upgrade_id)
	return result

## Fully validates the incoming legacy/new snapshot before replacing live state.
func replace_state(upgrade_ids: Variant, counts_by_id: Variant) -> bool:
	if typeof(upgrade_ids) != TYPE_ARRAY or typeof(counts_by_id) != TYPE_DICTIONARY:
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

	_counts_by_id = normalized_counts
	return true

func to_snapshot_data() -> Dictionary:
	var id_strings: Array[String] = []
	var counts: Dictionary = {}
	for upgrade_id in known_upgrade_ids():
		var rank := count_for(upgrade_id)
		counts[String(upgrade_id)] = rank
		if rank > 0:
			id_strings.append(String(upgrade_id))
	return {"upgrade_ids": id_strings, "counts_by_id": counts}

func clear() -> void:
	_clear_counts()

static func is_known_upgrade_id(upgrade_id: Variant) -> bool:
	return UpgradeCatalogScript.is_known_upgrade_id(upgrade_id)

static func known_upgrade_ids() -> Array[StringName]:
	return UpgradeCatalogScript.known_upgrade_ids()

func _clear_counts() -> void:
	_counts_by_id.clear()
	for upgrade_id in known_upgrade_ids():
		_counts_by_id[upgrade_id] = 0
