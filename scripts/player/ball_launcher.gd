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
	if not triggered or _aim_controller == null or _shot_origin == null:
		return false
	if projectile_scene == null or projectile_config == null or _projectile_parent == null:
		return false

	if _active_ball != null:
		if is_instance_valid(_active_ball):
			return false
		_active_ball = null

	var ball := projectile_scene.instantiate() as RicochetBall
	if ball == null:
		return false

	_projectile_parent.add_child(ball)
	_active_ball = ball
	ball.finished.connect(_on_ball_finished.bind(ball))

	var direction := _aim_controller.aim_direction
	ball.global_position = _shot_origin.global_position + direction * projectile_config.spawn_offset
	ball.launch(direction, projectile_config)
	return true

func reset() -> void:
	if _active_ball != null and is_instance_valid(_active_ball):
		_active_ball.cancel()
	_active_ball = null

func _on_ball_finished(_reason: String, ball: RicochetBall) -> void:
	if ball == _active_ball:
		_active_ball = null
