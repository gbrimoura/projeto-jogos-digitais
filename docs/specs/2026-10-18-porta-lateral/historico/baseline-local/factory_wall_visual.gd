@tool
extends Node2D

const ATLAS_TILE_SIZE := 32
const DRAW_TILE_SIZE := 64
const SEGMENT_COUNT := 10
const FINAL_SOURCE_HEIGHT := 4
const FINAL_DRAW_HEIGHT := 8

@export var atlas_texture: Texture2D:
	set(value):
		atlas_texture = value
		queue_redraw()

@export var atlas_source_id: int = 0:
	set(value):
		atlas_source_id = value
		queue_redraw()

@export var atlas_coordinates: Vector2i = Vector2i(0, 1):
	set(value):
		atlas_coordinates = value
		queue_redraw()

@export var flip_h: bool = false:
	set(value):
		flip_h = value
		queue_redraw()

func _enter_tree() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	queue_redraw()

func _draw() -> void:
	if atlas_texture == null or atlas_source_id != 0 or atlas_coordinates.x < 0 or atlas_coordinates.y < 0:
		return

	var source_x := atlas_coordinates.x * ATLAS_TILE_SIZE
	var source_y := atlas_coordinates.y * ATLAS_TILE_SIZE
	var full_source := Rect2(source_x, source_y, ATLAS_TILE_SIZE, ATLAS_TILE_SIZE)
	if flip_h:
		# Refletir no centro do segmento aponta o acabamento do atlas para dentro.
		draw_set_transform(Vector2(DRAW_TILE_SIZE, 0.0), 0.0, Vector2(-1.0, 1.0))

	for segment_index in SEGMENT_COUNT:
		var destination_y := segment_index * DRAW_TILE_SIZE
		draw_texture_rect_region(
			atlas_texture,
			Rect2(0.0, destination_y, DRAW_TILE_SIZE, DRAW_TILE_SIZE),
			full_source
		)

	# A última peça reutiliza os quatro pixels superiores da célula, escalados por dois.
	draw_texture_rect_region(
		atlas_texture,
		Rect2(0.0, SEGMENT_COUNT * DRAW_TILE_SIZE, DRAW_TILE_SIZE, FINAL_DRAW_HEIGHT),
		Rect2(source_x, source_y, ATLAS_TILE_SIZE, FINAL_SOURCE_HEIGHT)
	)

	if flip_h:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)