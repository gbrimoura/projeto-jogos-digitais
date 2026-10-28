extends RefCounted

const MIN_PLATFORM_COUNT := 2
const MAX_PLATFORM_COUNT := 5
const MIN_RANDOM_WIDTH := 160
const MIN_FALLBACK_WIDTH := 104
const MAX_PLATFORM_WIDTH := 216
const PLATFORM_THICKNESS := 24
const GAP_MIN := 56
const GAP_MAX := 96
const FIRST_LEFT_MIN := 208
const FIRST_LEFT_MAX := 256
const RIGHT_LIMIT := 980
const FIRST_TOP := 440
const TOP_LIMIT := 376
const MAX_RISE_PER_STEP := 64

static func generate_managed_layout(
	family: StringName,
	requested_seed: int,
	entry_dir: Vector2i,
	exit_dir: Vector2i,
	entry_offset: float,
	exit_offset: float,
	force_canonical: bool = false
) -> Dictionary:
	var seed_used := 1 if requested_seed == 0 else requested_seed
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_used
	if not [&"catwalk", &"ridge", &"valley", &"roof_four", &"roof_five"].has(family):
		return _invalid_result(seed_used, "família gerenciada desconhecida: %s" % String(family))
	if force_canonical:
		return _managed_layout_result(
			_canonical_managed_entries(family, entry_dir, exit_dir, entry_offset, exit_offset),
			family, seed_used, entry_dir, exit_dir, entry_offset, exit_offset, true
		)
	for _attempt in 12:
		var entries := _build_managed_entries(family, rng, entry_dir, exit_dir, entry_offset, exit_offset)
		if _managed_entries_are_safe(entries, family, entry_dir, exit_dir, entry_offset, exit_offset):
			return _managed_layout_result(entries, family, seed_used, entry_dir, exit_dir, entry_offset, exit_offset, false)
	var canonical := _canonical_managed_entries(family, entry_dir, exit_dir, entry_offset, exit_offset)
	if _managed_entries_are_safe(canonical, family, entry_dir, exit_dir, entry_offset, exit_offset):
		return _managed_layout_result(canonical, family, seed_used, entry_dir, exit_dir, entry_offset, exit_offset, true)
	return _invalid_result(seed_used, "fallback canônico da família %s falhou no contrato geométrico" % String(family))

static func _managed_layout_result(
	entries: Array[Dictionary],
	family: StringName,
	seed_used: int,
	entry_dir: Vector2i,
	exit_dir: Vector2i,
	entry_offset: float,
	exit_offset: float,
	used_fallback: bool
) -> Dictionary:
	var primary_index := 0
	var fallback_index := mini(1, entries.size() - 1)
	if family == &"roof_four" or family == &"roof_five":
		primary_index = mini(1, entries.size() - 1)
		fallback_index = 0
	if entry_dir == Vector2i(0, -1):
		primary_index = 0
		fallback_index = mini(1, entries.size() - 1)
	return {
		"valid": true,
		"platforms": entries,
		"primary_index": primary_index,
		"fallback_index": fallback_index,
		"seed": seed_used,
		"used_fallback": used_fallback,
		"family": family,
	}

