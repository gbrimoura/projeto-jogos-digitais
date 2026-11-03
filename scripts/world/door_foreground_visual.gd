@tool
extends Node2D

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
	if flip_h:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2(-1.0, 1.0))

	var half := aperture_size * 0.5
	var cap := minf(8.0, half.y)
	draw_rect(Rect2(-half.x, -half.y, 4.0, aperture_size.y), SHADOW)
	draw_rect(Rect2(half.x - 4.0, -half.y, 4.0, aperture_size.y), SHADOW)
	draw_rect(Rect2(-half.x, -half.y, aperture_size.x, 4.0), METAL_DARK)
	draw_rect(Rect2(-half.x + 4.0, -half.y + 2.0, aperture_size.x - 8.0, 2.0), METAL_LIGHT)
	draw_rect(Rect2(-half.x, half.y - cap, aperture_size.x, cap), METAL_DARK)
	draw_rect(Rect2(-half.x + 4.0, half.y - cap, aperture_size.x - 8.0, 2.0), METAL_LIGHT)
	draw_rect(Rect2(-half.x + 4.0, -half.y + 4.0, 2.0, aperture_size.y - 4.0 - cap), COPPER)
	draw_rect(Rect2(half.x - 6.0, -half.y + 4.0, 2.0, aperture_size.y - 4.0 - cap), METAL_DARK)

	if not is_open:
		var bar_count := maxi(3, floori(aperture_size.x / 18.0))
		var inner_width := aperture_size.x - 24.0
		for index in bar_count:
			var fraction := (float(index) + 0.5) / float(bar_count)
			var bar_x := snappedf(-inner_width * 0.5 + inner_width * fraction, 2.0)
			draw_rect(Rect2(bar_x - 2.0, -half.y + 10.0, 4.0, aperture_size.y - 20.0), METAL)
			draw_rect(Rect2(bar_x - 1.0, -half.y + 10.0, 1.0, aperture_size.y - 20.0), METAL_LIGHT)
		var rail_y := snappedf(-half.y + aperture_size.y * 0.33, 2.0)
		draw_rect(Rect2(-half.x + 10.0, rail_y, aperture_size.x - 20.0, 4.0), METAL_DARK)
		var second_rail_y := snappedf(rail_y + aperture_size.y * 0.36, 2.0)
		draw_rect(Rect2(-half.x + 10.0, second_rail_y, aperture_size.x - 20.0, 4.0), METAL_DARK)
		draw_rect(Rect2(half.x - 14.0, -8.0, 6.0, 16.0), METAL_DARK)
		draw_rect(Rect2(half.x - 12.0, -6.0, 2.0, 12.0), METAL_LIGHT)
		draw_rect(Rect2(half.x - 14.0, -2.0, 6.0, 4.0), COPPER)
		draw_rect(Rect2(half.x - 12.0, -2.0, 2.0, 4.0), AMBER)
	else:
		var rivet_y_values: Array[float] = [-half.y + 8.0, half.y - 10.0]
		for rivet_y in rivet_y_values:
			draw_rect(Rect2(-half.x + 6.0, rivet_y, 2.0, 2.0), AMBER)
			draw_rect(Rect2(half.x - 8.0, rivet_y, 2.0, 2.0), METAL_LIGHT)

	if flip_h:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
