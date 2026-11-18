extends Node2D

const RoomTransition = preload("res://scripts/world/room_transition.gd")
const DESIGN_SIZE: Vector2 = Vector2(1152.0, 648.0)
const ELEVATOR_INTERIOR: Rect2 = Rect2(912.0, 448.0, 128.0, 112.0)
const RUN_ROOT_PATH: String = "res://run_root.tscn"

@onready var _player: CharacterBody2D = get_node("Player") as CharacterBody2D
@onready var _ball_container: Node2D = get_node("BallContainer") as Node2D
@onready var _camera: Camera2D = get_node("LobbyCamera") as Camera2D
@onready var _world_visual: Node2D = get_node("EnvironmentVisual") as Node2D
@onready var _door_visual: Node2D = get_node("ElevatorDoorForeground") as Node2D
@onready var _fade_rect: ColorRect = get_node("LobbyUI/Fade") as ColorRect
@onready var _status: Control = get_node("LobbyUI/ElevatorStatus") as Control

var _travel_in_progress: bool = false
var _must_exit_cabin_before_retry: bool = false
var _player_process_mode_before_travel: int = Node.PROCESS_MODE_INHERIT
var _ball_container_process_mode_before_travel: int = Node.PROCESS_MODE_INHERIT

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_INHERIT
	RoomTransition.clear_pending_snapshot()
	_fade_rect.color = Color(0.0431373, 0.0627451, 0.0901961, 0.0)
	_set_status("", false)
	var viewport: Viewport = get_viewport()
	if viewport != null:
		viewport.size_changed.connect(Callable(self, "_update_camera_fit"))
	_update_camera_fit()

func _physics_process(_delta: float) -> void:
	if _travel_in_progress:
		return
	var player_bounds: Rect2 = _player_world_aabb()
	if not _rect_has_area(player_bounds):
		return
	if _must_exit_cabin_before_retry:
		if not player_bounds.intersects(ELEVATOR_INTERIOR):
			_must_exit_cabin_before_retry = false
		return
	if bool(_player.get("is_dead")) or not _player.is_on_floor():
		return
	if ELEVATOR_INTERIOR.encloses(player_bounds):
		_begin_elevator_travel()

func _update_camera_fit() -> void:
	if _camera == null:
		return
	var viewport: Viewport = get_viewport()
	if viewport == null:
		return
	var viewport_size: Vector2 = viewport.get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		return
	var horizontal_fit: float = viewport_size.x / DESIGN_SIZE.x
	var vertical_fit: float = viewport_size.y / DESIGN_SIZE.y
	var zoom_factor: float = minf(horizontal_fit, vertical_fit)
	if not is_finite(zoom_factor) or zoom_factor <= 0.0:
		zoom_factor = 1.0
	_camera.position = DESIGN_SIZE * 0.5
	_camera.zoom = Vector2(zoom_factor, zoom_factor)

func _player_world_aabb() -> Rect2:
	if _player == null or not is_instance_valid(_player):
		return Rect2()
	var collision_shape: CollisionShape2D = _player.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision_shape == null or collision_shape.disabled or collision_shape.shape == null:
		return Rect2()
	var local_rect: Rect2 = collision_shape.shape.get_rect()
	if local_rect.size.x <= 0.0 or local_rect.size.y <= 0.0:
		return Rect2()
	var transform: Transform2D = collision_shape.global_transform
	var corners: PackedVector2Array = PackedVector2Array([
		local_rect.position,
		Vector2(local_rect.end.x, local_rect.position.y),
		local_rect.end,
		Vector2(local_rect.position.x, local_rect.end.y),
	])
	var first: Vector2 = transform * corners[0]
	var minimum_x: float = first.x
	var minimum_y: float = first.y
	var maximum_x: float = first.x
	var maximum_y: float = first.y
	for corner_index: int in range(1, corners.size()):
		var world_corner: Vector2 = transform * corners[corner_index]
		minimum_x = minf(minimum_x, world_corner.x)
		minimum_y = minf(minimum_y, world_corner.y)
		maximum_x = maxf(maximum_x, world_corner.x)
		maximum_y = maxf(maximum_y, world_corner.y)
	return Rect2(
		Vector2(minimum_x, minimum_y),
		Vector2(maximum_x - minimum_x, maximum_y - minimum_y)
	)

func _rect_has_area(rect: Rect2) -> bool:
	return rect.size.x > 0.0 and rect.size.y > 0.0

func _begin_elevator_travel() -> void:
	if _travel_in_progress or _player == null or _ball_container == null:
		return
	if bool(_player.get("is_dead")) or not _player.is_on_floor():
		return
	var player_bounds: Rect2 = _player_world_aabb()
	if not ELEVATOR_INTERIOR.encloses(player_bounds):
		return

	_set_status("", false)

	# Latch and save inherited processing before the first asynchronous cue.
	_travel_in_progress = true
	_player_process_mode_before_travel = _player.process_mode
	_ball_container_process_mode_before_travel = _ball_container.process_mode
	_player.process_mode = Node.PROCESS_MODE_DISABLED
	_ball_container.process_mode = Node.PROCESS_MODE_DISABLED
	_reset_lobby_combat_transients()
	RoomTransition.clear_pending_snapshot()

	await _tween_door_fraction(1.0, 0.20)
	await _play_travel_cue()
	_set_status("ANDAR 01", true)
	await _fade_to(1.0, 0.20)

	var change_error: int = get_tree().change_scene_to_file(RUN_ROOT_PATH)
	if change_error == OK:
		return
	await _recover_failed_elevator_load()

func _reset_lobby_combat_transients() -> void:
	var launcher: Node = _player.get_node_or_null("BallLauncher")
	if launcher != null and launcher.has_method("reset"):
		launcher.call("reset")
	var racket: Node = _player.get_node_or_null("RacketController")
	if racket != null and racket.has_method("cancel"):
		racket.call("cancel")

func _play_travel_cue() -> void:
	for cue_index: int in range(5):
		var lights_on: bool = cue_index % 2 == 0
		_world_visual.call("set_amber_lights_on", lights_on)
		var shake: Vector2 = Vector2(2.0, 0.0) if cue_index % 2 == 0 else Vector2(-2.0, 1.0)
		_camera.offset = shake
		var timer: SceneTreeTimer = get_tree().create_timer(0.065)
		await timer.timeout
	_camera.offset = Vector2.ZERO
	_world_visual.call("set_amber_lights_on", true)

func _tween_door_fraction(target: float, duration: float) -> void:
	var tween: Tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_method(
		Callable(_door_visual, "set_door_closed_fraction"),
		float(_door_visual.get("door_closed_fraction")),
		target,
		duration
	)
	await tween.finished

func _fade_to(alpha: float, duration: float) -> void:
	var tween: Tween = create_tween()
	tween.set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(_fade_rect, "color:a", alpha, duration)
	await tween.finished

func _recover_failed_elevator_load() -> void:
	RoomTransition.clear_pending_snapshot()
	_must_exit_cabin_before_retry = true
	await _tween_door_fraction(0.0, 0.16)
	_world_visual.call("set_amber_lights_on", false)
	_camera.offset = Vector2.ZERO
	_set_status("ERRO AO ABRIR\nSAIA E ENTRE PARA TENTAR", true)
	await _fade_to(0.0, 0.18)
	_player.process_mode = _player_process_mode_before_travel
	_ball_container.process_mode = _ball_container_process_mode_before_travel
	_travel_in_progress = false

func _set_status(message: String, visible_state: bool) -> void:
	_status.call("set_text", message)
	_status.visible = visible_state
