@tool
extends Node2D

const RIGHT := Vector2i(1, 0)
const DOWN := Vector2i(0, 1)
const LEFT := Vector2i(-1, 0)
const UP := Vector2i(0, -1)
const OUTLINE := Color("#302D2A")
const AMBER := Color("#B78342")
const CREAM := Color("#E2C99B")

const OUTLINE_RECTS: Array[Rect2i] = [
	Rect2i(-24, -8, 40, 16),
	Rect2i(0, -16, 8, 32),
	Rect2i(8, -12, 8, 24),
	Rect2i(16, -8, 8, 16),
	Rect2i(24, -4, 12, 8),
]

const ARROW_RECTS: Array[Rect2i] = [
	Rect2i(-20, -4, 28, 8),
	Rect2i(0, -12, 8, 24),
	Rect2i(8, -8, 8, 16),
	Rect2i(16, -4, 8, 8),
	Rect2i(24, -4, 8, 8),
]

@export var direction: Vector2i = RIGHT:
	set(value):
		if not _is_cardinal(value):
			return
		direction = value
		queue_redraw()

func _enter_tree() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	queue_redraw()

func configure(next_direction: Vector2i, next_position: Vector2, enabled: bool) -> void:
	if _is_cardinal(next_direction):
		direction = next_direction
	position = next_position
	visible = enabled
	queue_redraw()

func _draw() -> void:
	for raw_rect in OUTLINE_RECTS:
		var rect: Rect2i = raw_rect
		draw_rect(_oriented_rect(rect), OUTLINE)
	for raw_rect in ARROW_RECTS:
		var rect: Rect2i = raw_rect
		draw_rect(_oriented_rect(rect), AMBER)
	draw_rect(_oriented_rect(Rect2i(-16, -2, 16, 4)), CREAM)

func _oriented_rect(rect: Rect2i) -> Rect2:
	var position_i := rect.position
	var size_i := rect.size
	var oriented_position := position_i
	var oriented_size := size_i
	if direction == DOWN:
		oriented_position = Vector2i(-position_i.y - size_i.y, position_i.x)
		oriented_size = Vector2i(size_i.y, size_i.x)
	elif direction == LEFT:
		oriented_position = Vector2i(-position_i.x - size_i.x, -position_i.y - size_i.y)
	elif direction == UP:
		oriented_position = Vector2i(position_i.y, -position_i.x - size_i.x)
		oriented_size = Vector2i(size_i.y, size_i.x)
	return Rect2(Vector2(oriented_position), Vector2(oriented_size))

func _is_cardinal(value: Vector2i) -> bool:
	return value == RIGHT or value == DOWN or value == LEFT or value == UP
