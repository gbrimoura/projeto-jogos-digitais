class_name ReticleVisual
extends Node2D

## Reticula visual independente da locomocao e da fisica do jogador.

@export_range(2.0, 32.0, 0.5)
var radius: float = 9.0

@export_range(0.0, 16.0, 0.5)
var gap: float = 4.0

@export_range(2.0, 24.0, 0.5)
var arm_length: float = 8.0

@export_range(1.0, 6.0, 0.5)
var line_width: float = 2.0

@export var reticle_color: Color = Color("#f0b35b")
@export var center_color: Color = Color("#ffdf9a")

@export_range(0.5, 5.0, 0.5)
var center_radius: float = 1.5

func set_aim(_direction: Vector2, target_position: Vector2) -> void:
	global_position = target_position
	queue_redraw()

func _draw() -> void:
	var segment_gap := 0.16
	var segment_length := PI * 0.5 - segment_gap * 2.0
	for index in range(4):
		var segment_start := float(index) * PI * 0.5 + segment_gap
		draw_arc(
			Vector2.ZERO,
			radius,
			segment_start,
			segment_start + segment_length,
			12,
			reticle_color,
			line_width,
			true
		)

	var arm_start := radius + gap
	var arm_end := arm_start + arm_length
	for axis in [Vector2.RIGHT, Vector2.LEFT, Vector2.UP, Vector2.DOWN]:
		draw_line(axis * arm_start, axis * arm_end, reticle_color, line_width, true)

	draw_circle(Vector2.ZERO, center_radius, center_color)
