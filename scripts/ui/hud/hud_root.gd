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
@export var show_debug_details: bool = false:
	set(value):
		if show_debug_details == value:
			return
		show_debug_details = value
		if is_node_ready():
			_apply_status_visibility()
			_apply_layout()
@export_range(1, 2, 1) var module_pixel_scale: int = 1:
	set(value):
		var safe_value: int = clampi(value, 1, 2)
		if module_pixel_scale == safe_value:
			return
		module_pixel_scale = safe_value
		if is_node_ready():
			_apply_layout()
@export var player_panel_position: Vector2 = Vector2(8.0, 8.0):
	set(value):
		if player_panel_position == value:
			return
		player_panel_position = value
		if is_node_ready():
			_apply_layout()
@export var dash_panel_position: Vector2 = Vector2(8.0, 52.0):
	set(value):
		if dash_panel_position == value:
			return
		dash_panel_position = value
		if is_node_ready():
			_apply_layout()
@export var target_panel_position: Vector2 = Vector2(216.0, 8.0):
	set(value):
		if target_panel_position == value:
			return
		target_panel_position = value
		if is_node_ready():
			_apply_layout()
@export var room_panel_position: Vector2 = Vector2(484.0, 8.0):
	set(value):
		if room_panel_position == value:
			return
		room_panel_position = value
		if is_node_ready():
			_apply_layout()
@export var gauge_panel_position: Vector2 = Vector2(484.0, 48.0):
	set(value):
		if gauge_panel_position == value:
			return
		gauge_panel_position = value
		if is_node_ready():
			_apply_layout()

const BITMAP_TEXT_SCRIPT = preload("res://scripts/ui/hud/bitmap_text.gd")
const REFERENCE_WIDTH: float = 576.0
const MINIMUM_STAGE_SIZE: Vector2 = Vector2(576.0, 324.0)
const EDITOR_STAGE_SIZE: Vector2 = Vector2(960.0, 540.0)
const STATUS_SIDE_PADDING: float = 8.0
const STATUS_BOTTOM_PADDING: float = 8.0
const STATUS_LINE_HEIGHT: float = 12.0
const DEBUG_STATUS_LINES: int = 3
const STATUS_BUILD_GAP: float = 2.0

@onready var _player_panel: Control = $Content/PlayerHealth
@onready var _dash_panel: Control = $Content/Dash
@onready var _target_panel: Control = $Content/Target
@onready var _room_panel: Control = $Content/RoomProgress
@onready var _gauge_panel: Control = $Content/BallGauge
@onready var _status_text: Control = $Content/StatusText
@onready var _build_text: Control = $Content/BuildText

var _font_ready: bool = false

func _ready() -> void:
	custom_minimum_size = MINIMUM_STAGE_SIZE
	size = EDITOR_STAGE_SIZE
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var font_bundle: Dictionary = BITMAP_TEXT_SCRIPT.load_font_bundle()
	_font_ready = bool(font_bundle.get("valid", false))
	if _font_ready:
		for node: Node in find_children("*", "Control", true, false):
			if node.has_method("configure_font"):
				node.call("configure_font", font_bundle)
	_apply_status_visibility()
	_apply_layout()
	_gauge_panel.call("set_enabled", show_ball_gauge)
	_target_panel.call("clear_target")
	if not _font_ready:
		hide()

func is_font_ready() -> bool:
	return _font_ready

func set_available_stage_size(value: Vector2) -> void:
	var available_size: Vector2 = Vector2(maxf(value.x, 0.0), maxf(value.y, 0.0)).round()
	var safe_size: Vector2 = Vector2(
		maxf(available_size.x, MINIMUM_STAGE_SIZE.x),
		maxf(available_size.y, MINIMUM_STAGE_SIZE.y)
	)
	if size == safe_size:
		return
	size = safe_size
	_apply_layout()

func set_health(current: int, maximum: int) -> void:
	_player_panel.call("set_health", current, maximum)

func set_dash(state: StringName, remaining: float, duration: float) -> void:
	_dash_panel.call("set_dash", state, remaining, duration)

func set_target(target_name: String, current: int, maximum: int, portrait: Texture2D, level: int = 1) -> void:
	_target_panel.call("set_target", target_name, current, maximum, portrait, level)
	_target_panel.show()

func clear_target() -> void:
	_target_panel.call("clear_target")
	_target_panel.hide()

func set_progress(floor_index: int, floor_total: int, room_index: int, room_total: int, is_boss: bool) -> void:
	_room_panel.call("set_progress", floor_index, floor_total, room_index, room_total, is_boss)

func set_status(value: String) -> void:
	var display_value: String = value
	if not show_debug_details:
		var status_lines: PackedStringArray = value.replace("\r", "").split("\n")
		display_value = status_lines[0] if not status_lines.is_empty() else ""
		var normalized_status: String = display_value.strip_edges().to_upper()
		if normalized_status in ["ENCONTRO ATIVO", "PREPARANDO ENCONTRO"]:
			display_value = ""
	_status_text.call("set_text", display_value)

func set_build(value: String) -> void:
	_build_text.call("set_text", value)
	_build_text.visible = show_debug_details and not value.is_empty()

