class_name CombatFeedbackBurst
extends Node2D

enum EffectKind { PARRY, WALL_RICOCHET, ENEMY_HIT, CHARGED_HIT }

@export_group("Parry")
@export_range(0.05, 1.0, 0.01) var parry_duration: float = 0.20
@export var parry_color: Color = Color("#66ead0")
@export_range(4.0, 64.0, 1.0) var parry_size: float = 22.0

@export_group("Wall ricochet")
@export_range(0.05, 1.0, 0.01) var wall_duration: float = 0.14
@export var wall_color: Color = Color("#9dd9e2")
@export_range(4.0, 64.0, 1.0) var wall_size: float = 12.0

@export_group("Accepted enemy hit")
@export_range(0.05, 1.0, 0.01) var enemy_hit_duration: float = 0.18
@export var enemy_hit_color: Color = Color("#f5a84f")
@export_range(4.0, 64.0, 1.0) var enemy_hit_size: float = 18.0

@export_group("Charged enemy hit")
@export_range(0.05, 1.0, 0.01) var charged_hit_duration: float = 0.27
@export var charged_hit_color: Color = Color("#ffd36a")
@export_range(4.0, 64.0, 1.0) var charged_hit_size: float = 28.0

@export_group("Shape")
@export_range(4, 16, 1) var spark_count: int = 8

var effect_kind: int = EffectKind.PARRY
var _duration: float = 0.20
var _color: Color = Color("#66ead0")
var _size: float = 22.0
var _elapsed: float = 0.0
var _direction: Vector2 = Vector2.ZERO
var _speed_accent: float = 0.0

func configure(next_kind: int, direction: Vector2 = Vector2.ZERO, speed_ratio: float = 0.0) -> void:
	_direction = direction
	_speed_accent = clampf((speed_ratio - 1.0) * 0.8, 0.0, 1.0)
	effect_kind = clampi(next_kind, EffectKind.PARRY, EffectKind.CHARGED_HIT)
	match effect_kind:
		EffectKind.PARRY:
			_duration = parry_duration
			_color = parry_color
			_size = parry_size
		EffectKind.WALL_RICOCHET:
			_duration = wall_duration
			_color = wall_color
			_size = wall_size
		EffectKind.ENEMY_HIT:
			_duration = enemy_hit_duration
			_color = enemy_hit_color
			_size = enemy_hit_size
		EffectKind.CHARGED_HIT:
			_duration = charged_hit_duration
			_color = charged_hit_color
			_size = charged_hit_size
	_duration = maxf(_duration, 0.01)
	_size = maxf(_size, 1.0)

func _ready() -> void:
	add_to_group("combat_feedback_burst")
	queue_redraw()

func _process(delta: float) -> void:
	_elapsed += delta
	if _elapsed >= _duration:
		queue_free()
		return
	queue_redraw()

func _draw() -> void:
	var progress := clampf(_elapsed / _duration, 0.0, 1.0)
	var fade := 1.0 - progress
	var radius := _size * lerpf(0.22, 1.0, progress)
	var draw_color := _color
	draw_color.a *= fade
	var axis_angle := _direction.angle() if not _direction.is_zero_approx() else -PI * 0.5

	match effect_kind:
		EffectKind.WALL_RICOCHET:
			draw_arc(Vector2.ZERO, radius * 0.72, axis_angle - 1.2, axis_angle + 1.2, 12, draw_color, 2.0, false)
		EffectKind.CHARGED_HIT:
			draw_arc(Vector2.ZERO, radius * 0.56, 0.0, TAU, 20, draw_color, 3.0, false)
			draw_arc(Vector2.ZERO, radius, 0.0, TAU, 24, draw_color, 1.0, false)
		_:
			draw_arc(Vector2.ZERO, radius * 0.74, 0.0, TAU, 18, draw_color, 2.0, false)

	if progress < 0.28:
		var flash := Color("#FFF2C7")
		flash.a = 1.0 - progress / 0.28
		var flare_size := (6.0 + _speed_accent * 4.0) * (1.0 - progress)
		draw_rect(Rect2(Vector2(-flare_size, -1.0), Vector2(flare_size * 2.0, 2.0)), flash)
		draw_rect(Rect2(Vector2(-1.0, -flare_size), Vector2(2.0, flare_size * 2.0)), flash)

	_draw_particles(progress, draw_color, axis_angle)

func _draw_particles(progress: float, draw_color: Color, axis_angle: float) -> void:
	var is_wall := effect_kind == EffectKind.WALL_RICOCHET
	var span := 2.45 if is_wall else TAU
	var count := clampi(spark_count + roundi(_speed_accent * 5.0), 4, 16)
	var travel := 1.0 - pow(1.0 - progress, 2.0)
	for index in count:
		var unit := (float(index) + 0.5) / float(count)
		var angle := axis_angle + (unit - 0.5) * span
		var direction := Vector2.from_angle(angle)
		var spread := 0.85 + float(index % 4) * 0.16
		var distance := _size * spread * lerpf(0.16, 1.65 + _speed_accent * 0.35, travel)
		var point := (direction * distance + Vector2.DOWN * progress * progress * 13.0).round()
		var tint := draw_color.lightened(0.3) if index % 3 == 0 else draw_color
		var streak := maxf(2.0, (6.0 + _speed_accent * 4.0) * (1.0 - progress))
		draw_line((point - direction * streak).round(), point, tint, 2.0, false)
		if index % 2 == 0:
			draw_rect(Rect2(point - Vector2.ONE, Vector2(3.0, 3.0)), tint)
