extends Node2D

var _radius: float = 140.0
var _phase: StringName = &"hidden"
var _opacity: float = 0.0

func set_area_state(radius: float, center_offset: Vector2, phase: StringName, opacity: float) -> void:
	_radius = maxf(radius, 0.0)
	position = center_offset
	_phase = phase
	_opacity = clampf(opacity, 0.0, 1.0)
	visible = _phase != &"hidden" and _opacity > 0.001
	queue_redraw()

func _draw() -> void:
	if not visible or _radius <= 0.0:
		return

	var fill_alpha := 0.045
	var outline_alpha := 0.88
	var outline_width := 2.0
	var color := Color(1.0, 0.27, 0.055)
	match _phase:
		&"windup":
			color = Color(1.0, 0.32, 0.055)
			fill_alpha = 0.055
			outline_alpha = 0.82
		&"active":
			color = Color(1.0, 0.16, 0.035)
			fill_alpha = 0.09
			outline_alpha = 1.0
			outline_width = 3.0
		&"impact":
			color = Color(1.0, 0.76, 0.24)
			fill_alpha = 0.13
			outline_alpha = 1.0
			outline_width = 4.0
		&"recovery":
			color = Color(1.0, 0.27, 0.055)
			fill_alpha = 0.035
			outline_alpha = 0.55

	draw_circle(Vector2.ZERO, _radius, Color(color.r, color.g, color.b, fill_alpha * _opacity))
	draw_arc(
		Vector2.ZERO,
		_radius,
		0.0,
		TAU,
		96,
		Color(color.r, color.g, color.b, outline_alpha * _opacity),
		outline_width,
		true
	)
