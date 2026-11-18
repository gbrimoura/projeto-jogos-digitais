class_name HudBallGaugePanel
extends Control

@export var enabled: bool = false:
	set(value):
		enabled = value
		visible = enabled and _speed_ratio > 0.0

var _speed_ratio: float = 0.0
var _reading: Label

func set_enabled(value: bool) -> void:
	enabled = value

func set_speed_ratio(value: float) -> void:
	if is_equal_approx(value, _speed_ratio):
		return
	_speed_ratio = value
	visible = enabled and _speed_ratio > 0.0
	$Needle.rotation = lerpf(-0.95, 0.95, clampf((_speed_ratio - 1.0) / 0.6, 0.0, 1.0))
	if is_instance_valid(_reading):
		_reading.text = "%d%%" % roundi(_speed_ratio * 100.0)

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	$Needle.pivot_offset = Vector2(18.0, 17.0)
	$ConceptLabel.hide()
	_reading = Label.new()
	_reading.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_reading.position = Vector2(0.0, 10.0)
	_reading.size.x = 84.0
	_reading.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_reading.add_theme_font_size_override("font_size", 13)
	_reading.add_theme_color_override("font_color", Color("#ffdf9a"))
	add_child(_reading)
	visible = false
