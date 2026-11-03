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
	if aperture_size.is_equal_approx(Vector2(64.0, 128.0)):
		_draw_legacy_side_door()
		return
	if flip_h:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(-1.0, 1.0))
	var half := aperture_size * 0.5
	var border := 4.0
	var cap := minf(8.0, half.y)
	draw_rect(Rect2(-half.x, -half.y, aperture_size.x, aperture_size.y), VOID)
	draw_rect(Rect2(-half.x, -half.y, border, aperture_size.y), SHADOW)
	draw_rect(Rect2(half.x - border, -half.y, border, aperture_size.y), DEPTH)
	draw_rect(Rect2(-half.x, -half.y, aperture_size.x, border), METAL_DARK)
	draw_rect(Rect2(-half.x + border, -half.y + 2.0, aperture_size.x - border * 2.0, 2.0), METAL_LIGHT)
	draw_rect(Rect2(-half.x, half.y - cap, aperture_size.x, cap), METAL_DARK)
	draw_rect(Rect2(-half.x + border, half.y - cap, aperture_size.x - border * 2.0, 2.0), METAL_LIGHT)
	draw_rect(Rect2(-half.x + border, -half.y + border, 2.0, aperture_size.y - border - cap), COPPER)
	draw_rect(Rect2(half.x - border - 2.0, -half.y + border, 2.0, aperture_size.y - border - cap), METAL_DARK)
	if is_open:
		draw_rect(Rect2(-half.x + 8.0, -half.y + 8.0, aperture_size.x - 16.0, aperture_size.y - 16.0), VOID)
		draw_rect(Rect2(-half.x + 8.0, -half.y + 8.0, aperture_size.x - 16.0, 2.0), METAL_DARK)
		draw_rect(Rect2(-half.x + 8.0, half.y - 10.0, aperture_size.x - 16.0, 2.0), SHADOW)
	else:
		var bar_count := maxi(3, floori(aperture_size.x / 18.0))
		var inner_width := aperture_size.x - 24.0
		for index in bar_count:
			var fraction := (float(index) + 0.5) / float(bar_count)
			var bar_x := -inner_width * 0.5 + inner_width * fraction
			draw_rect(Rect2(bar_x - 2.0, -half.y + 10.0, 4.0, aperture_size.y - 20.0), METAL)
			draw_rect(Rect2(bar_x - 1.0, -half.y + 10.0, 1.0, aperture_size.y - 20.0), METAL_LIGHT)
		var rail_y := -half.y + aperture_size.y * 0.33
		draw_rect(Rect2(-half.x + 10.0, rail_y, aperture_size.x - 20.0, 4.0), METAL_DARK)
		draw_rect(Rect2(-half.x + 10.0, rail_y + aperture_size.y * 0.36, aperture_size.x - 20.0, 4.0), METAL_DARK)
		draw_rect(Rect2(half.x - 14.0, -8.0, 6.0, 16.0), METAL_DARK)
		draw_rect(Rect2(half.x - 12.0, -6.0, 2.0, 12.0), METAL_LIGHT)
		draw_rect(Rect2(half.x - 14.0, -2.0, 6.0, 4.0), COPPER)
		draw_rect(Rect2(half.x - 12.0, -2.0, 2.0, 4.0), AMBER)
	if flip_h:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_legacy_side_door() -> void:
	if flip_h:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(-1.0, 1.0))
	draw_rect(Rect2(-32, -64, 64, 128), VOID)
	draw_rect(Rect2(-32, -64, 4, 128), SHADOW)
	draw_rect(Rect2(28, -64, 4, 128), DEPTH)
	draw_rect(Rect2(-30, -64, 60, 8), METAL_DARK)
	draw_rect(Rect2(-28, -62, 56, 2), METAL_LIGHT)
	draw_rect(Rect2(-28, -58, 56, 2), SHADOW)
	draw_rect(Rect2(-30, 58, 60, 6), METAL_DARK)
	draw_rect(Rect2(-28, 58, 56, 2), METAL_LIGHT)
	draw_rect(Rect2(-30, 62, 60, 2), SHADOW)
	draw_rect(Rect2(-28, -56, 2, 112), COPPER)
	draw_rect(Rect2(26, -56, 2, 112), METAL_DARK)
	draw_rect(Rect2(-26, 42, 2, 4), COPPER)
	for rivet_y in [-48, -16, 16, 48]:
		draw_rect(Rect2(-30, rivet_y, 2, 2), AMBER)
		draw_rect(Rect2(28, rivet_y, 2, 2), METAL_LIGHT)
	if not is_open:
		draw_rect(Rect2(-22, -54, 44, 4), METAL_DARK)
		draw_rect(Rect2(-22, 50, 44, 4), METAL_DARK)
		for bar_x in [-18, -6, 6, 18]:
			draw_rect(Rect2(bar_x, -50, 4, 100), METAL)
			draw_rect(Rect2(bar_x, -50, 2, 100), METAL_LIGHT)
		for rail_y in [-22, 18]:
			draw_rect(Rect2(-18, rail_y, 36, 4), METAL_DARK)
		draw_rect(Rect2(20, -12, 6, 24), METAL_DARK)
		draw_rect(Rect2(22, -10, 2, 20), METAL_LIGHT)
		draw_rect(Rect2(20, -2, 6, 4), COPPER)
		draw_rect(Rect2(22, -2, 2, 4), AMBER)
	else:
		draw_rect(Rect2(-24, -54, 48, 108), VOID)
		draw_rect(Rect2(-24, -54, 48, 2), METAL_DARK)
		draw_rect(Rect2(-24, 52, 48, 2), SHADOW)
		draw_rect(Rect2(-24, -52, 2, 104), DEPTH)
		draw_rect(Rect2(22, -52, 2, 104), COPPER)
	if flip_h:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)