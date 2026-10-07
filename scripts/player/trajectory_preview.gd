class_name TrajectoryPreview
extends Node2D

const MAX_QUERY_ITERATIONS: int = 24
const POSITION_EPSILON_SQUARED: float = 0.01
const DIRECTION_EPSILON_SQUARED: float = 0.000001

@export var path_color: Color = Color("#e7b25e")
@export var outline_color: Color = Color("#101722")
@export var bounce_color: Color = Color("#ffdf9a")
@export var endpoint_color: Color = Color("#f4d18a")
@export var warning_color: Color = Color("#e9795e")

@export_range(80.0, 480.0, 16.0)
var preview_distance: float = 240.0

@export_range(0.05, 0.8, 0.05)
var path_opacity: float = 0.4

@export_range(6.0, 24.0, 1.0)
var dot_spacing: float = 13.0

@export_range(1.0, 3.0, 0.25)
var dot_radius: float = 1.5

var _aim_controller: AimController
var _shot_origin: Node2D
var _ball_launcher: BallLauncher
var _projectile_shape: CircleShape2D
var _prediction_query: PhysicsShapeQueryParameters2D
var _path_points: PackedVector2Array = PackedVector2Array()
var _bounce_points: PackedVector2Array = PackedVector2Array()
var _blocked: bool = false
var _bounce_limit_reached: bool = false
var _query_limit_reached: bool = false
var _dirty: bool = true
var _has_cached_state: bool = false
var _last_origin: Vector2 = Vector2.ZERO
var _last_direction: Vector2 = Vector2.ZERO
var _last_mobile_enemy_positions: Dictionary = {}

func configure(
	aim_controller: AimController,
	shot_origin: Node2D,
	ball_launcher: BallLauncher
) -> void:
	_aim_controller = aim_controller
	_shot_origin = shot_origin
	_ball_launcher = ball_launcher
	if _aim_controller != null and not _aim_controller.aim_changed.is_connected(_on_aim_changed):
		_aim_controller.aim_changed.connect(_on_aim_changed)
	_dirty = true

func _physics_process(_delta: float) -> void:
	if _aim_controller == null or _shot_origin == null or _ball_launcher == null:
		visible = false
		return
	if _mobile_enemy_positions_changed():
		_dirty = true

	if not _ball_launcher.is_launch_available():
		visible = false
		_has_cached_state = false
		return

	visible = true
	var direction := _aim_controller.aim_direction.normalized()
	if direction.is_zero_approx():
		direction = Vector2.RIGHT
	var shot_origin_position := _shot_origin.global_position

	if (
		_has_cached_state
		and not _dirty
		and _last_origin.distance_squared_to(shot_origin_position) <= POSITION_EPSILON_SQUARED
		and _last_direction.distance_squared_to(direction) <= DIRECTION_EPSILON_SQUARED
	):
		return

	var spawn_position := _ball_launcher.get_spawn_position_for_direction(direction)
	var blocked := not spawn_position.is_finite()
	var prediction_origin := shot_origin_position if blocked else spawn_position
	_has_cached_state = true
	_last_origin = shot_origin_position
	_last_direction = direction
	_dirty = false
	_build_prediction(prediction_origin, direction, blocked)

func _mobile_enemy_positions_changed() -> bool:
	var current_positions: Dictionary = {}
	var changed := false
	for enemy in get_tree().get_nodes_in_group("combat_enemy"):
		if not enemy is CharacterBody2D:
			continue
		var enemy_id := enemy.get_instance_id()
		var enemy_position: Vector2 = enemy.global_position
		current_positions[enemy_id] = enemy_position
		if (
			not _last_mobile_enemy_positions.has(enemy_id)
			or _last_mobile_enemy_positions[enemy_id].distance_squared_to(enemy_position)
			> POSITION_EPSILON_SQUARED
		):
			changed = true
	for enemy_id in _last_mobile_enemy_positions:
		if not current_positions.has(enemy_id):
			changed = true
	_last_mobile_enemy_positions = current_positions
	return changed

func _on_aim_changed(_direction: Vector2, _target_position: Vector2) -> void:
	_dirty = true

