extends Area2D

signal transition_requested(player: Player)

@export_enum("Exit", "Entrance") var door_role: int = 0
@export var player_path: NodePath = NodePath("../Player")
@export var gate_path: NodePath = NodePath("../WorldCollision/ExitGate")
@export var portal_direction: Vector2i = Vector2i.RIGHT
@export var portal_offset: float = 496.0

@onready var _door_visual: Node2D = get_node_or_null("SideDoorVisual") as Node2D
@onready var _door_foreground: Node2D = get_node_or_null("SideDoorVisual/DoorForegroundVisual") as Node2D
@onready var _direction_indicator: Node2D = get_node_or_null("ExitDirectionIndicator") as Node2D
@onready var _door_label: Label = get_node_or_null("DoorLabel") as Label

var _room_root: Node2D
var _player: Player
var _gate: CollisionShape2D
var _room_is_cleared: bool = false
var _transition_busy: bool = false
var _terminal_complete: bool = false
var _retry_enabled: bool = true
var _failure_message: String = ""
var _sample_initialized: bool = false
var _previous_center_room := Vector2.ZERO
var _crossing_armed: bool = false
var _crossing_latched: bool = false
var _latched_player: Player
var _managed_orientation_configured: bool = false
var _standalone_failure_displayed_text: String = ""

func _ready() -> void:
	_room_root = get_parent() as Node2D
	_player = get_node_or_null(player_path) as Player
	_gate = get_node_or_null(gate_path) as CollisionShape2D
	if _door_visual != null:
		_door_visual.z_as_relative = false
		_door_visual.z_index = -1
	if _door_foreground != null:
		_door_foreground.z_as_relative = false
		_door_foreground.z_index = 1
		if _door_visual != null:
			_door_foreground.set("flip_h", bool(_door_visual.get("flip_h")))
	if _direction_indicator != null:
		_direction_indicator.z_as_relative = false
		_direction_indicator.z_index = 1
	if _managed_orientation_configured:
		_configure_visual_orientation(portal_direction)
	if door_role == 0 and _gate != null:
		_gate.set_deferred("disabled", false)
	_update_presentation()

func configure_managed_orientation(direction: Vector2i, offset: float, is_exit: bool) -> void:
	_managed_orientation_configured = true
	portal_direction = direction
	portal_offset = offset
	door_role = 0 if is_exit else 1
	if direction == Vector2i(-1, 0):
		position = Vector2(32.0, 496.0)
	elif direction == Vector2i(1, 0):
		position = Vector2(1120.0, 496.0)
	elif direction == Vector2i(0, -1):
		position = Vector2(offset, 32.0)
	else:
		position = Vector2(offset, 604.0)
	var sensor := get_node_or_null("SensorShape") as CollisionShape2D
	if sensor != null:
		sensor.position = Vector2.ZERO
		var rectangle := RectangleShape2D.new()
		rectangle.resource_local_to_scene = true
		rectangle.size = Vector2(64.0, 128.0) if direction.x != 0 else Vector2(256.0, 96.0)
		sensor.shape = rectangle
	_configure_visual_orientation(direction)
	_update_presentation()

func _configure_visual_orientation(direction: Vector2i) -> void:
	var visual_position := Vector2(0.0, -16.0) if direction == Vector2i(0, -1) else Vector2.ZERO
	var visual_size := Vector2(64.0, 128.0) if direction.x != 0 else Vector2(256.0, 96.0)
	if _door_visual != null:
		_door_visual.position = visual_position
		_door_visual.rotation = 0.0
		_door_visual.set("aperture_size", visual_size)
		_door_visual.set("flip_h", direction == Vector2i(-1, 0))
		_door_visual.z_as_relative = false
		_door_visual.z_index = -1
	if _door_foreground != null:
		_door_foreground.rotation = 0.0
		_door_foreground.set("aperture_size", visual_size)
		_door_foreground.set("flip_h", direction == Vector2i(-1, 0))
		_door_foreground.z_as_relative = false
		_door_foreground.z_index = 1
	if _direction_indicator != null:
		_direction_indicator.rotation = 0.0
		_direction_indicator.z_as_relative = false
		_direction_indicator.z_index = 1
