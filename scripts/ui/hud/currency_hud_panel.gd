class_name CurrencyHudPanel
extends Control

@onready var _value: Control = $Value

func set_currency(value: int) -> void:
	_value.call("set_text", "%d" % maxi(value, 0))