func _build_prediction(start_position: Vector2, initial_direction: Vector2, blocked: bool) -> void:
	_path_points.clear()
	_bounce_points.clear()
	_blocked = blocked
	_bounce_limit_reached = false
	_query_limit_reached = false
	_append_global_point(start_position)
	if blocked:
		queue_redraw()
		return

	var config := _ball_launcher.projectile_config
	var full_distance := maxf(config.speed, 0.0) * maxf(config.lifetime, 0.0)
	var remaining_distance := minf(full_distance, maxf(preview_distance, 0.0))
	var current_position := start_position
	var direction := initial_direction
	var bounce_count := 0
	var iterations := 0
	_ensure_prediction_query(config)

	var space_state := get_world_2d().direct_space_state
	while remaining_distance > 0.01 and iterations < MAX_QUERY_ITERATIONS:
		iterations += 1
		var motion := direction * remaining_distance
		_prediction_query.transform = Transform2D(0.0, current_position)
		_prediction_query.motion = motion
		var fractions := space_state.cast_motion(_prediction_query)
		if fractions.size() < 2:
			_query_limit_reached = true
			break

		var safe_fraction := clampf(fractions[0], 0.0, 1.0)
		var unsafe_fraction := clampf(fractions[1], 0.0, 1.0)
		if safe_fraction >= 1.0:
			_append_global_point(current_position + motion)
			remaining_distance = 0.0
			break

		var contact_center := current_position + motion * safe_fraction
		_append_global_point(contact_center)
		remaining_distance *= 1.0 - safe_fraction

		_prediction_query.transform = Transform2D(
			0.0,
			current_position + motion * unsafe_fraction
		)
		_prediction_query.motion = Vector2.ZERO
		var contact_info := space_state.get_rest_info(_prediction_query)
		if contact_info.is_empty():
			_query_limit_reached = true
			break

		var surface_normal: Vector2 = contact_info.get("normal", Vector2.ZERO)
		surface_normal = surface_normal.normalized()
		if surface_normal.is_zero_approx():
			_query_limit_reached = true
			break

		var velocity := direction * config.speed
		if not BounceResolver.should_bounce(velocity, surface_normal):
			velocity = BounceResolver.slide_velocity(
				velocity,
				surface_normal,
				config.speed
			)
			if velocity.is_zero_approx():
				remaining_distance = 0.0
				break
			direction = velocity.normalized()
			current_position = contact_center + surface_normal * config.collision_skin
			continue

		if bounce_count >= config.max_bounces:
			_bounce_limit_reached = true
			break

		bounce_count += 1
		_bounce_points.append(to_local(contact_center))
		velocity = BounceResolver.reflect_velocity(
			velocity,
			surface_normal,
			config.speed
		)
		if velocity.is_zero_approx():
			_query_limit_reached = true
			break
		direction = velocity.normalized()
		current_position = contact_center + surface_normal * config.collision_skin

	if iterations >= MAX_QUERY_ITERATIONS and remaining_distance > 0.01:
		_query_limit_reached = true
	queue_redraw()

func _ensure_prediction_query(config: ProjectileConfig) -> void:
	if _projectile_shape == null:
		_projectile_shape = CircleShape2D.new()
	if _prediction_query == null:
		_prediction_query = PhysicsShapeQueryParameters2D.new()
		_prediction_query.shape = _projectile_shape
		_prediction_query.collide_with_bodies = true
		_prediction_query.collide_with_areas = false

	_projectile_shape.radius = config.collision_radius
	_prediction_query.collision_mask = config.collision_mask
	_prediction_query.margin = maxf(config.collision_safe_margin, 0.01)

func _append_global_point(global_point: Vector2) -> void:
	var local_point := to_local(global_point)
	if (
		_path_points.is_empty()
		or _path_points[_path_points.size() - 1].distance_squared_to(local_point)
		> POSITION_EPSILON_SQUARED
	):
		_path_points.append(local_point)

func _draw() -> void:
	if _path_points.size() > 1:
		_draw_dotted_path()

	for bounce_point in _bounce_points:
		draw_circle(bounce_point, 7.0, outline_color)
		draw_arc(bounce_point, 5.5, 0.0, TAU, 24, bounce_color, 1.8, true)
		draw_circle(bounce_point, 2.0, bounce_color)

	if _path_points.is_empty():
		return
	var endpoint := _path_points[_path_points.size() - 1]
	if _blocked:
		draw_circle(endpoint, 8.0, outline_color)
		draw_arc(endpoint, 6.0, 0.0, TAU, 24, warning_color, 2.0, true)
		draw_line(endpoint + Vector2(-3.0, -3.0), endpoint + Vector2(3.0, 3.0), warning_color, 2.0, true)
		draw_line(endpoint + Vector2(3.0, -3.0), endpoint + Vector2(-3.0, 3.0), warning_color, 2.0, true)
	elif _query_limit_reached:
		draw_circle(endpoint, 7.0, outline_color)
		draw_circle(endpoint, 4.0, warning_color)
	elif _bounce_limit_reached:
		draw_circle(endpoint, 7.0, outline_color)
		draw_arc(endpoint, 5.5, 0.0, TAU, 24, bounce_color, 1.8, true)
		draw_circle(endpoint, 2.0, bounce_color)
	else:
		draw_circle(endpoint, 2.5, endpoint_color)

func _draw_dotted_path() -> void:
	var dot_color := path_color
	dot_color.a *= path_opacity
	var dot_outline := outline_color
	dot_outline.a *= path_opacity * 0.35
	var spacing := maxf(dot_spacing, 1.0)

	for segment_index in range(_path_points.size() - 1):
		var start := _path_points[segment_index]
		var end := _path_points[segment_index + 1]
		var segment_length := start.distance_to(end)
		if segment_length <= 0.01:
			continue
		var segment_direction := (end - start).normalized()
		var distance_along := 0.0
		while distance_along <= segment_length:
			var point := start + segment_direction * distance_along
			draw_circle(point, dot_radius + 0.75, dot_outline)
			draw_circle(point, dot_radius, dot_color)
			distance_along += spacing
