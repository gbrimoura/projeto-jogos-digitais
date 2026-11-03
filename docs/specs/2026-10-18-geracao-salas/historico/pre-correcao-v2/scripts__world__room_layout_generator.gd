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
const MAX_ATTEMPTS := 32

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
	var available_width := RIGHT_LIMIT - FIRST_LEFT_MIN - GAP_MIN * (platform_count - 1)
	var maximum_width := mini(MAX_PLATFORM_WIDTH, floori(float(available_width) / float(platform_count) / 8.0) * 8)
	if maximum_width < minimum_width:
		return _invalid_result(seed_used, "não há largura suficiente para uma rota segura com esta quantidade")

	for attempt in MAX_ATTEMPTS:
		var first_left := rng.randi_range(FIRST_LEFT_MIN / 8, FIRST_LEFT_MAX / 8) * 8
		var width_room := RIGHT_LIMIT - first_left - GAP_MIN * (platform_count - 1)
		var candidate_max_width := mini(maximum_width, floori(float(width_room) / float(platform_count) / 8.0) * 8)
		if candidate_max_width < minimum_width:
			continue

		var entries: Array[Dictionary] = []
		var left := float(first_left)
		var previous_top := FIRST_TOP
		for index in platform_count:
			var width := rng.randi_range(minimum_width / 8, candidate_max_width / 8) * 8
			var top := FIRST_TOP
			if index > 0:
				var rise := rng.randi_range(2, MAX_RISE_PER_STEP / 8) * 8
				top = maxi(TOP_LIMIT, previous_top - rise)
			previous_top = top
			var rect := Rect2(Vector2(left, top), Vector2(width, PLATFORM_THICKNESS))
			entries.append(_entry_from_rect(rect))
			left = rect.end.x
			if index < platform_count - 1:
				left += rng.randi_range(GAP_MIN / 8, GAP_MAX / 8) * 8

		if _entries_are_safe(entries, spawn_x):
			return _success_result(entries, seed_used, false)

	var fallback_entries := _safe_fallback(platform_count)
	if not _entries_are_safe(fallback_entries, spawn_x):
		return _invalid_result(seed_used, "fallback fixo não satisfaz os limites de sala")
	return _success_result(fallback_entries, seed_used, true)

static func _safe_fallback(platform_count: int) -> Array[Dictionary]:
	var entries: Array[Dictionary] = []
	if platform_count == 3:
		var centers := [320.0, 590.0, 860.0]
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
