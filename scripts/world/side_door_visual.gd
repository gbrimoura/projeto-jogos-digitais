@tool
extends Node2D

const VOID := Color("#0E0D0E")
const DEPTH := Color("#1D1B1A")
const SHADOW := Color("#302D2A")
const COPPER := Color("#70432C")

@export var flip_h: bool = false:
	set(value):
		flip_h = value
		queue_redraw()

@export var is_open: bool = false:
	set(value):
		is_open = value
		queue_redraw()

@export var aperture_size: Vector2 = Vector2(64.0, 128.0):
	set(value):
		aperture_size = Vector2(maxf(value.x, 64.0), maxf(value.y, 64.0))
		queue_redraw()

func _enter_tree() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	queue_redraw()

func set_aperture_open(value: bool) -> void:
	is_open = value

func _draw() -> void:
	if not is_open:
		return
	if flip_h:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(-1.0, 1.0))

	var half := aperture_size * 0.5
	draw_rect(Rect2(-half.x, -half.y, aperture_size.x, aperture_size.y), DEPTH)
	draw_rect(Rect2(-half.x + 8.0, -half.y + 8.0, aperture_size.x - 16.0, aperture_size.y - 16.0), VOID)
	draw_rect(Rect2(-half.x + 8.0, -half.y + 8.0, 4.0, aperture_size.y - 16.0), SHADOW)
	draw_rect(Rect2(half.x - 12.0, -half.y + 8.0, 4.0, aperture_size.y - 16.0), COPPER)

	if flip_h:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
