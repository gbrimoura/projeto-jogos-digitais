extends Node2D

const FACTORY_ATLAS: Texture2D = preload("res://assets/environment/factory_v1/tileset-fabrica-v1-atlas.png")
const TILE_SIZE: int = 32
const WORLD_WIDTH: int = 1152
const WORLD_HEIGHT: int = 648

const NIGHT: Color = Color("#0E0D0E")
const INK: Color = Color("#0C1B29")
const STEEL: Color = Color("#142C40")
const STEEL_LIGHT: Color = Color("#203E50")
const STEEL_MID: Color = Color("#4B555D")
const STEEL_EDGE: Color = Color("#879198")
const RUST: Color = Color("#70432C")
const AMBER: Color = Color("#D2A75C")
const PALE: Color = Color("#E8D8B5")
const GLASS: Color = Color("#0C1B29")

@export_enum("World background", "Elevator foreground") var visual_layer: int = 0
@export_range(0.0, 1.0, 0.01) var door_closed_fraction: float = 0.0
@export var amber_lights_on: bool = false

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func set_door_closed_fraction(value: float) -> void:
	door_closed_fraction = clampf(value, 0.0, 1.0)
	queue_redraw()

func set_amber_lights_on(value: bool) -> void:
	amber_lights_on = value
	queue_redraw()

func _draw() -> void:
	if visual_layer == 0:
		_draw_world()
	else:
		_draw_elevator_foreground()