func _physics_process(_delta: float) -> void:
	if door_role != 0 or _player == null or not is_instance_valid(_player):
		return
	var center_value: Variant = _player_collider_center_in_room(_player)
	if center_value == null:
		return
	var current_center: Vector2 = center_value
	if not _sample_initialized:
		_previous_center_room = current_center
		_sample_initialized = true
		return

	var current_distance := _signed_distance(current_center)
	var previous_distance := _signed_distance(_previous_center_room)
	if not _crossing_armed and current_distance < (-2.0 if _managed_orientation_configured else 0.0) and (_retry_enabled or not _transition_busy):
		_crossing_armed = true
		_clear_standalone_failure_status()
		_failure_message = ""
		_update_presentation()

	if _room_is_cleared and not _transition_busy and not _crossing_latched \
		and _crossing_armed and previous_distance < 0.0 and current_distance >= 0.0 \
		and (current_center - _previous_center_room).dot(_normal()) > 0.0 \
		and _point_is_inside_exit_opening(current_center):
		_crossing_latched = true
		_crossing_armed = false
		_latched_player = _player
		_transition_busy = true
		_failure_message = ""
		_update_presentation()
		transition_requested.emit(_player)

	_previous_center_room = current_center

func set_room_cleared(cleared: bool) -> void:
	if door_role != 0 or _terminal_complete:
		return
	_room_is_cleared = cleared
	if _gate != null:
		_gate.set_deferred("disabled", cleared)
	if not cleared:
		_transition_busy = false
		_clear_standalone_failure_status()
		_failure_message = ""
		_crossing_latched = false
		_latched_player = null
		_crossing_armed = false
		_sample_initialized = false
	elif _player != null and is_instance_valid(_player):
		var center_value: Variant = _player_collider_center_in_room(_player)
		if center_value != null:
			_previous_center_room = center_value
			_sample_initialized = true
			_crossing_armed = _signed_distance(_previous_center_room) < (-2.0 if _managed_orientation_configured else 0.0)
	_update_presentation()

func set_transition_busy(busy: bool) -> void:
	if door_role != 0 or _terminal_complete:
		return
	if busy and not _room_is_cleared:
		return
	_transition_busy = busy
	if busy:
		_clear_standalone_failure_status()
		_failure_message = ""
	_update_presentation()

func set_retry_enabled(enabled: bool) -> void:
	_retry_enabled = enabled

func report_transition_failure(message: String) -> void:
	if door_role != 0 or _terminal_complete:
		return
	_failure_message = message.strip_edges()
	_crossing_latched = false
	_latched_player = null
	_crossing_armed = false
	if _retry_enabled:
		_transition_busy = false
	else:
		_transition_busy = true
	_show_standalone_failure_status(_failure_message)
	_update_presentation()

func has_latched_crossing(player: Player) -> bool:
	return (
		door_role == 0
		and _room_is_cleared
		and _transition_busy
		and _crossing_latched
		and player != null
		and is_instance_valid(player)
		and player == _latched_player
		and _player == player
	)

func is_player_inside_exit_opening(player: Player) -> bool:
	if player == null or not is_instance_valid(player) or player != _player:
		return false
	var center_value: Variant = _player_collider_center_in_room(player)
	if center_value == null:
		return false
	var center: Vector2 = center_value
	return _signed_distance(center) >= 0.0 and _point_is_inside_exit_opening(center)

func is_gate_open() -> bool:
	return _gate != null and _gate.disabled

func set_terminal_complete() -> void:
	_terminal_complete = true
	_room_is_cleared = false
	_transition_busy = false
	_clear_standalone_failure_status()
	_failure_message = ""
	_crossing_latched = false
	_latched_player = null
	_crossing_armed = false
	if _gate != null:
		_gate.set_deferred("disabled", false)
	_update_presentation()

func _player_collider_center_in_room(player: Player) -> Variant:
	if _room_root == null or not is_instance_valid(_room_root):
		return null
	var collision := player.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision == null or collision.shape == null:
		return null
	var center_global := collision.global_transform * collision.shape.get_rect().get_center()
	return _room_root.to_local(center_global)

