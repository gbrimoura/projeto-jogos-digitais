@tool
extends Sprite2D

const BASE_TEXTURES = [
	preload("res://resources/environment/factory_floor1_base_boiler_texture.tres"),
	preload("res://resources/environment/factory_floor1_base_maintenance_texture.tres"),
]
const LEFT_MODULE_TEXTURES = [
	preload("res://resources/environment/factory_floor1_left_boiler_texture.tres"),
	preload("res://resources/environment/factory_floor1_left_cabinets_texture.tres"),
]
const RIGHT_MODULE_TEXTURES = [
	preload("res://resources/environment/factory_floor1_right_service_texture.tres"),
	preload("res://resources/environment/factory_floor1_right_press_texture.tres"),
]
const LEFT_MODULE_ANCHORS = [Vector2i(20, 12), Vector2i(18, 36)]
const RIGHT_MODULE_ANCHORS = [Vector2i(326, 24), Vector2i(223, 25)]
# Base wall, left module, right module. -1 leaves a wall bay open.
const MAINTENANCE := [Vector3i(1, 1, 0), Vector3i(1, 1, 1), Vector3i(1, -1, 1)]
const FOUNDRY := [Vector3i(0, 0, 0), Vector3i(0, 0, -1), Vector3i(0, 1, 1)]
const SERVICE := [Vector3i(1, -1, 0), Vector3i(1, 1, -1), Vector3i(0, -1, 1)]

@export_enum("Boiler wall", "Maintenance wall") var fallback_base_variant: int = 0
@export_enum("Boiler circuit", "Service cabinets") var fallback_left_variant: int = 0
@export_enum("Service sign", "Press") var fallback_right_variant: int = 0
@export var choose_from_room_seed: bool = true

var _glass_gallery: bool = false
var _fixture_positions: PackedVector2Array = PackedVector2Array()
var _fixture_style: int = 0

func _ready() -> void:
	centered = false
	position = Vector2.ZERO
	scale = Vector2(2.0, 2.0)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_fixture_positions.clear()
	for module_name in ["__factory_floor1_left", "__factory_floor1_right"]:
		var old := get_node_or_null(NodePath(module_name))
		if old != null:
			old.free()

	var world: Node = get_parent()
	if world != null:
		world = world.get_parent()
	_glass_gallery = (
		not Engine.is_editor_hint() and world != null and world.has_method("uses_glass_gallery_background")
		and bool(world.call("uses_glass_gallery_background"))
	)
	if _glass_gallery:
		texture = BASE_TEXTURES[1]
		queue_redraw()
		return

	var variants := _resolve_variants(world)
	texture = BASE_TEXTURES[variants.x]
	if variants.y >= 0:
		_add_module("__factory_floor1_left", LEFT_MODULE_TEXTURES[variants.y], LEFT_MODULE_ANCHORS[variants.y])
	if variants.z >= 0:
		_add_module("__factory_floor1_right", RIGHT_MODULE_TEXTURES[variants.z], RIGHT_MODULE_ANCHORS[variants.z])
	queue_redraw()

func _draw() -> void:
	if not _glass_gallery:
		_draw_fixtures()
		return
	draw_rect(Rect2(65, 46, 446, 146), Color("#102433"))
	draw_rect(Rect2(69, 50, 438, 138), Color("#2b515d"))
	for index in 6:
		var left := float(74 + index * 71)
		draw_rect(Rect2(left, 55, 67, 128), Color("#172f3b"))
		draw_rect(Rect2(left + 3, 58, 61, 62), Color("#284752"))
		draw_rect(Rect2(left + 7, 67, 42, 3), Color("#426773"))
		draw_rect(Rect2(left + 42, 148, 14, 35), Color("#203c48"))
		draw_rect(Rect2(left + 12, 160, 22, 23), Color("#102632"))
	draw_rect(Rect2(65, 116, 446, 5), Color("#314754"))
	draw_rect(Rect2(65, 188, 446, 4), Color("#98784d"))

func _draw_fixtures() -> void:
	if _fixture_positions.is_empty():
		return
	draw_rect(Rect2(36, 19, 504, 3), Color("#263036"))
	for point in _fixture_positions:
		draw_rect(Rect2(point, Vector2(3, 13)), Color("#263036"))
		draw_rect(Rect2(point + Vector2(-7, 11), Vector2(17, 7)), Color("#2f3b40"))
		var light := Color("#9b7442") if _fixture_style == 0 else Color("#587a80")
		draw_rect(Rect2(point + Vector2(-5, 14), Vector2(13, 2)), light)

func _resolve_variants(main_room: Node) -> Vector3i:
	var fallback := Vector3i(
		clampi(fallback_base_variant, 0, 1),
		clampi(fallback_left_variant, 0, 1),
		clampi(fallback_right_variant, 0, 1)
	)
	if Engine.is_editor_hint() or not choose_from_room_seed:
		return fallback

	if main_room == null or not main_room.has_method("get_room_visual_family"):
		return fallback
	var family := StringName(main_room.call("get_room_visual_family"))
	if family.is_empty():
		return fallback

	var rng := RandomNumberGenerator.new()
	rng.seed = int(main_room.call("get_prepared_room_layout_seed")) ^ 0x4445434F
	var recipes: Array = FOUNDRY
	if family == &"valley":
		recipes = MAINTENANCE
	elif family == &"roof_four" or family == &"roof_five":
		recipes = SERVICE
	elif family == &"catwalk":
		recipes = MAINTENANCE + SERVICE
	var picked: Vector3i = recipes[rng.randi_range(0, recipes.size() - 1)]
	_fixture_style = rng.randi_range(0, 1)
	# Keep ceiling openings and windows out of the fixture strip.
	for x: float in [48.0, 196.0, 375.0, 526.0]:
		if rng.randi_range(0, 2) > 0:
			_fixture_positions.append(Vector2(x, 22.0))
	return picked

func _add_module(node_name: String, module_texture: Texture2D, anchor: Vector2i) -> void:
	var module_sprite := Sprite2D.new()
	module_sprite.name = node_name
	module_sprite.centered = false
	module_sprite.position = Vector2(anchor)
	module_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	module_sprite.z_index = 1
	module_sprite.texture = module_texture
	add_child(module_sprite)