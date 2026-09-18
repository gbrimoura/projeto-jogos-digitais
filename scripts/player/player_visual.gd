class_name PlayerVisual
extends Node2D

var _facing_direction: int = 1
var _is_dashing: bool = false
var _dash_phase: float = 0.0

func _process(delta: float) -> void:
	if _is_dashing:
		_dash_phase = fmod(_dash_phase + delta * 16.0, TAU)
		queue_redraw()

func set_facing_direction(direction: int) -> void:
	if direction == 0 or direction == _facing_direction:
		return
	_facing_direction = 1 if direction > 0 else -1
	queue_redraw()

func set_dashing(value: bool) -> void:
	if value == _is_dashing:
		return
	_is_dashing = value
	queue_redraw()

func _draw() -> void:
	var facing := float(_facing_direction)
	var outline := Color("#101722")
	var metal := Color("#526276")
	var metal_light := Color("#91a5b8")
	var accent := Color("#f0b35b")

	if _is_dashing:
		var pulse := 0.5 + 0.5 * sin(_dash_phase)
		draw_line(
			Vector2(-facing * 12.0, -25.0),
			Vector2(-facing * (42.0 + pulse * 8.0), -25.0),
			Color(0.94, 0.7, 0.35, 0.75),
			8.0
		)

	draw_rect(Rect2(-16.0, -42.0, 32.0, 30.0), metal)
	draw_rect(Rect2(-16.0, -42.0, 32.0, 30.0), outline, false, 2.0)
	draw_circle(Vector2(0.0, -54.0), 13.0, metal_light)
	draw_arc(Vector2(0.0, -54.0), 13.0, 0.0, TAU, 32, outline, 2.0)

	# Visor e antena mantem a direcao do robo legivel sem depender de sprite.
	draw_line(Vector2(-8.0, -54.0), Vector2(8.0, -54.0), accent, 2.0)
	draw_circle(Vector2(5.0 * facing, -54.0), 2.5, accent)
	draw_line(Vector2(0.0, -67.0), Vector2(0.0, -74.0), outline, 2.0)
	draw_circle(Vector2(0.0, -75.0), 2.0, accent)

	# Braco e pernas reforcam a leitura lateral do personagem.
	draw_line(Vector2(facing * 14.0, -32.0), Vector2(facing * 24.0, -23.0), metal_light, 4.0)
	draw_line(Vector2(-9.0, -12.0), Vector2(-11.0, -2.0), outline, 4.0)
	draw_line(Vector2(9.0, -12.0), Vector2(11.0, -2.0), outline, 4.0)
