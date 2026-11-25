extends Node2D

const STEAM_TIME := 0.56
const ARRIVAL_TIME := 0.4
const REINFORCEMENT_MARK_TIME := 1.05
const COLUMN := 0
const FLOOR := 1
const AMBER := Color("#f5a84f")
const WHITE_HOT := Color("#fff0cf")
const COPPER := Color("#b37949")
const SIGNAL_GREEN := Color("#a5eee2")

var _purge_region: Rect2
var _purge_kind := 0
var _charge_duration := 0.0
var _charge_remaining := 0.0
var _steam_remaining := 0.0
var _spawn_position: Vector2
var _mark_remaining := 0.0
var _arrival_remaining := 0.0


func _ready() -> void:
	var boss := get_parent() as SupervisorCaldeira
	boss.purge_warned.connect(_on_purge_warned)
	boss.purge_released.connect(_on_purge_released)
	boss.purge_cancelled.connect(_on_purge_cancelled)
	boss.reinforcement_warned.connect(_on_reinforcement_warned)
	boss.reinforcement_arrived.connect(_on_reinforcement_arrived)
	boss.reinforcement_cancelled.connect(_on_reinforcement_cancelled)
	set_process(false)


func _process(delta: float) -> void:
	_charge_remaining = maxf(_charge_remaining - delta, 0.0)
	_steam_remaining = maxf(_steam_remaining - delta, 0.0)
	_mark_remaining = maxf(_mark_remaining - delta, 0.0)
	_arrival_remaining = maxf(_arrival_remaining - delta, 0.0)
	set_process(_charge_remaining > 0.0 or _steam_remaining > 0.0 or _mark_remaining > 0.0 or _arrival_remaining > 0.0)
	queue_redraw()


func _on_purge_warned(region: Rect2, kind: int, duration: float) -> void:
	_purge_region = region
	_purge_kind = kind
	_charge_duration = duration
	_charge_remaining = duration
	_start_effect()


func _on_purge_released(region: Rect2, kind: int) -> void:
	_purge_region = region
	_purge_kind = kind
	_charge_remaining = 0.0
	_steam_remaining = STEAM_TIME
	_start_effect()


func _on_reinforcement_warned(spawn_position: Vector2) -> void:
	_spawn_position = spawn_position
	_mark_remaining = REINFORCEMENT_MARK_TIME
	_start_effect()


func _on_reinforcement_arrived(spawn_position: Vector2) -> void:
	_spawn_position = spawn_position
	_mark_remaining = 0.0
	_arrival_remaining = ARRIVAL_TIME
	_start_effect()


func _on_purge_cancelled(_region: Rect2, _kind: int) -> void:
	_charge_remaining = 0.0
	queue_redraw()


func _on_reinforcement_cancelled(_spawn_position: Vector2) -> void:
	_mark_remaining = 0.0
	queue_redraw()


func _start_effect() -> void:
	set_process(true)
	queue_redraw()


func _draw() -> void:
	if _charge_remaining > 0.0:
		_draw_pressure_charge()
	if _steam_remaining > 0.0:
		_draw_steam()
	if _mark_remaining > 0.0 or _arrival_remaining > 0.0:
		_draw_reinforcement_hatch()


func _draw_pressure_charge() -> void:
	var region := Rect2(to_local(_purge_region.position), _purge_region.size)
	var buildup := 1.0 - _charge_remaining / _charge_duration
	var pulse := 0.5 + 0.5 * sin(buildup * 25.0)
	var tint := Color(AMBER, 0.45 + 0.22 * pulse + 0.25 * buildup)
	if _purge_kind == COLUMN:
		for index in 8:
			var x := region.position.x + region.size.x * (float(index) + 0.5) / 8.0
			var height := 8.0 + floorf(12.0 * buildup + 8.0 * pulse)
			draw_rect(Rect2(Vector2(x - 3.0, region.end.y - height).round(), Vector2(6.0, height)), tint)
	else:
		for index in 4:
			var y := region.position.y + (float(index) + 0.5) * region.size.y / 4.0
			var reach := 10.0 + floorf(16.0 * buildup + 9.0 * pulse)
			draw_rect(Rect2(Vector2(region.position.x, y - 3.0).round(), Vector2(reach, 6.0)), tint)
			draw_rect(Rect2(Vector2(region.end.x - reach, y - 3.0).round(), Vector2(reach, 6.0)), tint)


