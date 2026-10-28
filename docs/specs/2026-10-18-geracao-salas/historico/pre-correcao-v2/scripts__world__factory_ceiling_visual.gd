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
	# terrain_top_mid tem acabamento no alto; inverter Y volta essa borda para baixo.
	draw_set_transform(Vector2(0.0, BAND_HEIGHT), 0.0, Vector2(1.0, -1.0))
	for segment_index in range(BAND_WIDTH / DRAW_TILE_SIZE):
		draw_texture_rect_region(
			atlas_texture,
			Rect2(segment_index * DRAW_TILE_SIZE, 0.0, DRAW_TILE_SIZE, DRAW_TILE_SIZE),
			source
		)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
