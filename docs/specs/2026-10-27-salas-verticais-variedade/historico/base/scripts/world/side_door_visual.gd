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

	# The outer silhouette remains the 64×128 through-cut at the lateral wall.
	draw_rect(Rect2(-32, -64, 64, 128), VOID)
	draw_rect(Rect2(-32, -64, 4, 128), SHADOW)
	draw_rect(Rect2(28, -64, 4, 128), DEPTH)

	# Thick lintel and low sill build a stepped, horizontal tunnel reveal.
	draw_rect(Rect2(-30, -64, 60, 8), METAL_DARK)
	draw_rect(Rect2(-28, -62, 56, 2), METAL_LIGHT)
	draw_rect(Rect2(-28, -58, 56, 2), SHADOW)
	draw_rect(Rect2(-30, 58, 60, 6), METAL_DARK)
	draw_rect(Rect2(-28, 58, 56, 2), METAL_LIGHT)
	draw_rect(Rect2(-30, 62, 60, 2), SHADOW)

	# Recessed side rails use the factory steel and copper tones.
	draw_rect(Rect2(-28, -56, 2, 112), COPPER)
	draw_rect(Rect2(26, -56, 2, 112), METAL_DARK)
	# A single low rust trace keeps the finish used, without adding surface noise.
	draw_rect(Rect2(-26, 42, 2, 4), COPPER)

	# Paired 2×2 fasteners stay on the exposed jambs.
	for rivet_y in [-48, -16, 16, 48]:
		draw_rect(Rect2(-30, rivet_y, 2, 2), AMBER)
		draw_rect(Rect2(28, rivet_y, 2, 2), METAL_LIGHT)

	if not is_open:
		# Heavy grate bars and cross rails sit inside the wall thickness.
		draw_rect(Rect2(-22, -54, 44, 4), METAL_DARK)
		draw_rect(Rect2(-22, 50, 44, 4), METAL_DARK)
		for bar_x in [-18, -6, 6, 18]:
			draw_rect(Rect2(bar_x, -50, 4, 100), METAL)
			draw_rect(Rect2(bar_x, -50, 2, 100), METAL_LIGHT)
		for rail_y in [-22, 18]:
			draw_rect(Rect2(-18, rail_y, 36, 4), METAL_DARK)
		# Compact sliding latch and amber status pin.
		draw_rect(Rect2(20, -12, 6, 24), METAL_DARK)
		draw_rect(Rect2(22, -10, 2, 20), METAL_LIGHT)
		draw_rect(Rect2(20, -2, 6, 4), COPPER)
		draw_rect(Rect2(22, -2, 2, 4), AMBER)
	else:
		# The open state keeps a broad, dark passage; only the tunnel edges remain detailed.
		draw_rect(Rect2(-24, -54, 48, 108), VOID)
		draw_rect(Rect2(-24, -54, 48, 2), METAL_DARK)
		draw_rect(Rect2(-24, 52, 48, 2), SHADOW)
		draw_rect(Rect2(-24, -52, 2, 104), DEPTH)
		draw_rect(Rect2(22, -52, 2, 104), COPPER)

	if flip_h:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
