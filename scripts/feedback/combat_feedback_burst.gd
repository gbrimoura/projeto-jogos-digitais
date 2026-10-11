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

func configure(next_kind: int) -> void:
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
	var radius := _size * lerpf(0.25, 1.0, progress)
	var line_width := maxf(_size * 0.075 * fade, 0.5)
	var draw_color := _color
	draw_color.a *= fade

	match effect_kind:
		EffectKind.PARRY:
			draw_arc(Vector2.ZERO, radius * 0.72, 0.0, TAU, 20, draw_color, line_width, true)
			_draw_sparks(radius, draw_color, line_width, 0.0)
		EffectKind.WALL_RICOCHET:
			draw_arc(Vector2.ZERO, radius * 0.78, -0.5, 2.5, 10, draw_color, line_width, true)
			_draw_sparks(radius, draw_color, line_width, PI * 0.25)
		EffectKind.ENEMY_HIT:
			draw_arc(Vector2.ZERO, radius * 0.62, 0.0, TAU, 18, draw_color, line_width, true)
			_draw_sparks(radius, draw_color, line_width, PI * 0.125)
		EffectKind.CHARGED_HIT:
			draw_arc(Vector2.ZERO, radius * 0.52, 0.0, TAU, 18, draw_color, line_width * 1.4, true)
			draw_arc(Vector2.ZERO, radius, 0.0, TAU, 24, draw_color, line_width, true)
			_draw_sparks(radius, draw_color, line_width * 1.2, 0.0)

func _draw_sparks(radius: float, draw_color: Color, line_width: float, angle_offset: float) -> void:
	var count := maxi(spark_count, 4)
	var inner_radius := radius * 0.72
	var outer_radius := radius * (1.0 if effect_kind == EffectKind.WALL_RICOCHET else 1.28)
	for index in range(count):
		var angle := TAU * float(index) / float(count) + angle_offset
		var direction := Vector2.RIGHT.rotated(angle)
		draw_line(direction * inner_radius, direction * outer_radius, draw_color, line_width, true)
