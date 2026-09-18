class_name SandboxVisual
extends Node2D

const WORLD_SIZE := Vector2(1152.0, 648.0)
const FLOOR_TOP := 560.0
const PLATFORM_RECTS := [
	Rect2(180.0, 440.0, 220.0, 24.0),
	Rect2(520.0, 350.0, 190.0, 24.0),
	Rect2(820.0, 460.0, 190.0, 24.0),
]

func _ready() -> void:
	queue_redraw()

func _draw() -> void:
	var background := Color("#0b1018")
	var grid := Color(0.17, 0.22, 0.29, 0.35)
	var platform := Color("#263545")
	var platform_edge := Color("#f0b35b")

	draw_rect(Rect2(Vector2.ZERO, WORLD_SIZE), background)

	for x in range(0, 1153, 64):
		draw_line(Vector2(x, 0.0), Vector2(x, FLOOR_TOP), grid, 1.0)
	for y in range(80, int(FLOOR_TOP), 64):
		draw_line(Vector2(0.0, y), Vector2(WORLD_SIZE.x, y), grid, 1.0)

	for rect in PLATFORM_RECTS:
		draw_rect(rect, platform)
		draw_line(rect.position, Vector2(rect.end.x, rect.position.y), platform_edge, 3.0)

	draw_rect(Rect2(0.0, FLOOR_TOP, WORLD_SIZE.x, WORLD_SIZE.y - FLOOR_TOP), Color("#1a2632"))
	draw_line(Vector2(0.0, FLOOR_TOP), Vector2(WORLD_SIZE.x, FLOOR_TOP), platform_edge, 3.0)
	draw_line(Vector2(0.0, FLOOR_TOP + 32.0), Vector2(WORLD_SIZE.x, FLOOR_TOP + 32.0), Color("#253746"), 1.0)
