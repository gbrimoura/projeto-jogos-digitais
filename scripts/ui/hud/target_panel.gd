class_name HudTargetPanel
extends Control

const TARGET_BAR_FILL: Texture2D = preload("res://assets/ui/hud_caldeira_v1/export/bar-fill-target-90x8.png")
const PORTRAIT_REGION: Vector2 = Vector2(32.0, 28.0)
const BAR_POSITION: Vector2 = Vector2(42.0, 30.0)
const BAR_SIZE: Vector2 = Vector2(96.0, 6.0)
const BAR_OUTER_COLOR: Color = Color("0E0D0E")
const BAR_BORDER_COLOR: Color = Color("4B555D")
const BAR_BACKGROUND_COLOR: Color = Color("0C1B29")
const BAR_FILL_SOURCE: Rect2 = Rect2(0.0, 2.0, 90.0, 2.0)

@onready var _portrait: TextureRect = $Portrait
@onready var _name_text: Control = $NameText
@onready var _level_text: Control = $LevelText
@onready var _value_text: Control = $ValueText

var _current_health: int = 0
var _maximum_health: int = 0

func set_target(target_name: String, current: int, maximum: int, portrait: Texture2D, level: int = 1) -> void:
	_name_text.call("set_text", target_name)
	_level_text.call("set_text", "NV%d" % maxi(level, 1))
	_value_text.call("set_text", "%d/%d" % [current, maximum])
	_current_health = current
	_maximum_health = maximum
	_set_portrait(portrait)
	queue_redraw()
	show()

func _set_portrait(portrait: Texture2D) -> void:
	_portrait.texture = portrait
	_portrait.visible = portrait != null
	if portrait == null:
		return
	var natural_size: Vector2 = portrait.get_size()
	var display_size: Vector2 = natural_size
	if natural_size.x > PORTRAIT_REGION.x or natural_size.y > PORTRAIT_REGION.y:
		var contain_scale: float = minf(
			PORTRAIT_REGION.x / natural_size.x,
			PORTRAIT_REGION.y / natural_size.y
		)
		display_size = Vector2(
			maxf(floorf(natural_size.x * contain_scale), 1.0),
			maxf(floorf(natural_size.y * contain_scale), 1.0)
		)
	_portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	_portrait.stretch_mode = TextureRect.STRETCH_SCALE
	_portrait.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_portrait.size = display_size
	_portrait.position = Vector2(
		6.0 + floorf((PORTRAIT_REGION.x - display_size.x) * 0.5),
		6.0 + floorf((PORTRAIT_REGION.y - display_size.y) * 0.5)
	)

func _draw() -> void:
	var outer_rect: Rect2 = Rect2(BAR_POSITION, BAR_SIZE)
	draw_rect(outer_rect, BAR_OUTER_COLOR)
	draw_rect(Rect2(BAR_POSITION + Vector2.ONE, BAR_SIZE - Vector2(2.0, 2.0)), BAR_BORDER_COLOR)
	draw_rect(Rect2(BAR_POSITION + Vector2(2.0, 2.0), BAR_SIZE - Vector2(4.0, 4.0)), BAR_BACKGROUND_COLOR)
	if _maximum_health <= 0:
		return
	var health_ratio: float = clampf(float(_current_health) / float(_maximum_health), 0.0, 1.0)
	var filled_width: int = int(floor(90.0 * health_ratio + 0.5))
	if filled_width <= 0:
		return
	var fill_destination: Rect2 = Rect2(BAR_POSITION + Vector2(3.0, 2.0), Vector2(float(filled_width), 2.0))
	var fill_source: Rect2 = Rect2(BAR_FILL_SOURCE.position, Vector2(float(filled_width), BAR_FILL_SOURCE.size.y))
	draw_texture_rect_region(TARGET_BAR_FILL, fill_destination, fill_source)

func clear_target() -> void:
	_name_text.call("set_text", "")
	_level_text.call("set_text", "")
	_value_text.call("set_text", "")
	_current_health = 0
	_maximum_health = 0
	_portrait.texture = null
	_portrait.hide()
	queue_redraw()
	hide()