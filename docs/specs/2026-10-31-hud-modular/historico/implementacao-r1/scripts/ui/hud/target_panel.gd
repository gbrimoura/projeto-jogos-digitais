class_name HudTargetPanel
extends Control

@onready var _portrait: TextureRect = $Portrait
@onready var _name_text: Control = $NameText
@onready var _value_text: Control = $ValueText
@onready var _bar: Control = $HealthBar

func set_target(target_name: String, current: int, maximum: int, portrait: Texture2D) -> void:
	var value_text: String = "%d/%d" % [current, maximum]
	_name_text.call("set_text", target_name)
	_value_text.call("set_text", value_text)
	_layout_text_fields(value_text)
	_bar.call("set_values", current, maximum)
	_portrait.texture = portrait
	_portrait.visible = portrait != null
	if portrait != null:
		var portrait_size: Vector2 = portrait.get_size()
		_portrait.size = portrait_size
		_portrait.position = Vector2(
			6.0 + floorf((32.0 - portrait_size.x) * 0.5),
			6.0 + floorf((28.0 - portrait_size.y) * 0.5)
		)
	show()

func _layout_text_fields(value_text: String) -> void:
	const ADVANCE: float = 6.0
	const LEFT: float = 42.0
	const RIGHT: float = 138.0
	const GAP: float = 4.0
	var value_width: float = minf(float(value_text.length()) * ADVANCE, 42.0)
	var value_left: float = RIGHT - value_width
	var name_right: float = maxf(LEFT, value_left - GAP)
	_name_text.position = Vector2(LEFT, 6.0)
	_name_text.size = Vector2(name_right - LEFT, 12.0)
	_value_text.position = Vector2(value_left, 6.0)
	_value_text.size = Vector2(value_width, 12.0)

func clear_target() -> void:
	_name_text.call("set_text", "")
	_value_text.call("set_text", "")
	_bar.call("set_values", 0, 0)
	_portrait.texture = null
	_portrait.hide()
	hide()