func _draw_steam() -> void:
	var region := Rect2(to_local(_purge_region.position), _purge_region.size)
	var age := 1.0 - _steam_remaining / STEAM_TIME
	var fade := 1.0 - age
	var tint := AMBER if _purge_kind == FLOOR else COPPER
	if age < 0.26:
		draw_rect(region, Color(AMBER, 0.22 * (1.0 - age / 0.26)))
	for index in 48:
		# Fixed sequence makes the plume stable across frames and seeds.
		var lane := fposmod(float(index) * 0.6180339, 1.0)
		var offset := fposmod(float(index) * 0.2141, 1.0)
		var streak := 16.0 + offset * 85.0 * fade
		var head := 3.0 + floorf(5.0 * offset)
		var travel := clampf(age * (1.08 + 0.55 * offset) + offset * 0.18, 0.0, 1.0)
		var strip: Rect2
		if _purge_kind == COLUMN:
			var bottom := region.end.y - travel * region.size.y
			strip = Rect2(Vector2(region.position.x + lane * region.size.x, bottom - streak), Vector2(head, streak))
		else:
			var from_left := index % 2 == 0
			var x := lerpf(region.position.x, region.end.x, travel if from_left else 1.0 - travel)
			strip = Rect2(Vector2(x - streak if from_left else x, region.position.y + lane * region.size.y), Vector2(streak, head))
		strip = region.intersection(Rect2(strip.position.round(), strip.size.round()))
		if strip.has_area():
			draw_rect(strip, Color(WHITE_HOT if index % 3 != 0 else tint, fade * (0.34 + offset * 0.48)))
			if index % 4 == 0 and age > 0.12:
				var cloud := Rect2(strip.get_center().round() - Vector2(8.0, 8.0), Vector2(16.0, 16.0))
				cloud = region.intersection(cloud)
				if cloud.has_area():
					draw_rect(cloud, Color("#d9ccc1", fade * 0.24))


func _draw_reinforcement_hatch() -> void:
	var anchor := to_local(_spawn_position).round()
	var arrival := _arrival_remaining > 0.0
	var progress := 1.0 - _arrival_remaining / ARRIVAL_TIME if arrival else 0.0
	var pulse := 0.75 + 0.25 * sin(_mark_remaining * 29.0)
	var light := Color(SIGNAL_GREEN if arrival else AMBER, 1.0 - progress if arrival else pulse)
	var gap := 8.0 + roundf(22.0 * progress)
	if not arrival:
		var mark_progress := 1.0 - _mark_remaining / REINFORCEMENT_MARK_TIME
		draw_string(ThemeDB.fallback_font, anchor + Vector2(-42, -46), "REFORÇO", HORIZONTAL_ALIGNMENT_CENTER, 84.0, 13, light)
		draw_rect(Rect2(anchor + Vector2(-33, -35), Vector2(66.0 * mark_progress, 3.0)), light)
	draw_rect(Rect2(anchor + Vector2(-42, -8), Vector2(84, 8)), Color("#192031"))
	draw_rect(Rect2(anchor + Vector2(-42, -8), Vector2(84, 2)), light)
	for side: float in [-1.0, 1.0]:
		var hinge := anchor + Vector2(side * gap, -14)
		var left := hinge.x - (18.0 if side < 0.0 else 0.0)
		draw_rect(Rect2(Vector2(left, hinge.y), Vector2(18, 8)), Color("#373f4d"))
		draw_rect(Rect2(Vector2(left, hinge.y), Vector2(18, 2)), light)
		for index in 5:
			var x := hinge.x + side * float(index * 5)
			var rise := 8.0 + progress * float(16 + index * 7)
			draw_rect(Rect2(Vector2(x, anchor.y - 12.0 - rise).round(), Vector2(3.0, rise)), light)