func _line_point_in_room() -> Vector2:
	if _room_root == null:
		return position
	if not _managed_orientation_configured and _gate != null and _gate.shape != null:
		var gate_center_global := _gate.global_transform * _gate.shape.get_rect().get_center()
		return _room_root.to_local(gate_center_global)
	return _room_root.to_local(global_position)

func _normal() -> Vector2:
	return Vector2(portal_direction)

func _signed_distance(center_room: Vector2) -> float:
	return (center_room - _line_point_in_room()).dot(_normal())

func _point_is_inside_exit_opening(center_room: Vector2) -> bool:
	if _gate == null or _room_root == null or _gate.shape == null:
		return false
	var gate_to_room := _room_root.global_transform.affine_inverse() * _gate.global_transform
	var opening := _transform_rect(_gate.shape.get_rect(), gate_to_room)
	return opening.has_point(center_room)

func _transform_rect(rect: Rect2, transform: Transform2D) -> Rect2:
	var a := transform * rect.position
	var b := transform * Vector2(rect.end.x, rect.position.y)
	var c := transform * rect.end
	var d := transform * Vector2(rect.position.x, rect.end.y)
	var minimum := Vector2(
		minf(minf(a.x, b.x), minf(c.x, d.x)),
		minf(minf(a.y, b.y), minf(c.y, d.y))
	)
	var maximum := Vector2(
		maxf(maxf(a.x, b.x), maxf(c.x, d.x)),
		maxf(maxf(a.y, b.y), maxf(c.y, d.y))
	)
	return Rect2(minimum, maximum - minimum)

func _update_presentation() -> void:
	if _door_label != null:
		_door_label.text = ""
		_door_label.visible = false
	var opening_is_open := door_role == 0 and _room_is_cleared and not _terminal_complete
	if is_instance_valid(_door_visual) and _door_visual.has_method("set_aperture_open"):
		_door_visual.call("set_aperture_open", opening_is_open)
	if is_instance_valid(_door_foreground) and _door_foreground.has_method("set_aperture_open"):
		_door_foreground.call("set_aperture_open", opening_is_open)
	if is_instance_valid(_direction_indicator) and _direction_indicator.has_method("configure"):
		var indicator_visible := door_role == 0 and _room_is_cleared \
			and not _terminal_complete and not _transition_busy
		var line_local := Vector2.ZERO
		if _room_root != null and is_instance_valid(_room_root):
			line_local = to_local(_room_root.to_global(_line_point_in_room()))
		var indicator_position := line_local + _indicator_offset()
		_direction_indicator.call("configure", portal_direction, indicator_position, indicator_visible)

func _indicator_offset() -> Vector2:
	if portal_direction.x != 0:
		return Vector2(-float(portal_direction.x) * 48.0, -96.0)
	if portal_direction == Vector2i(0, -1):
		return Vector2(0.0, 88.0)
	if portal_direction == Vector2i(0, 1):
		return Vector2(0.0, -96.0)
	return Vector2.ZERO

func _show_standalone_failure_status(message: String) -> void:
	if message.is_empty() or _is_managed_room():
		return
	if _room_root == null or not is_instance_valid(_room_root):
		return
	var label := _room_root.get_node_or_null("CombatRoom/HUD/StatusLabel") as Label
	if label == null:
		push_warning("ExitDoor: HUD/StatusLabel não está disponível para mostrar falha standalone.")
		return
	label.text = message
	_standalone_failure_displayed_text = message

func _clear_standalone_failure_status() -> void:
	if _standalone_failure_displayed_text.is_empty() or _is_managed_room():
		return
	if _room_root != null and is_instance_valid(_room_root):
		var label := _room_root.get_node_or_null("CombatRoom/HUD/StatusLabel") as Label
		if label != null and label.text == _standalone_failure_displayed_text:
			label.text = ""
	_standalone_failure_displayed_text = ""

func _is_managed_room() -> bool:
	var ancestor := get_parent()
	while ancestor != null:
		if ancestor.has_method("is_active_room_instance"):
			return true
		ancestor = ancestor.get_parent()
	return false
