extends Node2D

const BACKDROP_TEXTURE: Texture2D = preload("res://assets/environment/factory_v1/lobby_v2/factory-lobby-generated-1672x941.png")
const BACKDROP_MOTION_SHADER: Shader = preload("res://scripts/world/lobby_backdrop_motion.gdshader")
const LEFT_DOOR_TEXTURE: Texture2D = preload("res://assets/environment/factory_v1/lobby_v1/export/elevator-door-left-32x56.png")
const RIGHT_DOOR_TEXTURE: Texture2D = preload("res://assets/environment/factory_v1/lobby_v1/export/elevator-door-right-32x56.png")
const WORLD_WIDTH: int = 1152
const FLOOR_TOP_WORLD_Y: float = 560.0
const SOURCE_FLOOR_TOP_Y: float = 808.0
const ELEVATOR_OPENING_RECT: Rect2 = Rect2(908.0, 454.0, 102.0, 106.0)
const DOOR_PANEL_WIDTH: float = ELEVATOR_OPENING_RECT.size.x * 0.5

const INK: Color = Color("#0C1B29")
const STEEL_MID: Color = Color("#4B555D")
const AMBER: Color = Color("#D2A75C")

@export_enum("World background", "Elevator foreground") var visual_layer: int = 0
@export_range(0.0, 1.0, 0.01) var door_closed_fraction: float = 0.0
@export var amber_lights_on: bool = false

func _ready() -> void:
	texture_filter = (
		CanvasItem.TEXTURE_FILTER_LINEAR
		if visual_layer == 0
		else CanvasItem.TEXTURE_FILTER_NEAREST
	)
	if visual_layer == 0:
		_add_animated_backdrop()

func _add_animated_backdrop() -> void:
	var backdrop_sprite := Sprite2D.new()
	backdrop_sprite.name = "BackdropMotion"
	backdrop_sprite.texture = BACKDROP_TEXTURE
	backdrop_sprite.centered = false
	backdrop_sprite.position = Vector2.ZERO
	backdrop_sprite.scale = Vector2(
		float(WORLD_WIDTH) / float(BACKDROP_TEXTURE.get_width()),
		FLOOR_TOP_WORLD_Y / SOURCE_FLOOR_TOP_Y
	)
	backdrop_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
	backdrop_sprite.show_behind_parent = true
	var motion_material := ShaderMaterial.new()
	motion_material.shader = BACKDROP_MOTION_SHADER
	backdrop_sprite.material = motion_material
	add_child(backdrop_sprite)

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
	# The nearest-filter plaque sprite is positioned in lobby.tscn.

	# The three event lamps sit above the plaque and remain visible while the doors are closed.
	for lamp_x: int in [921, 959, 997]:
		var lamp_color: Color = AMBER if amber_lights_on else STEEL_MID
		draw_rect(Rect2(lamp_x - 5, 411, 10, 10), INK)
		draw_rect(Rect2(lamp_x - 3, 413, 6, 6), lamp_color)

func _draw_elevator_foreground() -> void:
	var travel: float = clampf(door_closed_fraction, 0.0, 1.0)
	var opening: Rect2 = ELEVATOR_OPENING_RECT
	var panel_size: Vector2 = Vector2(DOOR_PANEL_WIDTH, opening.size.y)
	var left_open_x: float = opening.position.x - DOOR_PANEL_WIDTH
	var right_open_x: float = opening.end.x
	var left_closed_x: float = opening.position.x
	var right_closed_x: float = opening.position.x + DOOR_PANEL_WIDTH
	var left_x: float = lerpf(left_open_x, left_closed_x, travel)
	var right_x: float = lerpf(right_open_x, right_closed_x, travel)
	_draw_clipped_door(LEFT_DOOR_TEXTURE, Rect2(Vector2(left_x, opening.position.y), panel_size), opening)
	_draw_clipped_door(RIGHT_DOOR_TEXTURE, Rect2(Vector2(right_x, opening.position.y), panel_size), opening)

func _draw_clipped_door(texture: Texture2D, panel_rect: Rect2, opening: Rect2) -> void:
	var visible_rect: Rect2 = panel_rect.intersection(opening)
	if visible_rect.size.x <= 0.0 or visible_rect.size.y <= 0.0:
		return
	var texture_size: Vector2 = Vector2(texture.get_width(), texture.get_height())
	var source_position: Vector2 = (visible_rect.position - panel_rect.position) / panel_rect.size * texture_size
	var source_size: Vector2 = visible_rect.size / panel_rect.size * texture_size
	draw_texture_rect_region(texture, visible_rect, Rect2(source_position, source_size))
