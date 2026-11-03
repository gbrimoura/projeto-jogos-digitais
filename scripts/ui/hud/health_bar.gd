class_name HudHealthBar
extends Control

const BAR_FRAME: Texture2D = preload("res://assets/ui/hud_caldeira_v1/export/bar-frame-96x14.png")

@export var fill_texture: Texture2D
var _current: int = 0
var _maximum: int = 0

func set_values(current: int, maximum: int) -> void:
	_current = current
	_maximum = maximum
	queue_redraw()

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST

func _draw() -> void:
	draw_texture(BAR_FRAME, Vector2.ZERO)
	if fill_texture == null or _maximum <= 0:
		return
	var filled_width: int = int(floor(90.0 * clampf(float(_current) / float(_maximum), 0.0, 1.0) + 0.5))
	if filled_width <= 0:
		return
	var fill_region: Rect2 = Rect2(0.0, 0.0, float(filled_width), 8.0)
	draw_texture_rect_region(fill_texture, Rect2(Vector2(3.0, 3.0), fill_region.size), fill_region)