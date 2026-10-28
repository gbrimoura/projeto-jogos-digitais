extends RefCounted

## Snapshot simples e one-shot que atravessa uma troca de cena. Não persiste
## RunBuild nem qualquer Resource vivo.

const RunBuild = preload("res://scripts/progression/run_build.gd")

static var _pending_snapshot: Dictionary = {}

static func prepare_run_snapshot(
	destination_scene: PackedScene,
	current_health: Variant,
	maximum_health: Variant,
	build: RunBuild
) -> bool:
	_pending_snapshot.clear()
	if destination_scene == null or not is_instance_valid(destination_scene) or build == null:
		return false
	if typeof(current_health) != TYPE_INT or typeof(maximum_health) != TYPE_INT:
		return false

	var canonical_destination := destination_scene.resource_path
	if not _is_canonical_resource_path(canonical_destination):
		return false
	var build_data := build.to_snapshot_data()
	var snapshot := {
		"version": 1,
		"canonical_destination": canonical_destination,
		"hp_current": current_health,
		"hp_max": maximum_health,
		"upgrade_ids": build_data.get("upgrade_ids"),
		"counts_by_id": build_data.get("counts_by_id"),
	}
	if not _is_valid_snapshot(snapshot, canonical_destination):
		return false
	_pending_snapshot = snapshot.duplicate(true)
	return true

static func consume_pending_snapshot(destination_scene: PackedScene) -> Dictionary:
	if _pending_snapshot.is_empty():
		return {}
	var snapshot := _pending_snapshot.duplicate(true)
	_pending_snapshot.clear()
	if destination_scene == null or not is_instance_valid(destination_scene):
		return {}
	var canonical_destination := destination_scene.resource_path
	if not _is_canonical_resource_path(canonical_destination):
		return {}
	if not _is_valid_snapshot(snapshot, canonical_destination):
		return {}
	return snapshot.duplicate(true)

static func clear_pending_snapshot() -> void:
	_pending_snapshot.clear()

static func _is_valid_snapshot(snapshot: Variant, expected_destination: String) -> bool:
	if typeof(snapshot) != TYPE_DICTIONARY or not _is_canonical_resource_path(expected_destination):
		return false
	var required_keys: Array[String] = [
		"version",
		"canonical_destination",
		"hp_current",
		"hp_max",
		"upgrade_ids",
		"counts_by_id",
	]
	if snapshot.size() != required_keys.size():
		return false
	for key in required_keys:
		if not snapshot.has(key):
			return false
	if typeof(snapshot["version"]) != TYPE_INT or int(snapshot["version"]) != 1:
		return false
	if typeof(snapshot["canonical_destination"]) != TYPE_STRING:
		return false
	if String(snapshot["canonical_destination"]) != expected_destination:
		return false
	if typeof(snapshot["hp_current"]) != TYPE_INT or typeof(snapshot["hp_max"]) != TYPE_INT:
		return false
	var current_health := int(snapshot["hp_current"])
	var maximum_health := int(snapshot["hp_max"])
	# PlayerHealth.restore_health_for_room_transition aceita somente máximo 1..100.
	if maximum_health < 1 or maximum_health > 100 or current_health < 1 or current_health > maximum_health:
		return false
	if typeof(snapshot["upgrade_ids"]) != TYPE_ARRAY or typeof(snapshot["counts_by_id"]) != TYPE_DICTIONARY:
		return false
	for upgrade_id in snapshot["upgrade_ids"]:
		if typeof(upgrade_id) != TYPE_STRING:
			return false
	for upgrade_id in snapshot["counts_by_id"].keys():
		if typeof(upgrade_id) != TYPE_STRING:
			return false
	var validated_build := RunBuild.new()
	return validated_build.replace_state(snapshot["upgrade_ids"], snapshot["counts_by_id"])

static func _is_canonical_resource_path(path: String) -> bool:
	return path.begins_with("res://") and path.length() > "res://".length()
