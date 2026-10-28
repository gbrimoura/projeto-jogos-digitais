@tool
extends Node2D

const VOID := Color("#0E0D0E")
const DEPTH := Color("#1D1B1A")
const SHADOW := Color("#302D2A")
const METAL_DARK := Color("#5B5249")
const METAL := Color("#756957")
const METAL_LIGHT := Color("#90816A")
const COPPER := Color("#70432C")
const AMBER := Color("#B78342")

@export var flip_h: bool = false:
	set(value):
		flip_h = value
		queue_redraw()

@export var is_open: bool = false:
	set(value):
		is_open = value
		queue_redraw()

func _enter_tree() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	queue_redraw()

func set_aperture_open(value: bool) -> void:
	is_open = value

func _draw() -> void:
	if flip_h:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(-1.0, 1.0))

	# The 64×128 dark void occupies the actual wall thickness and ends at the floor.
	draw_rect(Rect2(-32, -64, 64, 128), VOID)
	# Recess facets and a narrow lintel read as cut metal, not as a panel on the back wall.
	draw_rect(Rect2(-30, -62, 60, 2), METAL_DARK)
	draw_rect(Rect2(-30, 60, 60, 2), SHADOW)
	draw_rect(Rect2(-32, -64, 4, 128), SHADOW)
	draw_rect(Rect2(28, -64, 4, 128), DEPTH)
	draw_rect(Rect2(-28, -58, 2, 116), COPPER)
	draw_rect(Rect2(26, -58, 2, 116), METAL_DARK)
	# Warm rivets stay on the exposed jambs and use the factory's existing palette.
	for rivet_y in [-48, -16, 16, 48]:
		draw_rect(Rect2(-30, rivet_y, 2, 2), AMBER)
		draw_rect(Rect2(28, rivet_y, 2, 2), METAL_LIGHT)

	if not is_open:
		# A simple grate sits inside the tunnel; the opening remains visibly lateral.
		draw_rect(Rect2(-22, -54, 44, 2), METAL_DARK)
		draw_rect(Rect2(-22, 52, 44, 2), METAL_DARK)
		for bar_x in [-20, -8, 4, 16]:
			draw_rect(Rect2(bar_x, -52, 2, 104), METAL)
		for rail_y in [-28, 0, 28]:
			draw_rect(Rect2(-20, rail_y, 38, 2), METAL_DARK)
		draw_rect(Rect2(16, -4, 4, 8), AMBER)
	else:
		# Open state keeps the through-hole dark and leaves only the inner-edge cut reveal.
		draw_rect(Rect2(-24, -54, 48, 108), VOID)
		draw_rect(Rect2(-30, -60, 2, 120), METAL_DARK)
		draw_rect(Rect2(-28, -58, 2, 116), METAL_LIGHT)

	if flip_h:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
