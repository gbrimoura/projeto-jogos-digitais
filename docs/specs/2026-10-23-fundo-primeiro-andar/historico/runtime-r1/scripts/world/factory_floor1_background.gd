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
const RIGHT_MODULE_ANCHORS = [Vector2i(313, 24), Vector2i(223, 25)]

@export_enum("Boiler wall", "Maintenance wall") var fallback_base_variant: int = 0
@export_enum("Boiler circuit", "Service cabinets") var fallback_left_variant: int = 0
@export_enum("Service sign", "Press") var fallback_right_variant: int = 0
@export var choose_from_room_seed: bool = true

func _ready() -> void:
	centered = false
	position = Vector2.ZERO
	scale = Vector2(2.0, 2.0)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

	var variants := _resolve_variants()
	texture = BASE_TEXTURES[variants.x]
	_add_module("__factory_floor1_left", LEFT_MODULE_TEXTURES[variants.y], LEFT_MODULE_ANCHORS[variants.y])
	_add_module("__factory_floor1_right", RIGHT_MODULE_TEXTURES[variants.z], RIGHT_MODULE_ANCHORS[variants.z])

func _resolve_variants() -> Vector3i:
	var fallback := Vector3i(
		clampi(fallback_base_variant, 0, 1),
		clampi(fallback_left_variant, 0, 1),
		clampi(fallback_right_variant, 0, 1)
	)
	if Engine.is_editor_hint() or not choose_from_room_seed:
		return fallback

	var main_room: Node = get_parent()
	if main_room != null:
		main_room = main_room.get_parent()
	if main_room == null or not main_room.has_method("get_prepared_room_layout_seed"):
		return fallback

	var seed := int(main_room.call("get_prepared_room_layout_seed"))
	return Vector3i(seed & 1, (seed >> 1) & 1, (seed >> 2) & 1)

func _add_module(node_name: String, module_texture: Texture2D, anchor: Vector2i) -> void:
	var previous := get_node_or_null(NodePath(node_name))
	if previous != null:
		previous.free()
	var module_sprite := Sprite2D.new()
	module_sprite.name = node_name
	module_sprite.centered = false
	module_sprite.position = Vector2(anchor)
	module_sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	module_sprite.z_index = 1
	module_sprite.texture = module_texture
	add_child(module_sprite)