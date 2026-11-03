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

# A zero opening height leaves this wall continuous (the default for other callers).
@export var opening_top: float = -1.0:
	set(value):
		opening_top = value
		queue_redraw()

@export var opening_height: float = 0.0:
	set(value):
		opening_height = value
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
	var has_opening := opening_height > 0.0 and opening_top >= 0.0
	if flip_h:
		# Refletir no centro do segmento aponta o acabamento do atlas para dentro.
		draw_set_transform(Vector2(DRAW_TILE_SIZE, 0.0), 0.0, Vector2(-1.0, 1.0))

	for segment_index in SEGMENT_COUNT:
		var destination_y := segment_index * DRAW_TILE_SIZE
		_draw_clipped_segment(
			Rect2(0.0, destination_y, DRAW_TILE_SIZE, DRAW_TILE_SIZE),
			full_source,
			has_opening
		)

	# A última peça reutiliza os quatro pixels superiores da célula, escalados por dois.
	_draw_clipped_segment(
		Rect2(0.0, SEGMENT_COUNT * DRAW_TILE_SIZE, DRAW_TILE_SIZE, FINAL_DRAW_HEIGHT),
		Rect2(source_x, source_y, ATLAS_TILE_SIZE, FINAL_SOURCE_HEIGHT),
		has_opening
	)

	if flip_h:
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _draw_clipped_segment(destination: Rect2, source: Rect2, has_opening: bool) -> void:
	if not has_opening:
		draw_texture_rect_region(atlas_texture, destination, source)
		return

	var segment_top := destination.position.y
	var segment_bottom := destination.end.y
	var opening_bottom := opening_top + opening_height
	var clipped_opening_top := maxf(opening_top, segment_top)
	var clipped_opening_bottom := minf(opening_bottom, segment_bottom)
	if clipped_opening_bottom <= segment_top or clipped_opening_top >= segment_bottom:
		draw_texture_rect_region(atlas_texture, destination, source)
		return

	var source_per_destination_y := source.size.y / destination.size.y
	if clipped_opening_top > segment_top:
		var upper_height := clipped_opening_top - segment_top
		draw_texture_rect_region(
			atlas_texture,
			Rect2(destination.position.x, segment_top, destination.size.x, upper_height),
			Rect2(source.position.x, source.position.y, source.size.x, upper_height * source_per_destination_y)
		)
	if clipped_opening_bottom < segment_bottom:
		var lower_height := segment_bottom - clipped_opening_bottom
		var lower_source_y := source.position.y + (clipped_opening_bottom - segment_top) * source_per_destination_y
		draw_texture_rect_region(
			atlas_texture,
			Rect2(destination.position.x, clipped_opening_bottom, destination.size.x, lower_height),
			Rect2(source.position.x, lower_source_y, source.size.x, lower_height * source_per_destination_y)
		)