static func _build_managed_entries(
	family: StringName,
	rng: RandomNumberGenerator,
	entry_dir: Vector2i,
	exit_dir: Vector2i,
	entry_offset: float,
	exit_offset: float
) -> Array[Dictionary]:
	var count := 3 if family == &"catwalk" else (5 if family == &"roof_five" else 4)
	var centers: Array[float] = []
	var tops: Array[float] = []
	var widths: Array[float] = []
	centers.resize(count)
	tops.resize(count)
	widths.resize(count)
	var is_roof := family == &"roof_four" or family == &"roof_five"
	if is_roof:
		var portal_x := entry_offset if entry_dir == Vector2i(0, -1) else exit_offset
		var horizontal_sign := -1.0 if portal_x == 248.0 else 1.0
		var allowed_steps: Array[int] = [64, 72, 80] if family == &"roof_five" else [80, 88, 96, 104, 112]
		var rises: Array[int] = []
		for _tries in 40:
			rises.clear()
			var total := 0
			for _step in count - 1:
				var rise: int = allowed_steps[rng.randi_range(0, allowed_steps.size() - 1)]
				rises.append(rise)
				total += rise
			if total == 288:
				break
		var rise_sum := 0
		for rise in rises:
			rise_sum += rise
		if rises.size() != count - 1 or rise_sum != 288:
			rises.clear()
			rises.resize(count - 1)
			for index in rises.size():
				rises[index] = 72 if family == &"roof_five" else 96
		tops[0] = 448.0
		for index in count - 1:
			tops[index + 1] = tops[index] - float(rises[index])
		for index in count:
			widths[index] = 104.0 + float(rng.randi_range(0, 3) * 8) if family == &"roof_five" else 144.0 + float(rng.randi_range(0, 4) * 8)
		centers[count - 1] = portal_x
		for index in range(count - 1, 0, -1):
			var gap := float(40 + rng.randi_range(0, 5) * 8)
			var center_step := widths[index] * 0.5 + widths[index - 1] * 0.5 + gap
			centers[index - 1] = centers[index] - horizontal_sign * center_step
	else:
		var base_tops: Array[float]
		if family == &"catwalk":
			base_tops = [448.0, 400.0, 448.0]
		elif family == &"ridge":
			base_tops = [448.0, 384.0, 352.0, 416.0]
		else:
			base_tops = [400.0, 448.0, 448.0, 400.0]
		for index in count:
			var offset_steps := rng.randi_range(-2, 2)
			if index == 0:
				offset_steps = rng.randi_range(-2, 0) if family != &"valley" else rng.randi_range(-1, 1)
			tops[index] = clampf(base_tops[index] + float(offset_steps * 8), 376.0, 448.0)
			widths[index] = float(144 + rng.randi_range(0, 5) * 8)
		var spawn_x := 160.0 if entry_dir == Vector2i(-1, 0) else (992.0 if entry_dir == Vector2i(1, 0) else entry_offset)
		var horizontal_sign := -1.0 if entry_dir == Vector2i(1, 0) or (entry_dir.y != 0 and spawn_x > 576.0) else 1.0
		var center_min := 240.0
		var center_max := 304.0
		if horizontal_sign < 0.0:
			center_min = 848.0
			center_max = 912.0
		if entry_dir.y != 0:
			center_min = spawn_x - 24.0
			center_max = spawn_x + 24.0
		centers[0] = float(rng.randi_range(roundi(center_min / 8.0), roundi(center_max / 8.0)) * 8)
		for index in range(1, count):
			var gap := float(48 + rng.randi_range(0, 6) * 8)
			centers[index] = centers[index - 1] + horizontal_sign * (widths[index - 1] * 0.5 + widths[index] * 0.5 + gap)
	var entries: Array[Dictionary] = []
	for index in count:
		var size := Vector2(widths[index], 16.0)
		var position := Vector2(centers[index], tops[index] + 8.0)
		var rect := Rect2(position - size * 0.5, size)
		entries.append({"position": position, "size": size, "rect": rect})
	return entries

static func _canonical_managed_entries(
	family: StringName,
	entry_dir: Vector2i,
	exit_dir: Vector2i,
	entry_offset: float,
	exit_offset: float
) -> Array[Dictionary]:
	var centers: Array[float] = []
	var tops: Array[float] = []
	var widths: Array[float] = []
	if family == &"roof_four":
		centers = [256.0, 472.0, 688.0, 904.0]
		tops = [448.0, 352.0, 256.0, 160.0]
		widths = [160.0, 160.0, 160.0, 160.0]
		var portal_x := entry_offset if entry_dir == Vector2i(0, -1) else exit_offset
		if portal_x == 248.0:
			for index in centers.size():
				centers[index] = 1152.0 - centers[index]
	elif family == &"roof_five":
		centers = [328.0, 472.0, 616.0, 760.0, 904.0]
		tops = [448.0, 376.0, 304.0, 232.0, 160.0]
		widths = [104.0, 104.0, 104.0, 104.0, 104.0]
		var portal_x := entry_offset if entry_dir == Vector2i(0, -1) else exit_offset
		if portal_x == 248.0:
			for index in centers.size():
				centers[index] = 1152.0 - centers[index]
	elif family == &"catwalk":
		centers = [256.0, 472.0, 688.0]
		tops = [448.0, 400.0, 448.0]
		widths = [160.0, 176.0, 160.0]
	elif family == &"ridge":
		centers = [256.0, 472.0, 688.0, 904.0]
		tops = [448.0, 384.0, 352.0, 416.0]
		widths = [160.0, 160.0, 160.0, 160.0]
	elif family == &"valley":
		centers = [256.0, 472.0, 688.0, 904.0]
		tops = [400.0, 448.0, 448.0, 400.0]
		widths = [160.0, 160.0, 160.0, 160.0]
	if family != &"roof_four" and family != &"roof_five":
		var spawn_right := entry_dir == Vector2i(1, 0) or (entry_dir.y != 0 and entry_offset > 576.0)
		if spawn_right:
			for index in centers.size():
				centers[index] = 1152.0 - centers[index]
	var entries: Array[Dictionary] = []
	for index in centers.size():
		var size := Vector2(widths[index], 16.0)
		var position := Vector2(centers[index], tops[index] + 8.0)
		entries.append({"position": position, "size": size, "rect": Rect2(position - size * 0.5, size)})
	return entries

