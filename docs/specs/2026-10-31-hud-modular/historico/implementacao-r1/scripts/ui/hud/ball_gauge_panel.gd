class_name HudBallGaugePanel
extends Control

@export var enabled: bool = false:
	set(value):
		enabled = value
		visible = enabled

func set_enabled(value: bool) -> void:
	enabled = value

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	visible = enabled