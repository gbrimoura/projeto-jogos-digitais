extends Node2D

const HudBitmapTextScript = preload("res://scripts/ui/hud/bitmap_text.gd")

@export_range(32.0, 160.0, 1.0) var interaction_distance: float = 84.0

@onready var _vendor_sprite: Sprite2D = $VendorSprite

var _room: Node
var _player: Node2D
var _nearby: bool = false
var _animation_time: float = 0.0
var _animation_frame: int = 0
var _font_bundle: Dictionary = {}

func configure(room: Node, player: Node2D) -> void:
	_room = room
	_player = player

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_font_bundle = HudBitmapTextScript.load_font_bundle()
	_update_animation_frame()

func _process(delta: float) -> void:
	if not is_instance_valid(_room) or not is_instance_valid(_player):
		_set_nearby(false)
		return
	var close_enough: bool = not bool(_player.get("is_dead")) \
		and global_position.distance_to(_player.global_position) <= interaction_distance
	_set_nearby(close_enough)
	_animation_time += delta
	if _animation_time >= 0.28:
		_animation_time = 0.0
		_animation_frame = (_animation_frame + 1) % 4
		_update_animation_frame()

func _unhandled_input(event: InputEvent) -> void:
	if not _nearby or not event.is_action_pressed(&"interact"):
		return
	if event is InputEventKey and (event as InputEventKey).echo:
		return
	if _room.has_method("request_shop_offer") and bool(_room.call("request_shop_offer")):
		get_viewport().set_input_as_handled()

func _set_nearby(value: bool) -> void:
	if _nearby == value:
		return
	_nearby = value
	queue_redraw()

func _update_animation_frame() -> void:
	if _vendor_sprite == null:
		return
	_vendor_sprite.region_rect = Rect2(_animation_frame * 64.0, 0.0, 64.0, 64.0)

func _draw() -> void:
	if not _nearby or not bool(_font_bundle.get("valid", false)):
		return
	var atlas: Texture2D = _font_bundle.get("atlas") as Texture2D
	var glyphs_variant: Variant = _font_bundle.get("glyphs", {})
	if typeof(glyphs_variant) != TYPE_DICTIONARY:
		return
	var glyphs: Dictionary = glyphs_variant
	var advance: int = int(_font_bundle.get("advance", 6))
	var line_height: int = int(_font_bundle.get("line_height", 12))
	var value: String = "E: NEGOCIAR"
	if atlas == null or glyphs.is_empty() or advance <= 0 or line_height <= 0:
		return
	var text_width: float = float(value.length() * advance)
	var box := Rect2(Vector2(-text_width * 0.5 - 5.0, -138.0), Vector2(text_width + 10.0, float(line_height + 6)))
	draw_rect(box, Color("#0b1b23"))
	draw_rect(box, Color("#d2a75c"), false, 1.0)
	var origin := Vector2(-text_width * 0.5, box.position.y + 3.0)
	for index in range(value.length()):
		var glyph_variant: Variant = glyphs.get(value.substr(index, 1), null)
		if typeof(glyph_variant) != TYPE_DICTIONARY:
			continue
		var glyph: Dictionary = glyph_variant
		var source_rect: Rect2i = glyph.get("rect", Rect2i())
		draw_texture_rect_region(
			atlas,
			Rect2(origin + Vector2(float(index * advance), 0.0), Vector2(source_rect.size)),
			Rect2(Vector2(source_rect.position), Vector2(source_rect.size)),
			Color("#e8d8b5")
		)