class_name CaldeiraHudRoot
extends Control

signal enabled_changed(enabled: bool)

@export var enabled: bool = true:
	set(value):
		if enabled == value:
			return
		enabled = value
		enabled_changed.emit(enabled)
@export var show_ball_gauge: bool = false
@export_range(1, 2, 1) var module_pixel_scale: int = 1
@export var player_panel_position: Vector2 = Vector2(8.0, 8.0)
@export var dash_panel_position: Vector2 = Vector2(8.0, 52.0)
@export var target_panel_position: Vector2 = Vector2(216.0, 8.0)
@export var room_panel_position: Vector2 = Vector2(484.0, 8.0)
@export var gauge_panel_position: Vector2 = Vector2(484.0, 48.0)

const BITMAP_TEXT_SCRIPT = preload("res://scripts/ui/hud/bitmap_text.gd")

@onready var _player_panel: Control = $Content/PlayerHealth
@onready var _dash_panel: Control = $Content/Dash
@onready var _target_panel: Control = $Content/Target
@onready var _room_panel: Control = $Content/RoomProgress
@onready var _gauge_panel: Control = $Content/BallGauge
@onready var _build_text: Control = $Content/BuildText

var _font_ready: bool = false

func _ready() -> void:
	custom_minimum_size = Vector2(576.0, 324.0)
	size = Vector2(576.0, 324.0)
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var font_bundle: Dictionary = BITMAP_TEXT_SCRIPT.load_font_bundle()
	_font_ready = bool(font_bundle.get("valid", false))
	if _font_ready:
		for node: Node in find_children("*", "Control", true, false):
			if node.has_method("configure_font"):
				node.call("configure_font", font_bundle)
	_apply_layout()
	_gauge_panel.call("set_enabled", show_ball_gauge)
	_target_panel.call("clear_target")
	if not _font_ready:
		hide()

func is_font_ready() -> bool:
	return _font_ready

func set_health(current: int, maximum: int) -> void:
	_player_panel.call("set_health", current, maximum)

func set_dash(state: StringName, remaining: float, duration: float) -> void:
	_dash_panel.call("set_dash", state, remaining, duration)

func set_target(target_name: String, current: int, maximum: int, portrait: Texture2D) -> void:
	_target_panel.call("set_target", target_name, current, maximum, portrait)
	_target_panel.show()

func clear_target() -> void:
	_target_panel.call("clear_target")
	_target_panel.hide()

func set_progress(floor_index: int, floor_total: int, room_index: int, room_total: int, is_boss: bool) -> void:
	_room_panel.call("set_progress", floor_index, floor_total, room_index, room_total, is_boss)

func set_status(value: String) -> void:
	$Content/StatusText.call("set_text", value)

func set_build(value: String) -> void:
	_build_text.call("set_text", value)

func _apply_layout() -> void:
	var pixel_scale: float = float(maxi(module_pixel_scale, 1))
	$Content/PlayerHealth.position = player_panel_position.round()
	$Content/Dash.position = dash_panel_position.round()
	$Content/Target.position = target_panel_position.round()
	$Content/RoomProgress.position = room_panel_position.round()
	$Content/BallGauge.position = gauge_panel_position.round()
	$Content/PlayerHealth.scale = Vector2.ONE * pixel_scale
	$Content/Dash.scale = Vector2.ONE * pixel_scale
	$Content/Target.scale = Vector2.ONE * pixel_scale
	$Content/RoomProgress.scale = Vector2.ONE * pixel_scale
	$Content/BallGauge.scale = Vector2.ONE * pixel_scale
	$Content/StatusText.position = Vector2(8.0, 264.0)
	_build_text.position = Vector2(8.0, 302.0)