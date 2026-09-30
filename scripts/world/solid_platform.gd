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

func _ready() -> void:
	_sync_geometry()

func _sync_geometry() -> void:
	var collision_shape := get_node_or_null("CollisionShape2D") as CollisionShape2D
	var visual_fill := get_node_or_null("Visuals/Fill") as Polygon2D
	var top_edge := get_node_or_null("Visuals/TopEdge") as Line2D
	if collision_shape == null or visual_fill == null or top_edge == null:
		return

	var rectangle := collision_shape.shape as RectangleShape2D
	if rectangle == null:
		return
	if not rectangle.resource_local_to_scene:
		rectangle = rectangle.duplicate() as RectangleShape2D
		rectangle.resource_local_to_scene = true
		collision_shape.shape = rectangle
	rectangle.size = size
	visual_fill.color = fill_color

	var half_size := size * 0.5
	var floor_detail := get_node_or_null("FloorDetail") as Line2D
	if floor_detail != null:
		floor_detail.position = Vector2(0.0, -half_size.y + 32.0)
		floor_detail.points = PackedVector2Array([
			Vector2(-half_size.x, 0.0),
			Vector2(half_size.x, 0.0),
		])

	visual_fill.polygon = PackedVector2Array([
		Vector2(-half_size.x, -half_size.y),
		Vector2(half_size.x, -half_size.y),
		Vector2(half_size.x, half_size.y),
		Vector2(-half_size.x, half_size.y),
	])
	top_edge.points = PackedVector2Array([
		Vector2(-half_size.x, -half_size.y),
		Vector2(half_size.x, -half_size.y),
	])
