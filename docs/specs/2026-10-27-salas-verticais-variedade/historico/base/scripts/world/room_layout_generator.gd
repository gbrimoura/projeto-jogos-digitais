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
		if rect.position.x < 64.0 or rect.end.x > RIGHT_LIMIT or fposmod(rect.position.x, 8.0) > 0.01 or fposmod(rect.size.x, 8.0) > 0.01:
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
			var gap := rect.position.x - previous.end.x
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
