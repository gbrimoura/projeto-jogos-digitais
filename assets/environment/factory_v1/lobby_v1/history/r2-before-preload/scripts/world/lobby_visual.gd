extends Node2D

const FACTORY_ATLAS: Texture2D = preload("res://assets/environment/factory_v1/tileset-fabrica-v1-atlas.png")
const BACKDROP_PATH: String = "res://assets/environment/factory_v1/lobby_v1/export/lobby-backdrop-576x324.png"
const LEFT_DOOR_PATH: String = "res://assets/environment/factory_v1/lobby_v1/export/elevator-door-left-32x56.png"
const RIGHT_DOOR_PATH: String = "res://assets/environment/factory_v1/lobby_v1/export/elevator-door-right-32x56.png"
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

var _backdrop_texture: Texture2D
var _left_door_texture: Texture2D
var _right_door_texture: Texture2D

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	if visual_layer == 0:
		_backdrop_texture = _load_png_texture(BACKDROP_PATH)
	else:
		_left_door_texture = _load_png_texture(LEFT_DOOR_PATH)
		_right_door_texture = _load_png_texture(RIGHT_DOOR_PATH)

func _load_png_texture(path: String) -> Texture2D:
	var image: Image = Image.new()
	var error: Error = image.load(path)
	if error != OK:
		push_error("Could not load lobby visual asset %s: %s" % [path, error_string(error)])
		return null
	return ImageTexture.create_from_image(image)

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
	# Keep a deterministic dark base under the backdrop's transparent floor strip.
	draw_rect(Rect2(0, 0, WORLD_WIDTH, WORLD_HEIGHT), NIGHT)
	if _backdrop_texture != null:
		draw_texture_rect(_backdrop_texture, Rect2(0, 0, WORLD_WIDTH, WORLD_HEIGHT), false)

	# Preserve the user's static amber plaque and the bitmap ElevatorSign node above it.
	draw_rect(Rect2(888, 384, 176, 40), INK)
	draw_rect(Rect2(888, 384, 176, 3), AMBER)
	draw_rect(Rect2(888, 421, 176, 3), AMBER)
	draw_rect(Rect2(888, 384, 3, 40), AMBER)
	draw_rect(Rect2(1061, 384, 3, 40), AMBER)

	# The status lamps remain dynamic and retain their existing positions/colors.
	for lamp_x: int in [928, 968, 1008]:
		var lamp_color: Color = AMBER if amber_lights_on else STEEL_MID
		draw_rect(Rect2(lamp_x - 7, 428, 14, 14), INK)
		draw_rect(Rect2(lamp_x - 4, 431, 8, 8), lamp_color)

	# The existing 32 px atlas supplies the exact continuous floor and side boundaries.
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

func _draw_elevator_foreground() -> void:
	var travel: float = clampf(door_closed_fraction, 0.0, 1.0)
	var panel_width: int = 64
	var door_top: int = 448
	var door_height: int = 112
	var left_x: int = 848 + roundi(float(panel_width) * travel)
	var right_x: int = 1040 - roundi(float(panel_width) * travel)

	if _left_door_texture != null:
		draw_texture_rect(_left_door_texture, Rect2(left_x, door_top, panel_width, door_height), false)
	if _right_door_texture != null:
		draw_texture_rect(_right_door_texture, Rect2(right_x, door_top, panel_width, door_height), false)
