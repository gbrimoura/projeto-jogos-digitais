extends Node2D

const DURATION := 0.18
var age := 0.0


func _process(delta: float) -> void:
	age += delta
	queue_redraw()

	if age >= DURATION:
		queue_free()


func _draw() -> void:
	var progress := clampf(age / DURATION, 0.0, 1.0)
	var alpha := 1.0 - progress

	for i in range(8):
		var direction := Vector2.RIGHT.rotated(TAU * float(i) / 8.0)
		var start := direction * 3.0
		var finish := direction * lerpf(7.0, 18.0, progress)

		draw_line(
			start,
			finish,
			Color(1.0, 0.72, 0.34, alpha),
			2.5,
			true
		)

	draw_circle(
		Vector2.ZERO,
		lerpf(5.0, 1.0, progress),
		Color(1.0, 0.9, 0.65, alpha)
	)
