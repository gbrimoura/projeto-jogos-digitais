class_name HudPlayerHealthPanel
extends Control

@onready var _value: Control = $Value
@onready var _bar: Control = $HealthBar

func set_health(current: int, maximum: int) -> void:
	_value.call("set_text", "%d/%d" % [current, maximum])
	_bar.call("set_values", current, maximum)
	show()