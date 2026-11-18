extends RefCounted

## One-shot scene snapshot; it contains primitive data, never a live Resource.
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
		"version": 2,
		"canonical_destination": canonical_destination,
		"hp_current": current_health,
		"hp_max": maximum_health,
		"upgrade_ids": build_data.get("upgrade_ids"),
		"counts_by_id": build_data.get("counts_by_id"),
		"item_ids": build_data.get("item_ids"),
		"item_levels_by_id": build_data.get("item_levels_by_id"),
		"rolamento_livre_damage_pending": build_data.get("rolamento_livre_damage_pending", false),
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
	var raw_version: Variant = snapshot.get("version")
	if typeof(raw_version) != TYPE_INT:
		return false
	var snapshot_version := int(raw_version)
	if snapshot_version != 1 and snapshot_version != 2:
		return false
	var required_keys: Array[String] = [
		"version", "canonical_destination", "hp_current", "hp_max", "upgrade_ids", "counts_by_id"
	]
	var has_item_ids: bool = snapshot.has("item_ids")
	var has_item_levels: bool = snapshot.has("item_levels_by_id")
	if has_item_ids != has_item_levels:
		return false
	if has_item_ids:
		required_keys.append("item_ids")
		required_keys.append("item_levels_by_id")
	var has_rolamento_pending: bool = snapshot.has("rolamento_livre_damage_pending")
	if snapshot_version == 2:
		if not has_rolamento_pending or typeof(snapshot["rolamento_livre_damage_pending"]) != TYPE_BOOL:
			return false
		required_keys.append("rolamento_livre_damage_pending")
	elif has_rolamento_pending:
		return false
	if snapshot.size() != required_keys.size():
		return false
	for key in required_keys:
		if not snapshot.has(key):
			return false
	if int(snapshot["version"]) != snapshot_version:
		return false
	if typeof(snapshot["canonical_destination"]) != TYPE_STRING:
		return false
	if String(snapshot["canonical_destination"]) != expected_destination:
		return false
	if typeof(snapshot["hp_current"]) != TYPE_INT or typeof(snapshot["hp_max"]) != TYPE_INT:
		return false
	var current_health := int(snapshot["hp_current"])
	var maximum_health := int(snapshot["hp_max"])
	if maximum_health < 1 or maximum_health > 100 or current_health < 1 or current_health > maximum_health:
		return false
	if typeof(snapshot["upgrade_ids"]) != TYPE_ARRAY or typeof(snapshot["counts_by_id"]) != TYPE_DICTIONARY:
		return false
	var item_ids: Variant = snapshot.get("item_ids", [])
	var item_levels: Variant = snapshot.get("item_levels_by_id", {})
	if typeof(item_ids) != TYPE_ARRAY or typeof(item_levels) != TYPE_DICTIONARY:
		return false
	for upgrade_id in snapshot["upgrade_ids"]:
		if typeof(upgrade_id) != TYPE_STRING:
			return false
	for upgrade_id in snapshot["counts_by_id"].keys():
		if typeof(upgrade_id) != TYPE_STRING:
			return false
	for item_id in item_ids:
		if typeof(item_id) != TYPE_STRING:
			return false
	for item_id in item_levels.keys():
		if typeof(item_id) != TYPE_STRING:
			return false
	var validated_build := RunBuild.new()
	return validated_build.replace_state(
		snapshot["upgrade_ids"],
		snapshot["counts_by_id"],
		item_ids,
		item_levels,
		bool(snapshot.get("rolamento_livre_damage_pending", false))
	)

static func _is_canonical_resource_path(path: String) -> bool:
	return path.begins_with("res://") and path.length() > "res://".length()
