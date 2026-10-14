@tool
class_name SolidPlatform
extends StaticBody2D

@export var size: Vector2 = Vector2(220.0, 24.0):
	set(value):
		size = Vector2(maxf(value.x, 1.0), maxf(value.y, 1.0))
		_sync_geometry()

@export var fill_color: Color = Color("#263545"):
	set(value):
		fill_color = value
		_sync_geometry()

@export var factory_skin_enabled: bool = false:
	set(value):
		factory_skin_enabled = value
		_sync_surface_skin()

@export_enum("Platform", "Block") var factory_surface_style: int = 0:
	set(value):
		factory_surface_style = clampi(value, 0, 1)
		_sync_surface_skin()

func _ready() -> void:
	_sync_geometry()

func _sync_geometry() -> void:
	var collision_shape := get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape != null:
		var rectangle := collision_shape.shape as RectangleShape2D
		if rectangle != null:
			if not rectangle.resource_local_to_scene:
				rectangle = rectangle.duplicate() as RectangleShape2D
				rectangle.resource_local_to_scene = true
				collision_shape.shape = rectangle
			rectangle.size = size

	var half_size := size * 0.5
	var visual_fill := get_node_or_null("Visuals/Fill") as Polygon2D
	if visual_fill != null:
		visual_fill.color = fill_color
		visual_fill.polygon = PackedVector2Array([
			Vector2(-half_size.x, -half_size.y),
			Vector2(half_size.x, -half_size.y),
			Vector2(half_size.x, half_size.y),
			Vector2(-half_size.x, half_size.y),
		])

	var top_edge := get_node_or_null("Visuals/TopEdge") as Line2D
	if top_edge != null:
		top_edge.points = PackedVector2Array([
			Vector2(-half_size.x, -half_size.y),
			Vector2(half_size.x, -half_size.y),
		])

	var floor_detail := get_node_or_null("FloorDetail") as Line2D
	if floor_detail != null:
		floor_detail.position = Vector2(0.0, -half_size.y + 32.0)
		floor_detail.points = PackedVector2Array([
			Vector2(-half_size.x, 0.0),
			Vector2(half_size.x, 0.0),
		])

	_sync_surface_skin()

func _sync_surface_skin() -> void:
	var surface_visual := get_node_or_null("Visuals/FactorySurfaceVisual") as Node2D
	var visual_fill := get_node_or_null("Visuals/Fill") as Polygon2D
	var top_edge := get_node_or_null("Visuals/TopEdge") as Line2D
	var floor_detail := get_node_or_null("FloorDetail") as Line2D
	var use_factory_skin: bool = factory_skin_enabled and surface_visual != null
	if surface_visual != null:
		surface_visual.set("surface_size", size)
		surface_visual.set("surface_style", factory_surface_style)
		surface_visual.visible = use_factory_skin
	if visual_fill != null:
		visual_fill.visible = not use_factory_skin
	if top_edge != null:
		top_edge.visible = not use_factory_skin
	if floor_detail != null:
		floor_detail.visible = not use_factory_skin