func _apply_status_visibility() -> void:
	if _status_text == null or _build_text == null:
		return
	_status_text.set("max_lines", DEBUG_STATUS_LINES if show_debug_details else 1)
	_build_text.visible = show_debug_details and not String(_build_text.get("text")).is_empty()

func _apply_layout() -> void:
	if _player_panel == null or _dash_panel == null or _target_panel == null \
		or _room_panel == null or _gauge_panel == null or _status_text == null or _build_text == null:
		return
	var pixel_scale: float = float(_effective_module_scale())
	var player_size: Vector2 = _panel_native_size(_player_panel, Vector2(144.0, 40.0))
	var target_size: Vector2 = _panel_native_size(_target_panel, Vector2(144.0, 40.0))
	var room_size: Vector2 = _panel_native_size(_room_panel, Vector2(84.0, 36.0))
	var gauge_size: Vector2 = _panel_native_size(_gauge_panel, Vector2(84.0, 77.0))
	# Existing exports retain their 576-wide meaning: left/top offsets, center delta, or right margin.
	_player_panel.position = player_panel_position.round()
	var dash_gap: float = dash_panel_position.y - player_panel_position.y - player_size.y
	_dash_panel.position = Vector2(
		roundf(dash_panel_position.x),
		roundf(player_panel_position.y + player_size.y * pixel_scale + dash_gap)
	)
	_target_panel.position = Vector2(
		roundf((size.x - target_size.x * pixel_scale) * 0.5 \
			+ target_panel_position.x - (REFERENCE_WIDTH - target_size.x) * 0.5),
		roundf(target_panel_position.y)
	)
	_room_panel.position = Vector2(
		roundf(size.x - room_size.x * pixel_scale \
			- _reference_right_margin(room_panel_position.x, room_size.x)),
		roundf(room_panel_position.y)
	)
	var gauge_gap: float = gauge_panel_position.y - room_panel_position.y - room_size.y
	_gauge_panel.position = Vector2(
		roundf(size.x - gauge_size.x * pixel_scale \
			- _reference_right_margin(gauge_panel_position.x, gauge_size.x)),
		roundf(room_panel_position.y + room_size.y * pixel_scale + gauge_gap)
	)
	_player_panel.scale = Vector2.ONE * pixel_scale
	_dash_panel.scale = Vector2.ONE * pixel_scale
	_target_panel.scale = Vector2.ONE * pixel_scale
	_room_panel.scale = Vector2.ONE * pixel_scale
	_gauge_panel.scale = Vector2.ONE * pixel_scale
	var status_lines: int = DEBUG_STATUS_LINES if show_debug_details else 1
	var build_height: float = STATUS_LINE_HEIGHT if show_debug_details else 0.0
	var status_height: float = STATUS_LINE_HEIGHT * float(status_lines)
	var footer_stack_height: float = status_height
	if show_debug_details:
		footer_stack_height += STATUS_BUILD_GAP + build_height
	var status_y: float = roundf(size.y - STATUS_BOTTOM_PADDING - footer_stack_height)
	var footer_width: float = maxf(size.x - STATUS_SIDE_PADDING * 2.0, 0.0)
	_status_text.position = Vector2(STATUS_SIDE_PADDING, status_y)
	_status_text.size = Vector2(footer_width, status_height)
	_build_text.position = Vector2(STATUS_SIDE_PADDING, roundf(size.y - STATUS_BOTTOM_PADDING - build_height))
	_build_text.size = Vector2(footer_width, build_height)
	_apply_status_visibility()

func _effective_module_scale() -> int:
	var requested_scale: int = clampi(module_pixel_scale, 1, 2)
	if requested_scale == 1:
		return 1
	var player_size: Vector2 = _panel_native_size(_player_panel, Vector2(144.0, 40.0))
	var target_size: Vector2 = _panel_native_size(_target_panel, Vector2(144.0, 40.0))
	var room_size: Vector2 = _panel_native_size(_room_panel, Vector2(84.0, 36.0))
	var pixel_scale: float = float(requested_scale)
	var target_x: float = (size.x - target_size.x * pixel_scale) * 0.5 \
		+ target_panel_position.x - (REFERENCE_WIDTH - target_size.x) * 0.5
	var room_x: float = size.x - room_size.x * pixel_scale \
		- _reference_right_margin(room_panel_position.x, room_size.x)
	var player_right: float = player_panel_position.x + player_size.x * pixel_scale
	var target_right: float = target_x + target_size.x * pixel_scale
	if player_right > target_x or target_right > room_x:
		return 1
	return requested_scale

func _panel_native_size(panel: Control, fallback: Vector2) -> Vector2:
	var panel_size: Vector2 = panel.size
	if panel_size.x <= 0.0 or panel_size.y <= 0.0:
		panel_size = panel.custom_minimum_size
	if panel_size.x <= 0.0 or panel_size.y <= 0.0:
		return fallback
	return panel_size

func _reference_right_margin(reference_x: float, native_width: float) -> float:
	return maxf(REFERENCE_WIDTH - reference_x - native_width, 0.0)
