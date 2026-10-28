@tool
extends Node2D

const SOURCE_TILE_SIZE: float = 32.0
const WORLD_SCALE: float = 2.0
const WORLD_TILE_SIZE: float = SOURCE_TILE_SIZE * WORLD_SCALE
const MIN_REMAINDER: float = 0.001
const FACTORY_TILESET: TileSet = preload("res://resources/environment/factory_tileset_v1.tres")

enum SurfaceStyle { PLATFORM, BLOCK }

@export var surface_size: Vector2 = Vector2(220.0, 24.0):
	set(value):
		surface_size = Vector2(maxf(value.x, 0.0), maxf(value.y, 0.0))
		if is_inside_tree():
			queue_redraw()

@export_enum("Platform", "Block") var surface_style: int = SurfaceStyle.PLATFORM:
	set(value):
		surface_style = clampi(value, SurfaceStyle.PLATFORM, SurfaceStyle.BLOCK)
		if is_inside_tree():
			queue_redraw()

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	queue_redraw()

func _draw() -> void:
	if surface_size.x <= 0.0 or surface_size.y <= 0.0:
		return

	var atlas_source: TileSetAtlasSource = FACTORY_TILESET.get_source(0) as TileSetAtlasSource
	if atlas_source == null:
		return
	var atlas: Texture2D = atlas_source.texture
	if atlas == null:
		return

	if surface_style == SurfaceStyle.BLOCK:
		_draw_block(atlas)
	else:
		_draw_platform(atlas)

func _draw_platform(atlas: Texture2D) -> void:
	var source_height: float = minf(SOURCE_TILE_SIZE, surface_size.y / WORLD_SCALE)
	_draw_triplet(atlas, 96.0, source_height, -surface_size.y * 0.5, surface_size.x, 0, 1, 2)

func _draw_block(atlas: Texture2D) -> void:
	var top_height: float = minf(WORLD_TILE_SIZE, surface_size.y)
	var top_source_height: float = top_height / WORLD_SCALE
	var top_y: float = -surface_size.y * 0.5
	_draw_triplet(atlas, 0.0, top_source_height, top_y, surface_size.x, 0, 1, 2)

	var remaining_height: float = surface_size.y - top_height
	if remaining_height <= 0.0:
		return

	var bottom_height: float = minf(WORLD_TILE_SIZE, remaining_height)
	if remaining_height > WORLD_TILE_SIZE:
		var fill_height: float = remaining_height - WORLD_TILE_SIZE
		var fill_y: float = top_y + top_height
		while fill_height > MIN_REMAINDER:
			var slice_height: float = minf(WORLD_TILE_SIZE, fill_height)
			_draw_triplet(
				atlas,
				32.0,
				slice_height / WORLD_SCALE,
				fill_y,
				surface_size.x,
				0,
				1,
				2
			)
			fill_y += slice_height
			fill_height -= slice_height
		bottom_height = WORLD_TILE_SIZE

	var bottom_source_height: float = bottom_height / WORLD_SCALE
	var bottom_source_y: float = 64.0 + SOURCE_TILE_SIZE - bottom_source_height
	var bottom_y: float = surface_size.y * 0.5 - bottom_height
	_draw_triplet(atlas, bottom_source_y, bottom_source_height, bottom_y, surface_size.x, 0, 1, 2)

func _draw_triplet(
	atlas: Texture2D,
	source_y: float,
	source_height: float,
	destination_y: float,
	width: float,
	left_column: int,
	middle_column: int,
	right_column: int
) -> void:
	if width <= 0.0 or source_height <= 0.0:
		return

	var half_width: float = width * 0.5
	var source_cap_width: float = minf(SOURCE_TILE_SIZE, width / (WORLD_SCALE * 2.0))
	var destination_cap_width: float = source_cap_width * WORLD_SCALE
	var destination_rect: Rect2
	var source_rect: Rect2

	if destination_cap_width > 0.0:
		destination_rect = Rect2(
			Vector2(-half_width, destination_y),
			Vector2(destination_cap_width, source_height * WORLD_SCALE)
		)
		source_rect = Rect2(
			Vector2(float(left_column) * SOURCE_TILE_SIZE, source_y),
			Vector2(source_cap_width, source_height)
		)
		draw_texture_rect_region(atlas, destination_rect, source_rect, Color.WHITE)

		destination_rect = Rect2(
			Vector2(half_width - destination_cap_width, destination_y),
			Vector2(destination_cap_width, source_height * WORLD_SCALE)
		)
		source_rect = Rect2(
			Vector2(
				float(right_column) * SOURCE_TILE_SIZE + SOURCE_TILE_SIZE - source_cap_width,
				source_y
			),
			Vector2(source_cap_width, source_height)
		)
		draw_texture_rect_region(atlas, destination_rect, source_rect, Color.WHITE)

	var middle_start: float = -half_width + destination_cap_width
	var middle_end: float = half_width - destination_cap_width
	var cursor: float = middle_start
	while cursor < middle_end - MIN_REMAINDER:
		var remaining_middle: float = middle_end - cursor
		var source_middle_width: float = minf(SOURCE_TILE_SIZE, remaining_middle / WORLD_SCALE)
		if source_middle_width <= 0.0:
			break
		var destination_middle_width: float = source_middle_width * WORLD_SCALE
		destination_rect = Rect2(
			Vector2(cursor, destination_y),
			Vector2(destination_middle_width, source_height * WORLD_SCALE)
		)
		source_rect = Rect2(
			Vector2(float(middle_column) * SOURCE_TILE_SIZE, source_y),
			Vector2(source_middle_width, source_height)
		)
		draw_texture_rect_region(atlas, destination_rect, source_rect, Color.WHITE)
		cursor += destination_middle_width
