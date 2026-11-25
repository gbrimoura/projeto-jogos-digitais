extends RefCounted

# Arquivo exclusivo da progressão da oficina; configurações do jogador ficam separadas.
const PATH := "user://iris_workshop.cfg"
const TEMP := "user://iris_workshop.tmp"
const BACKUP := "user://iris_workshop.bak"
const MAX_RANK := 2
const MAX_MARKS := 999_999
const PENDING_MARKS := &"iris_workshop_pending_marks"

static func read_state() -> Dictionary:
	var primary_exists := FileAccess.file_exists(PATH)
	var primary := _read_file(PATH) if primary_exists else {"valid": false}
	if bool(primary.get("valid", false)):
		return primary
	if FileAccess.file_exists(BACKUP):
		return _read_file(BACKUP)
	if primary_exists:
		return {"valid": false}
	return {"valid": true, "marks": 0, "health": 0, "scrap": 0}

static func _read_file(path: String) -> Dictionary:
	var cfg := ConfigFile.new()
	if cfg.load(path) != OK:
		return {"valid": false}
	for key in ["marks", "health", "scrap"]:
		if not cfg.has_section_key("workshop", key):
			return {"valid": false}
	var marks: Variant = cfg.get_value("workshop", "marks")
	var health: Variant = cfg.get_value("workshop", "health", null)
	var scrap: Variant = cfg.get_value("workshop", "scrap", null)
	if typeof(marks) != TYPE_INT or typeof(health) != TYPE_INT or typeof(scrap) != TYPE_INT:
		return {"valid": false}
	if marks < 0 or marks > MAX_MARKS or health < 0 or health > MAX_RANK or scrap < 0 or scrap > MAX_RANK:
		return {"valid": false}
	return {"valid": true, "marks": marks, "health": health, "scrap": scrap}

static func _write_state(state: Dictionary) -> bool:
	if not bool(read_state().get("valid", false)):
		return false
	var cfg := ConfigFile.new()
	for key in ["marks", "health", "scrap"]:
		cfg.set_value("workshop", key, state[key])
	if cfg.save(TEMP) != OK:
		return false
	var verified := _read_file(TEMP)
	if not bool(verified.get("valid", false)):
		return false
	for key in ["marks", "health", "scrap"]:
		if verified[key] != state[key]:
			return false
	var dir := DirAccess.open("user://")
	if dir == null:
		return false
	if FileAccess.file_exists(PATH):
		if bool(_read_file(PATH).get("valid", false)):
			if FileAccess.file_exists(BACKUP) and dir.remove("iris_workshop.bak") != OK:
				return false
			if dir.rename("iris_workshop.cfg", "iris_workshop.bak") != OK:
				return false
		else:
			var archived := "iris_workshop-danificado-%d-%d.cfg" % [OS.get_process_id(), Time.get_ticks_usec()]
			if dir.rename("iris_workshop.cfg", archived) != OK:
				return false
	# Se a troca falhar, o backup ainda é legível. O temporário pode ser refeito.
	if dir.rename("iris_workshop.tmp", "iris_workshop.cfg") != OK:
		return false
	if FileAccess.file_exists(BACKUP):
		dir.remove("iris_workshop.bak")
	return true

static func price_for(rank: int) -> int:
	if rank < 0 or rank >= MAX_RANK:
		return 0
	return 2 if rank == 0 else 4

static func buy(kind: String) -> bool:
	var state := read_state()
	if not bool(state.get("valid", false)) or kind not in ["health", "scrap"]:
		return false
	var rank: int = state[kind]
	if rank >= MAX_RANK:
		return false
	var cost := price_for(rank)
	if int(state.marks) < cost:
		return false
	state.marks -= cost
	state[kind] = rank + 1
	return _write_state(state)

static func pending_marks(tree: SceneTree) -> int:
	return int(tree.get_meta(PENDING_MARKS, 0))

static func stage_reward(tree: SceneTree, amount: int) -> void:
	if amount > 0:
		tree.set_meta(PENDING_MARKS, mini(pending_marks(tree) + amount, MAX_MARKS))

static func save_pending_rewards(tree: SceneTree) -> bool:
	var amount := pending_marks(tree)
	if amount == 0:
		return true
	if not _credit(amount):
		return false
	tree.remove_meta(PENDING_MARKS)
	return true

static func _credit(amount: int) -> bool:
	if amount <= 0:
		return true
	var state := read_state()
	if not bool(state.get("valid", false)):
		return false
	state.marks = int(state.marks) + mini(amount, MAX_MARKS - int(state.marks))
	return _write_state(state)
