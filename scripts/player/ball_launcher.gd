class_name BallLauncher
extends Node

## Dispara uma única bola por vez sem assumir responsabilidade pela locomoção.

@export var projectile_scene: PackedScene
@export var projectile_config: ProjectileConfig

var _player: Node2D
var _aim_controller: AimController
var _shot_origin: Node2D
var _projectile_parent: Node
var _active_ball: RicochetBall
var _spawn_shape: CircleShape2D
var _spawn_query: PhysicsShapeQueryParameters2D

func configure(
	player: Node2D,
	aim_controller: AimController,
	shot_origin: Node2D,
	projectile_parent: Node
) -> void:
	_player = player
	_aim_controller = aim_controller
	_shot_origin = shot_origin
	_projectile_parent = projectile_parent
	if _projectile_parent == null and _player != null:
		_projectile_parent = _player.get_parent()

func try_launch(triggered: bool) -> bool:
	if not triggered or not is_launch_available():
		return false

	var direction := _aim_controller.aim_direction.normalized()
	if direction.is_zero_approx():
		direction = Vector2.RIGHT
	var spawn_position := get_spawn_position_for_direction(direction)
	if not spawn_position.is_finite():
		return false

	var ball := projectile_scene.instantiate() as RicochetBall
	if ball == null:
		return false

	ball.collision_mask = projectile_config.collision_mask
	_projectile_parent.add_child(ball)
	_active_ball = ball
	ball.finished.connect(_on_ball_finished.bind(ball))
	ball.global_position = spawn_position
	ball.launch(direction, projectile_config)
	return true

func is_launch_available() -> bool:
	if _aim_controller == null or _shot_origin == null:
		return false
	if projectile_scene == null or projectile_config == null or _projectile_parent == null:
		return false
	if _active_ball == null:
		return true
	if is_instance_valid(_active_ball):
		return false
	_active_ball = null
	return true

func reset() -> void:
	if _active_ball != null and is_instance_valid(_active_ball):
		_active_ball.cancel()
	_active_ball = null

func _on_ball_finished(_reason: String, ball: RicochetBall) -> void:
	if ball == _active_ball:
		_active_ball = null

func get_spawn_position_for_direction(direction: Vector2) -> Vector2:
	if _shot_origin == null or projectile_config == null:
		return Vector2.INF

	var launch_direction := direction.normalized()
	if launch_direction.is_zero_approx():
		launch_direction = Vector2.RIGHT

	var config := projectile_config
	_ensure_spawn_query(config)
	var space_state := _shot_origin.get_world_2d().direct_space_state
	var origin := _shot_origin.global_position
	if not _is_spawn_position_clear(space_state, origin):
		return Vector2.INF

	var requested_distance := maxf(config.spawn_offset, 0.0)
	if requested_distance <= 0.0:
		return origin

	var motion := launch_direction * requested_distance
	_spawn_query.transform = Transform2D(0.0, origin)
	_spawn_query.motion = motion
	var fractions := space_state.cast_motion(_spawn_query)
	if fractions.size() < 2:
		return Vector2.INF

	var safe_fraction := clampf(fractions[0], 0.0, 1.0)
	var spawn_distance := requested_distance * safe_fraction
	if safe_fraction < 1.0:
		spawn_distance = maxf(spawn_distance - maxf(config.collision_skin, 0.0), 0.0)

	var candidate := origin + launch_direction * spawn_distance
	if not _is_spawn_position_clear(space_state, candidate):
		var low := 0.0
		var high := spawn_distance
		for _attempt in range(8):
			var midpoint := (low + high) * 0.5
			if _is_spawn_position_clear(space_state, origin + launch_direction * midpoint):
				low = midpoint
			else:
				high = midpoint
		spawn_distance = low
		candidate = origin + launch_direction * spawn_distance

	if spawn_distance <= 0.01:
		return Vector2.INF
	return candidate

func _ensure_spawn_query(config: ProjectileConfig) -> void:
	if _spawn_shape == null:
		_spawn_shape = CircleShape2D.new()
	if _spawn_query == null:
		_spawn_query = PhysicsShapeQueryParameters2D.new()
		_spawn_query.shape = _spawn_shape
		_spawn_query.collide_with_bodies = true
		_spawn_query.collide_with_areas = false

	_spawn_shape.radius = config.collision_radius
	_spawn_query.collision_mask = config.collision_mask
	_spawn_query.margin = maxf(config.collision_safe_margin, 0.01)

func _is_spawn_position_clear(space_state: PhysicsDirectSpaceState2D, position: Vector2) -> bool:
	_spawn_query.transform = Transform2D(0.0, position)
	_spawn_query.motion = Vector2.ZERO
	return space_state.intersect_shape(_spawn_query, 1).is_empty()