static func _managed_entries_are_safe(
	entries: Array[Dictionary],
	family: StringName,
	entry_dir: Vector2i,
	exit_dir: Vector2i,
	entry_offset: float,
	exit_offset: float
) -> bool:
	var expected_count := 3 if family == &"catwalk" else (5 if family == &"roof_five" else 4)
	if entries.size() != expected_count or entry_dir == exit_dir:
		return false
	if exit_dir.x == 0 and absf(exit_offset - 248.0) > 0.01 and absf(exit_offset - 904.0) > 0.01:
		return false
	if entry_dir.x == 0 and absf(entry_offset - 248.0) > 0.01 and absf(entry_offset - 904.0) > 0.01:
		return false
	var is_roof := family == &"roof_four" or family == &"roof_five"
	if (entry_dir == Vector2i(0, -1) or exit_dir == Vector2i(0, -1)) and not is_roof:
		return false
	var previous := Rect2()
	for index in entries.size():
		var rect: Rect2 = entries[index].get("rect", Rect2())
		if rect.size.y != 16.0 or rect.size.x < MIN_FALLBACK_WIDTH or rect.size.x > MAX_PLATFORM_WIDTH:
			return false
		if rect.position.x < 64.0 or rect.end.x > 1088.0 \
			or fposmod(rect.get_center().x, 8.0) > 0.01 or fposmod(rect.size.x, 8.0) > 0.01 \
			or fposmod(rect.position.y, 8.0) > 0.01:
			return false
		if rect.position.y < 152.0 or rect.position.y > 448.0 or 560.0 - rect.end.y < 96.0:
			return false
		if index > 0:
			if rect.intersects(previous):
				return false
			var gap := maxf(rect.position.x - previous.end.x, previous.position.x - rect.end.x)
			var rise := previous.position.y - rect.position.y
			if is_roof:
				if gap < 40.0 or gap > 80.0 or rise < 64.0 or rise > 112.0:
					return false
			elif gap < 40.0 or gap > 96.0 or absf(rise) > 64.0:
				return false
		previous = rect
	if is_roof:
		var last_rect: Rect2 = entries.back().get("rect", Rect2())
		var expected := entry_offset if entry_dir == Vector2i(0, -1) else exit_offset
		if (entry_dir == Vector2i(0, -1) or exit_dir == Vector2i(0, -1)) \
			and absf(last_rect.get_center().x - expected) > 0.01:
			return false
	elif family == &"catwalk":
		if entries.size() != 3 or tops_are_not_catwalk(entries):
			return false
	elif family == &"ridge":
		if entries.size() != 4 or tops_are_not_ridge(entries):
			return false
	elif family == &"valley":
		if entries.size() != 4 or tops_are_not_valley(entries):
			return false
	return true

static func tops_are_not_catwalk(entries: Array[Dictionary]) -> bool:
	var first: Rect2 = entries[0].get("rect", Rect2())
	var middle: Rect2 = entries[1].get("rect", Rect2())
	var last: Rect2 = entries[2].get("rect", Rect2())
	return middle.position.y >= minf(first.position.y, last.position.y) - 16.0

static func tops_are_not_ridge(entries: Array[Dictionary]) -> bool:
	var first: Rect2 = entries[0].get("rect", Rect2())
	var second: Rect2 = entries[1].get("rect", Rect2())
	var third: Rect2 = entries[2].get("rect", Rect2())
	var last: Rect2 = entries[3].get("rect", Rect2())
	return minf(second.position.y, third.position.y) >= minf(first.position.y, last.position.y) - 16.0

static func tops_are_not_valley(entries: Array[Dictionary]) -> bool:
	var first: Rect2 = entries[0].get("rect", Rect2())
	var second: Rect2 = entries[1].get("rect", Rect2())
	var third: Rect2 = entries[2].get("rect", Rect2())
	var last: Rect2 = entries[3].get("rect", Rect2())
	return maxf(second.position.y, third.position.y) <= maxf(first.position.y, last.position.y) + 16.0

