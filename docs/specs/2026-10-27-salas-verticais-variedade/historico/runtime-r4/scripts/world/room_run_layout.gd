extends RefCounted

## Builds a deterministic, linear room plan before any room scene enters the tree.
const HORIZONTAL_FAMILIES: Array[StringName] = [&"catwalk", &"ridge", &"valley"]
const ROOF_FAMILIES: Array[StringName] = [&"roof_four", &"roof_five"]
const LEFT := Vector2i(-1, 0)
const RIGHT := Vector2i(1, 0)
const UP := Vector2i(0, -1)
const DOWN := Vector2i(0, 1)

static func resolve_seed(requested_seed: int, randomize_seed: bool) -> int:
	if not randomize_seed:
		return requested_seed
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	return rng.randi()

static func build_floor(run_seed: int, floor_index: int, room_count: int, previous_family: StringName) -> Dictionary:
	if room_count < 1:
		return {"valid": false, "error": "run precisa de ao menos uma sala por andar", "rooms": []}
	var topology_rng := RandomNumberGenerator.new()
	topology_rng.seed = _derived_seed([run_seed, floor_index, 0x544F504F])
	var horizontal := RIGHT if topology_rng.randi_range(0, 1) == 0 else LEFT
	var link_count := room_count - 1
	var reserved_vertical := -1
	if link_count >= 2:
		var first_candidate := 1 if horizontal == LEFT else 0
		reserved_vertical = topology_rng.randi_range(first_candidate, link_count - 1)
	var coords: Array[Vector2i] = [Vector2i.ZERO]
	var exits: Array[Vector2i] = []
	var exit_offsets: Array[float] = []
	var vertical_sign_by_column: Dictionary = {}
	var vertical_used_by_column: Dictionary = {}
	var current := Vector2i.ZERO
	for link_index in link_count:
		var incoming := LEFT
		if not exits.is_empty():
			var last_move: Vector2i = exits.back()
			incoming = Vector2i(-last_move.x, -last_move.y)
		var must_vertical := (link_index == reserved_vertical or (link_index == 0 and horizontal == LEFT)) and not bool(vertical_used_by_column.get(str(current.x), false))
		var candidates: Array[Vector2i] = []
		var column_key := str(current.x)
		var fixed_sign := int(vertical_sign_by_column.get(column_key, 0))
		if must_vertical:
			if fixed_sign != 0:
				candidates.append(UP if fixed_sign < 0 else DOWN)
			else:
				candidates.append(UP)
				candidates.append(DOWN)
		else:
			candidates.append(horizontal)
			if not bool(vertical_used_by_column.get(column_key, false)):
				if fixed_sign == 0:
					candidates.append(UP)
					candidates.append(DOWN)
				else:
					candidates.append(UP if fixed_sign < 0 else DOWN)
		var legal: Array[Vector2i] = []
		for direction in candidates:
			if direction == incoming:
				continue
			if direction.x == 0:
				var old_sign := int(vertical_sign_by_column.get(column_key, 0))
				if old_sign != 0 and signi(direction.y) != old_sign:
					continue
			legal.append(direction)
		if legal.is_empty():
			return {"valid": false, "error": "não foi possível escolher ligação sem retorno na coordenada %s" % str(current), "rooms": []}
		var chosen: Vector2i = legal[topology_rng.randi_range(0, legal.size() - 1)]
		if chosen.x == 0:
			vertical_sign_by_column[column_key] = signi(chosen.y)
			vertical_used_by_column[column_key] = true
		var offset := 496.0 if chosen.x != 0 else (248.0 if topology_rng.randi_range(0, 1) == 0 else 904.0)
		exits.append(chosen)
		exit_offsets.append(offset)
		current += chosen
		coords.append(current)

	var rooms: Array[Dictionary] = []
	var prior := previous_family
	for room_index in room_count:
		var entry: Vector2i = LEFT if room_index == 0 else Vector2i(-exits[room_index - 1].x, -exits[room_index - 1].y)
		var exit_dir: Vector2i
		var exit_offset: float
		if room_index < link_count:
			exit_dir = exits[room_index]
			exit_offset = exit_offsets[room_index]
		else:
			var terminal_candidates: Array[Vector2i] = [horizontal, UP, DOWN]
			for candidate in terminal_candidates:
				if candidate != entry:
					exit_dir = candidate
					break
			if exit_dir == Vector2i.ZERO:
				exit_dir = LEFT if entry != LEFT else RIGHT
			exit_offset = 496.0 if exit_dir.x != 0 else (248.0 if topology_rng.randi_range(0, 1) == 0 else 904.0)
		if exit_dir == DOWN and entry.x != 0:
			exit_offset = 904.0 if entry == LEFT else 248.0
			if room_index < link_count:
				exit_offsets[room_index] = exit_offset
		if exit_dir == entry:
			return {"valid": false, "error": "saída coincide com entrada na sala %d" % (room_index + 1), "rooms": []}
		var needs_roof := entry == UP or exit_dir == UP
		var family_candidates: Array[StringName] = ROOF_FAMILIES if needs_roof else HORIZONTAL_FAMILIES
		var available: Array[StringName] = []
		for family in family_candidates:
			if family != prior:
				available.append(family)
		if available.is_empty():
			available = family_candidates.duplicate()
		var family_rng := RandomNumberGenerator.new()
		family_rng.seed = _derived_seed([run_seed, floor_index, room_index, 0x46414D49])
		var family: StringName = available[family_rng.randi_range(0, available.size() - 1)]
		prior = family
		var room_seed := _derived_seed([run_seed, floor_index, room_index, 0x524F4F4D])
		var entry_offset := 496.0 if entry.x != 0 else exit_offsets[room_index - 1]
		if room_index == 0:
			entry_offset = 496.0
		rooms.append({
			"room_seed": room_seed,
			"family": family,
			"entry_dir": entry,
			"exit_dir": exit_dir,
			"coord": coords[room_index],
			"entry_offset": entry_offset,
			"exit_offset": exit_offset,
		})
	return {"valid": true, "rooms": rooms, "last_family": prior, "horizontal_direction": horizontal}

static func opposite(direction: Vector2i) -> Vector2i:
	return Vector2i(-direction.x, -direction.y)

static func _derived_seed(parts: Array) -> int:
	var seed_value := int(hash(parts))
	return 1 if seed_value == 0 else seed_value
