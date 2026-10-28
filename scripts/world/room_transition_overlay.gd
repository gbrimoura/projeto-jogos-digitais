extends CanvasLayer

const RoomTransition = preload("res://scripts/world/room_transition.gd")
const FADE_OUT_SECONDS: float = 0.18
const FADE_IN_SECONDS: float = 0.22
const MAX_SCENE_WAIT_FRAMES: int = 120

var _owner: Node
var _source_scene: Node
var _destination_scene: PackedScene
var _transition_token: int = -1
var _backdrop: ColorRect
var _alpha: float = 0.0
var _tween: Tween
var _phase: StringName = &"idle"
var _wait_frames: int = 0
var _swap_accepted: bool = false
var _pending_failure_message: String = ""
var _rollback_after_accepted_swap_timeout: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 100
	_backdrop = ColorRect.new()
	_backdrop.name = "Fade"
	_backdrop.color = Color(0.0, 0.0, 0.0, 0.0)
	_backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(_backdrop)
	set_process(false)

func begin_transition(owner: Node, source_scene: Node, destination_scene: PackedScene, token: int) -> bool:
	if _phase != &"idle" or owner == null or source_scene == null or destination_scene == null:
		return false
	_owner = owner
	_source_scene = source_scene
	_destination_scene = destination_scene
	_transition_token = token
	_phase = &"fade_out"
	_start_fade(1.0, FADE_OUT_SECONDS, _on_fade_out_finished)
	return true

func cancel_transition() -> void:
	if _tween != null and _tween.is_running():
		_tween.kill()
	_tween = null
	if not _swap_accepted:
		RoomTransition.clear_pending_snapshot()
	_phase = &"cancelled"
	set_process(false)
	queue_free()

func _start_fade(target_alpha: float, duration: float, completion: Callable) -> void:
	if _tween != null and _tween.is_running():
		_tween.kill()
	_tween = create_tween()
	_tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_tween.tween_method(_set_alpha, _alpha, target_alpha, duration)
	_tween.tween_callback(completion)

func _set_alpha(value: float) -> void:
	_alpha = clampf(value, 0.0, 1.0)
	if _backdrop != null and is_instance_valid(_backdrop):
		var tint := _backdrop.color
		tint.a = _alpha
		_backdrop.color = tint

func _on_fade_out_finished() -> void:
	if not _is_owner_valid_before_swap():
		RoomTransition.clear_pending_snapshot()
		_pending_failure_message = "TRANSIÇÃO CANCELADA"
		_phase = &"fade_in_failure"
		_start_fade(0.0, FADE_IN_SECONDS, _finish)
		return

	var result := int(_owner.call("commit_standalone_room_swap", _transition_token, _destination_scene))
	if result != OK:
		RoomTransition.clear_pending_snapshot()
		_pending_failure_message = _swap_error_message(result)
		_phase = &"fade_in_failure"
		_start_fade(0.0, FADE_IN_SECONDS, _finish)
		return

	_swap_accepted = true
	_phase = &"waiting_for_scene"
	_wait_frames = 0
	set_process(true)

func _process(_delta: float) -> void:
	if _phase != &"waiting_for_scene":
		return
	var tree := get_tree()
	if tree == null:
		_clear_after_unrecoverable_swap()
		return
	var current_scene := tree.current_scene
	if current_scene != null and current_scene != _source_scene and current_scene.is_node_ready():
		_phase = &"fade_in_success"
		set_process(false)
		_start_fade(0.0, FADE_IN_SECONDS, _finish)
		return

	_wait_frames += 1
	if _wait_frames >= MAX_SCENE_WAIT_FRAMES:
		if is_instance_valid(_source_scene) and current_scene == _source_scene:
			_pending_failure_message = "FALHA AO ABRIR A SALA"
			_rollback_after_accepted_swap_timeout = true
			_swap_accepted = false
			_phase = &"fade_in_failure"
			set_process(false)
			_start_fade(0.0, FADE_IN_SECONDS, _finish)
		else:
			_clear_after_unrecoverable_swap()

func _is_owner_valid_before_swap() -> bool:
	if not is_instance_valid(_owner) or not is_instance_valid(_source_scene):
		return false
	if get_tree().current_scene != _source_scene:
		return false
	return _owner.has_method("is_standalone_transition_valid") \
		and bool(_owner.call("is_standalone_transition_valid", _transition_token))

func _clear_after_unrecoverable_swap() -> void:
	RoomTransition.clear_pending_snapshot()
	_swap_accepted = false
	_phase = &"fade_in_recovery"
	set_process(false)
	_start_fade(0.0, FADE_IN_SECONDS, _finish)

func _finish() -> void:
	if not _pending_failure_message.is_empty():
		if _rollback_after_accepted_swap_timeout:
			var rollback_completed: bool = false
			if is_instance_valid(_owner) \
				and _owner.has_method("transition_overlay_source_still_active_after_timeout"):
				rollback_completed = bool(_owner.call(
					"transition_overlay_source_still_active_after_timeout",
					_transition_token,
					_pending_failure_message
				))
			if not rollback_completed:
				var tree: SceneTree = get_tree()
				var current_scene: Node = tree.current_scene if tree != null else null
				var new_scene_ready: bool = current_scene != null \
					and current_scene != _source_scene and current_scene.is_node_ready()
				if not new_scene_ready:
					# Without a ready destination or an accepted rollback, there is
					# no scene that can safely consume this snapshot.
					RoomTransition.clear_pending_snapshot()
		else:
			if is_instance_valid(_owner) and _owner.has_method("transition_overlay_failed"):
				_owner.call("transition_overlay_failed", _transition_token, _pending_failure_message)
	_pending_failure_message = ""
	_rollback_after_accepted_swap_timeout = false
	if is_instance_valid(_owner) and _owner.has_method("transition_overlay_finished"):
		_owner.call("transition_overlay_finished", _transition_token)
	_phase = &"finished"
	set_process(false)
	queue_free()

func _swap_error_message(error_code: int) -> String:
	if error_code == ERR_INVALID_DATA:
		return "FALHA AO PREPARAR TRANSIÇÃO"
	return "FALHA AO CARREGAR SALA"