func _draw_world() -> void:
	draw_rect(Rect2(0, 0, WORLD_WIDTH, WORLD_HEIGHT), NIGHT)

	# Distant roofline and the tower keep the courtyard enclosed visually.
	draw_rect(Rect2(0, 272, 736, 256), INK)
	draw_rect(Rect2(24, 232, 184, 296), STEEL)
	draw_rect(Rect2(216, 192, 208, 336), INK)
	draw_rect(Rect2(432, 224, 240, 304), STEEL)
	draw_rect(Rect2(704, 80, 400, 448), INK)
	draw_rect(Rect2(736, 40, 352, 488), STEEL)
	draw_rect(Rect2(776, 16, 304, 512), STEEL_LIGHT)
	draw_rect(Rect2(800, 0, 248, 512), STEEL)
	draw_rect(Rect2(824, 0, 16, 512), STEEL_MID)
	draw_rect(Rect2(1032, 0, 16, 512), INK)
	draw_rect(Rect2(816, 48, 240, 8), STEEL_EDGE)
	draw_rect(Rect2(768, 88, 320, 8), STEEL_EDGE)
	draw_rect(Rect2(728, 136, 376, 8), STEEL_EDGE)

	# Windows sit in open wall bays; no pipe or beam crosses the glass.
	for window_y: int in [88, 144, 200, 256, 312]:
		for window_x: int in [744, 784, 864, 904, 984, 1024]:
			draw_rect(Rect2(window_x - 3, window_y - 3, 22, 34), RUST)
			draw_rect(Rect2(window_x, window_y, 16, 28), GLASS)
			draw_rect(Rect2(window_x + 7, window_y, 2, 28), STEEL_EDGE)
			draw_rect(Rect2(window_x, window_y + 13, 16, 2), STEEL_EDGE)
			draw_rect(Rect2(window_x + 3, window_y + 4, 3, 3), AMBER)

	# Small decorative maintenance bench; it has no collision or interaction.
	draw_rect(Rect2(152, 488, 176, 12), INK)
	draw_rect(Rect2(152, 480, 176, 8), RUST)
	draw_rect(Rect2(160, 472, 160, 8), STEEL_MID)
	draw_rect(Rect2(168, 500, 12, 60), STEEL_LIGHT)
	draw_rect(Rect2(296, 500, 12, 60), STEEL_LIGHT)
	draw_rect(Rect2(184, 464, 32, 16), STEEL)
	draw_rect(Rect2(192, 456, 16, 8), AMBER)
	draw_rect(Rect2(240, 468, 40, 12), STEEL)
	draw_rect(Rect2(248, 460, 24, 8), STEEL_EDGE)
	draw_rect(Rect2(204, 504, 80, 4), RUST)

	# Elevator alcove and heavy frame. The entrance remains open at rest.
	draw_rect(Rect2(872, 424, 208, 136), STEEL)
	draw_rect(Rect2(888, 432, 176, 128), STEEL_MID)
	draw_rect(Rect2(904, 448, 144, 112), INK)
	draw_rect(Rect2(912, 448, 128, 112), GLASS)
	draw_rect(Rect2(912, 448, 128, 4), STEEL_EDGE)
	draw_rect(Rect2(912, 556, 128, 4), AMBER)
	draw_rect(Rect2(896, 432, 16, 128), STEEL_LIGHT)
	draw_rect(Rect2(1040, 432, 16, 128), STEEL_LIGHT)
	draw_rect(Rect2(904, 424, 144, 8), AMBER)
	draw_rect(Rect2(904, 438, 144, 4), STEEL_EDGE)

	# A square amber-framed plaque carries the bitmap elevator sign.
	draw_rect(Rect2(888, 384, 176, 40), INK)
	draw_rect(Rect2(888, 384, 176, 3), AMBER)
	draw_rect(Rect2(888, 421, 176, 3), AMBER)
	draw_rect(Rect2(888, 384, 3, 40), AMBER)
	draw_rect(Rect2(1061, 384, 3, 40), AMBER)
	# Three status lamps above the elevator doors.
	for lamp_x: int in [928, 968, 1008]:
		var lamp_color: Color = AMBER if amber_lights_on else STEEL_MID
		draw_rect(Rect2(lamp_x - 7, 428, 14, 14), INK)
		draw_rect(Rect2(lamp_x - 4, 431, 8, 8), lamp_color)

	# Steel courtyard floor: the existing 32 px atlas supplies top, middle and
	# lower edges. Integer destination rectangles and nearest filtering preserve
	# the factory palette and tile silhouette.
	for tile_x_index: int in range(36):
		var tile_x: int = tile_x_index * TILE_SIZE
		var source_x: int = TILE_SIZE
		if tile_x_index == 0:
			source_x = 0
		elif tile_x_index == 35:
			source_x = TILE_SIZE * 2
		draw_texture_rect_region(
			FACTORY_ATLAS,
			Rect2(tile_x, 560, TILE_SIZE, TILE_SIZE),
			Rect2(source_x, 0, TILE_SIZE, TILE_SIZE)
		)
		draw_texture_rect_region(
			FACTORY_ATLAS,
			Rect2(tile_x, 592, TILE_SIZE, TILE_SIZE),
			Rect2(source_x, TILE_SIZE, TILE_SIZE, TILE_SIZE)
		)
		draw_texture_rect_region(
			FACTORY_ATLAS,
			Rect2(tile_x, 624, TILE_SIZE, TILE_SIZE),
			Rect2(source_x, TILE_SIZE * 3, TILE_SIZE, TILE_SIZE)
		)

	for tile_y_index: int in range(21):
		var tile_y: int = tile_y_index * TILE_SIZE
		draw_texture_rect_region(
			FACTORY_ATLAS,
			Rect2(0, tile_y, TILE_SIZE, TILE_SIZE),
			Rect2(0, TILE_SIZE, TILE_SIZE, TILE_SIZE)
		)
		draw_texture_rect_region(
			FACTORY_ATLAS,
			Rect2(WORLD_WIDTH - TILE_SIZE, tile_y, TILE_SIZE, TILE_SIZE),
			Rect2(TILE_SIZE * 2, TILE_SIZE, TILE_SIZE, TILE_SIZE)
		)

	# Bright, uncluttered entrance threshold.
	draw_rect(Rect2(912, 556, 128, 4), PALE)

func _draw_elevator_foreground() -> void:
	var travel: float = clampf(door_closed_fraction, 0.0, 1.0)
	var panel_width: int = 64
	var door_top: int = 448
	var door_height: int = 112
	var left_x: int = 848 + roundi(float(panel_width) * travel)
	var right_x: int = 1040 - roundi(float(panel_width) * travel)

	_draw_door_panel(left_x, door_top, panel_width, door_height, true)
	_draw_door_panel(right_x, door_top, panel_width, door_height, false)

func _draw_door_panel(x: int, y: int, width: int, height: int, is_left: bool) -> void:
	draw_rect(Rect2(x, y, width, height), STEEL)
	draw_rect(Rect2(x + 4, y + 4, width - 8, height - 8), STEEL_LIGHT)
	draw_rect(Rect2(x + 8, y + 8, width - 16, height - 16), STEEL)
	draw_rect(Rect2(x + 12, y + 12, 4, height - 24), STEEL_EDGE)
	draw_rect(Rect2(x + width - 16, y + 12, 4, height - 24), INK)
	draw_rect(Rect2(x + width / 2 - 2, y + 8, 4, height - 16), RUST)
	draw_rect(Rect2(x + width / 2 - 1, y + 16, 2, height - 32), AMBER)
	draw_rect(Rect2(x + 8, y + height - 14, width - 16, 4), AMBER if is_left else RUST)