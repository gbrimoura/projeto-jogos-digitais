class_name RunBuild
extends RefCounted

## Estado temporário da run. Recursos de definição e configurações não são
## armazenados aqui; snapshots são compostos apenas de Strings, ints, Arrays e
## Dictionaries.

const IMPACTO_REFORCADO: StringName = &"impacto_reforcado"
const MOTOR_ACELERADO: StringName = &"motor_acelerado"
const CARGA_REATIVA: StringName = &"carga_reativa"
const MAX_UPGRADES: int = 1

var _counts_by_id: Dictionary = {}

func _init() -> void:
	_clear_counts()

func add_upgrade(upgrade_id: StringName) -> bool:
	if not is_known_upgrade_id(upgrade_id) or total_count() >= MAX_UPGRADES:
		return false
	if int(_counts_by_id.get(upgrade_id, 0)) != 0:
		return false
	_counts_by_id[upgrade_id] = 1
	return true

func has_upgrade(upgrade_id: StringName) -> bool:
	return is_known_upgrade_id(upgrade_id) and int(_counts_by_id.get(upgrade_id, 0)) == 1

func count_for(upgrade_id: StringName) -> int:
	return int(_counts_by_id.get(upgrade_id, 0)) if is_known_upgrade_id(upgrade_id) else 0

func total_count() -> int:
	var total := 0
	for upgrade_id in known_upgrade_ids():
		total += int(_counts_by_id.get(upgrade_id, 0))
	return total

func get_upgrade_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for upgrade_id in known_upgrade_ids():
		if int(_counts_by_id.get(upgrade_id, 0)) == 1:
			result.append(upgrade_id)
	return result

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
		if normalized_ids.size() > MAX_UPGRADES:
			return false

	var normalized_counts: Dictionary = {}
	var seen_count_ids: Dictionary = {}
	for upgrade_id in known_upgrade_ids():
		normalized_counts[upgrade_id] = 0

	for raw_id in counts_by_id.keys():
		if typeof(raw_id) != TYPE_STRING and typeof(raw_id) != TYPE_STRING_NAME:
			return false
		var upgrade_id := StringName(raw_id)
		if not is_known_upgrade_id(upgrade_id):
			return false
		if seen_count_ids.has(upgrade_id):
			return false
		var count: Variant = counts_by_id[raw_id]
		if typeof(count) != TYPE_INT or int(count) < 0 or int(count) > 1:
			return false
		seen_count_ids[upgrade_id] = true
		normalized_counts[upgrade_id] = int(count)

	var ids_from_counts: Array[StringName] = []
	for upgrade_id in known_upgrade_ids():
		if int(normalized_counts[upgrade_id]) == 1:
			ids_from_counts.append(upgrade_id)
	if ids_from_counts.size() > MAX_UPGRADES or ids_from_counts.size() != normalized_ids.size():
		return false
	for upgrade_id in normalized_ids:
		if not ids_from_counts.has(upgrade_id):
			return false

	_counts_by_id = normalized_counts
	return true

func to_snapshot_data() -> Dictionary:
	var id_strings: Array[String] = []
	var counts: Dictionary = {}
	for upgrade_id in known_upgrade_ids():
		var count := int(_counts_by_id.get(upgrade_id, 0))
		counts[String(upgrade_id)] = count
		if count == 1:
			id_strings.append(String(upgrade_id))
	return {
		"upgrade_ids": id_strings,
		"counts_by_id": counts,
	}

func clear() -> void:
	_clear_counts()

static func is_known_upgrade_id(upgrade_id: Variant) -> bool:
	if typeof(upgrade_id) != TYPE_STRING and typeof(upgrade_id) != TYPE_STRING_NAME:
		return false
	match String(upgrade_id):
		"impacto_reforcado", "motor_acelerado", "carga_reativa":
			return true
	return false

static func known_upgrade_ids() -> Array[StringName]:
	return [IMPACTO_REFORCADO, MOTOR_ACELERADO, CARGA_REATIVA]

func _clear_counts() -> void:
	_counts_by_id.clear()
	for upgrade_id in known_upgrade_ids():
		_counts_by_id[upgrade_id] = 0
