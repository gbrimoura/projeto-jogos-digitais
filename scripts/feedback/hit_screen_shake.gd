extends Node

const DURATION: float = 0.13
const MIN_RETRIGGER_INTERVAL: float = 0.045
const MAX_OFFSET: float = 3.0

var _viewport: Viewport
var _base_transform := Transform2D.IDENTITY
var _last_transform := Transform2D.IDENTITY
var _elapsed: float = DURATION
var _amplitude: float = 0.0
var _direction: Vector2 = Vector2.RIGHT
var _owns_transform: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_viewport = get_viewport()
	set_process(false)

func kick(strength: float, direction: Vector2) -> void:
	if not is_instance_valid(_viewport) or get_tree().paused or _viewport.get_camera_2d() != null:
		return
	var next_amplitude := clampf(strength, 0.0, MAX_OFFSET)
	var can_restart := _elapsed >= MIN_RETRIGGER_INTERVAL
	if not can_restart and next_amplitude <= _amplitude:
		return
	if not _owns_transform or not _viewport.canvas_transform.is_equal_approx(_last_transform):
		_base_transform = _viewport.canvas_transform
		_last_transform = _base_transform
		_owns_transform = true
	_amplitude = next_amplitude
	_direction = Vector2.RIGHT if direction.is_zero_approx() else direction.normalized()
	if can_restart:
		_elapsed = 0.0
	set_process(true)
	_apply_offset()

func _process(delta: float) -> void:
	if not is_instance_valid(_viewport) or get_tree().paused or _viewport.get_camera_2d() != null:
		_clear()
		return
	_elapsed += delta
	if _elapsed >= DURATION or not _viewport.canvas_transform.is_equal_approx(_last_transform):
		_clear()
		return
	_apply_offset()

func _apply_offset() -> void:
	var fade := 1.0 - _elapsed / DURATION
	var swing := cos(_elapsed * TAU * 20.0)
	var offset := (_direction * swing + _direction.orthogonal() * (1.0 - absf(swing)) * 0.45)
	_last_transform = _base_transform
	_last_transform.origin += (offset * _amplitude * fade * fade).round()
	_viewport.canvas_transform = _last_transform

func _exit_tree() -> void:
	_clear()

func _clear() -> void:
	if _owns_transform and is_instance_valid(_viewport) and _viewport.canvas_transform.is_equal_approx(_last_transform):
		_viewport.canvas_transform = _base_transform
	_owns_transform = false
	_elapsed = DURATION
	set_process(false)