static func generate_layout(platform_count: int, requested_seed: int, spawn_x: float) -> Dictionary:
	var rng := RandomNumberGenerator.new()
	if requested_seed == 0:
		rng.randomize()
	else:
		rng.seed = requested_seed
	var seed_used: int = rng.seed
	if platform_count < MIN_PLATFORM_COUNT or platform_count > MAX_PLATFORM_COUNT:
		return _invalid_result(seed_used, "quantidade atual de plataformas fora do intervalo suportado (2..5)")

	var minimum_width: int = MIN_RANDOM_WIDTH if platform_count == 3 else MIN_FALLBACK_WIDTH
	var minimum_footprint := platform_count * minimum_width + (platform_count - 1) * GAP_MIN
	var spawn_left_min := ceili((spawn_x + 38.0) / 8.0) * 8
	var first_left_min := maxi(FIRST_LEFT_MIN, spawn_left_min)
	var first_left_max := mini(
		FIRST_LEFT_MAX,
		floori(float(RIGHT_LIMIT - minimum_footprint) / 8.0) * 8
	)
	var entries: Array[Dictionary] = []
	if first_left_min <= first_left_max:
		var first_left := rng.randi_range(first_left_min / 8, first_left_max / 8) * 8
		var slack_units := floori(float(RIGHT_LIMIT - first_left - minimum_footprint) / 8.0)
		var width_capacity_units := int((MAX_PLATFORM_WIDTH - minimum_width) / 8)
		var gap_capacity_units := int((GAP_MAX - GAP_MIN) / 8)
		var total_capacity_units := platform_count * width_capacity_units \
			+ (platform_count - 1) * gap_capacity_units
		# Reserva uma unidade de 8 px quando a folga permite.
		var budget_limit := mini(slack_units, total_capacity_units)
		if budget_limit > 0:
			budget_limit -= 1
		var extra_units := rng.randi_range(0, budget_limit)
		var horizontal_budget := _distribute_horizontal_budget(
			platform_count,
			minimum_width,
			extra_units,
			rng
		)
		var widths: Array[int] = horizontal_budget.get("widths", [])
		var gaps: Array[int] = horizontal_budget.get("gaps", [])
		var rises := _distribute_vertical_rise(platform_count, rng)
		var left := float(first_left)
		var previous_top := FIRST_TOP
		for index in platform_count:
			var top := FIRST_TOP if index == 0 else previous_top - rises[index - 1]
			previous_top = top
			var rect := Rect2(Vector2(left, top), Vector2(widths[index], PLATFORM_THICKNESS))
			entries.append(_entry_from_rect(rect))
			left = rect.end.x
			if index < platform_count - 1:
				left += gaps[index]

	if _entries_are_safe(entries, spawn_x):
		return _success_result(entries, seed_used, false)

	var fallback_entries := _safe_fallback(platform_count)
	if not _entries_are_safe(fallback_entries, spawn_x):
		return _invalid_result(seed_used, "fallback fixo não satisfaz os limites de sala")
	return _success_result(fallback_entries, seed_used, true)

static func _distribute_horizontal_budget(
	platform_count: int,
	minimum_width: int,
	extra_units: int,
	rng: RandomNumberGenerator
) -> Dictionary:
	var widths: Array[int] = []
	var gaps: Array[int] = []
	for index in platform_count:
		widths.append(minimum_width)
		if index < platform_count - 1:
			gaps.append(GAP_MIN)

	var slot_capacities: Array[int] = []
	var slot_is_gap: Array[bool] = []
	var slot_target_indices: Array[int] = []
	var width_capacity_units := int((MAX_PLATFORM_WIDTH - minimum_width) / 8)
	var gap_capacity_units := int((GAP_MAX - GAP_MIN) / 8)
	for index in platform_count:
		slot_capacities.append(width_capacity_units)
		slot_is_gap.append(false)
		slot_target_indices.append(index)
		if index < platform_count - 1:
			slot_capacities.append(gap_capacity_units)
			slot_is_gap.append(true)
			slot_target_indices.append(index)

	var slot_order: Array[int] = []
	for slot_index in slot_capacities.size():
		slot_order.append(slot_index)
	for index in range(slot_order.size() - 1, 0, -1):
		var swap_index := rng.randi_range(0, index)
		var previous_index: int = slot_order[index]
		slot_order[index] = slot_order[swap_index]
		slot_order[swap_index] = previous_index

	var suffix_capacity: Array[int] = []
	suffix_capacity.resize(slot_order.size() + 1)
	suffix_capacity[slot_order.size()] = 0
	for offset in slot_order.size():
		var position := slot_order.size() - 1 - offset
		suffix_capacity[position] = suffix_capacity[position + 1] + slot_capacities[slot_order[position]]

	var remaining_units := extra_units
	for position in slot_order.size():
		var slot_index: int = slot_order[position]
		var minimum_allocation := maxi(0, remaining_units - suffix_capacity[position + 1])
		var maximum_allocation := mini(slot_capacities[slot_index], remaining_units)
		var allocation := rng.randi_range(minimum_allocation, maximum_allocation)
		if slot_is_gap[slot_index]:
			gaps[slot_target_indices[slot_index]] += allocation * 8
		else:
			widths[slot_target_indices[slot_index]] += allocation * 8
		remaining_units -= allocation

	return {"widths": widths, "gaps": gaps}

