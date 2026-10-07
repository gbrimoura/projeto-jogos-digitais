@tool
class_name EnemyPatrolArea
extends Node2D

@onready var _left_marker: Marker2D = get_node_or_null("LeftLimit") as Marker2D
@onready var _right_marker: Marker2D = get_node_or_null("RightLimit") as Marker2D
@onready var _preview_line: Line2D = get_node_or_null("PreviewLine") as Line2D

func _ready() -> void:
	if _preview_line != null:
		_preview_line.visible = Engine.is_editor_hint()
	set_process(Engine.is_editor_hint())
	if Engine.is_editor_hint():
		_update_preview()

func _process(_delta: float) -> void:
	if Engine.is_editor_hint():
		_update_preview()

func _update_preview() -> void:
	if _preview_line == null or _left_marker == null or _right_marker == null:
		return
	_preview_line.points = PackedVector2Array([
		to_local(_left_marker.global_position),
		to_local(_right_marker.global_position)
	])