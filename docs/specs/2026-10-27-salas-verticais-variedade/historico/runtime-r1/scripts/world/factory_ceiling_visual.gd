@tool
extends Node2D

const ATLAS_TILE_SIZE := 32
const DRAW_TILE_SIZE := 64
const BAND_WIDTH := 1152
const BAND_HEIGHT := 64
const ATLAS_COORDINATES := Vector2i(1, 0)

@export var atlas_texture: Texture2D:
	set(value):
		atlas_texture = value
		queue_redraw()
@export var opening_center_x: float = 0.0:
	set(value):
		opening_center_x = value
		queue_redraw()
@export var opening_width: float = 0.0:
	set(value):
		opening_width = maxf(value, 0.0)
		queue_redraw()
@export var opening_enabled: bool = false:
	set(value):
		opening_enabled = value
		queue_redraw()

func _enter_tree() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	queue_redraw()

func _draw() -> void:
	if atlas_texture == null:
		return
	var source := Rect2(
		ATLAS_COORDINATES.x * ATLAS_TILE_SIZE,
		ATLAS_COORDINATES.y * ATLAS_TILE_SIZE,
		ATLAS_TILE_SIZE,
		ATLAS_TILE_SIZE
	)
	draw_set_transform(Vector2(0.0, BAND_HEIGHT), 0.0, Vector2(1.0, -1.0))
	var opening_left := opening_center_x + BAND_WIDTH * 0.5 - opening_width * 0.5
	var opening_right := opening_center_x + BAND_WIDTH * 0.5 + opening_width * 0.5
	for segment_index in range(BAND_WIDTH / DRAW_TILE_SIZE):
		var x := float(segment_index * DRAW_TILE_SIZE)
		var destination := Rect2(x, 0.0, DRAW_TILE_SIZE, DRAW_TILE_SIZE)
		if not opening_enabled or x + DRAW_TILE_SIZE <= opening_left or x >= opening_right:
			draw_texture_rect_region(atlas_texture, destination, source)
			continue
		var left_end := clampf(opening_left, x, x + DRAW_TILE_SIZE)
		var right_start := clampf(opening_right, x, x + DRAW_TILE_SIZE)
		if left_end > x:
			var left_width := left_end - x
			draw_texture_rect_region(
				atlas_texture,
				Rect2(x, 0.0, left_width, DRAW_TILE_SIZE),
				Rect2(source.position, Vector2(ATLAS_TILE_SIZE * left_width / DRAW_TILE_SIZE, ATLAS_TILE_SIZE))
			)
		if right_start < x + DRAW_TILE_SIZE:
			var right_width := x + DRAW_TILE_SIZE - right_start
			var source_x := source.position.x + ATLAS_TILE_SIZE * (right_start - x) / DRAW_TILE_SIZE
			draw_texture_rect_region(
				atlas_texture,
				Rect2(right_start, 0.0, right_width, DRAW_TILE_SIZE),
				Rect2(Vector2(source_x, source.position.y), Vector2(ATLAS_TILE_SIZE * right_width / DRAW_TILE_SIZE, ATLAS_TILE_SIZE))
			)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)