static func _distribute_vertical_rise(
	platform_count: int,
	rng: RandomNumberGenerator
) -> Array[int]:
	var edge_count := platform_count - 1
	var remaining_units := rng.randi_range(0, MAX_RISE_PER_STEP / 8)
	var rises: Array[int] = []
	for index in edge_count:
		var remaining_edges := edge_count - index - 1
		var minimum_units := maxi(0, remaining_units - (MAX_RISE_PER_STEP / 8) * remaining_edges)
		var maximum_units := mini(MAX_RISE_PER_STEP / 8, remaining_units)
		var rise_units := rng.randi_range(minimum_units, maximum_units)
		rises.append(rise_units * 8)
		remaining_units -= rise_units
	return rises

static func _safe_fallback(platform_count: int) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	if platform_count == 3:
		var centers := [324.0, 596.0, 860.0]
		var widths := [200.0, 184.0, 184.0]
		var tops := [440.0, 400.0, 376.0]
		for index in platform_count:
			var width: float = widths[index]
			var top: float = tops[index]
			var rect := Rect2(Vector2(centers[index] - width * 0.5, top), Vector2(width, PLATFORM_THICKNESS))
			entries.append(_entry_from_rect(rect))
		return entries

	var gap := GAP_MIN
	var available_width := RIGHT_LIMIT - FIRST_LEFT_MIN - gap * (platform_count - 1)
	var width := mini(MAX_PLATFORM_WIDTH, floori(float(available_width) / float(platform_count) / 8.0) * 8)
	if width < MIN_FALLBACK_WIDTH:
		return entries
	for index in platform_count:
		var left := float(FIRST_LEFT_MIN + index * (width + gap))
		var top := maxi(TOP_LIMIT, FIRST_TOP - mini(index, 2) * 32)
		var rect := Rect2(Vector2(left, top), Vector2(width, PLATFORM_THICKNESS))
		entries.append(_entry_from_rect(rect))
	return entries

static func _entries_are_safe(entries: Array[Dictionary], spawn_x: float) -> bool:
	if entries.size() < MIN_PLATFORM_COUNT:
		return false
	var previous: Rect2
	for index in entries.size():
		var rect: Rect2 = entries[index].get("rect", Rect2())
		if rect.size.y != PLATFORM_THICKNESS or rect.size.x < MIN_FALLBACK_WIDTH or rect.size.x > MAX_PLATFORM_WIDTH:
			return false
		if rect.position.x < 64.0 or rect.end.x > RIGHT_LIMIT or fposmod(rect.get_center().x, 8.0) > 0.01 or fposmod(rect.size.x, 8.0) > 0.01:
			return false
		if rect.position.y < TOP_LIMIT or rect.position.y > FIRST_TOP or rect.end.y > 464.0:
			return false
		if 560.0 - rect.end.y < 96.0:
			return false
		if index == 0:
			if absf(rect.position.y - FIRST_TOP) > 0.01:
				return false
			if rect.position.x < FIRST_LEFT_MIN or rect.position.x > FIRST_LEFT_MAX or rect.position.x - (spawn_x + 14.0) < 24.0:
				return false
		else:
			var gap := maxf(rect.position.x - previous.end.x, previous.position.x - rect.end.x)
			var rise := previous.position.y - rect.position.y
			if gap < GAP_MIN or gap > GAP_MAX or rise < 0.0 or rise > MAX_RISE_PER_STEP:
				return false
			if rect.intersects(previous):
				return false
		previous = rect
	return true

static func _entry_from_rect(rect: Rect2) -> Dictionary:
	return {
		"position": rect.get_center(),
		"size": rect.size,
		"rect": rect,
	}

static func _success_result(entries: Array[Dictionary], seed_used: int, used_fallback: bool) -> Dictionary:
	return {
		"valid": true,
		"platforms": entries,
		"primary_index": entries.size() - 1,
		"fallback_index": 0,
		"seed": seed_used,
		"used_fallback": used_fallback,
	}

static func _invalid_result(seed_used: int, message: String) -> Dictionary:
	return {
		"valid": false,
		"platforms": [],
		"primary_index": -1,
		"fallback_index": -1,
		"seed": seed_used,
		"used_fallback": false,
		"error": message,
	}
