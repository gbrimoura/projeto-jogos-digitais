class_name Player
extends CharacterBody2D

@export var movement_config: MovementConfig

@onready var movement_controller: MovementController = $MovementController
@onready var aim_controller: AimController = $AimController
@onready var player_visual: PlayerVisual = $PlayerVisual
@onready var reticle_visual: ReticleVisual = $ReticleVisual
@onready var shot_origin: Node2D = $ShotOrigin
@onready var ball_launcher: BallLauncher = $BallLauncher

var aim_direction: Vector2:
	get:
		return aim_controller.aim_direction

var aim_target_position: Vector2:
	get:
		return aim_controller.aim_target_position

func _ready() -> void:
	if movement_config == null:
		movement_config = MovementConfig.new()
	movement_controller.configure(self, movement_config)
	aim_controller.aim_changed.connect(reticle_visual.set_aim)
	reticle_visual.set_aim(aim_controller.aim_direction, aim_controller.aim_target_position)
	ball_launcher.configure(self, aim_controller, shot_origin, _find_projectile_parent())

func _physics_process(delta: float) -> void:
	var move_axis := Input.get_axis("move_left", "move_right")
	var jump_pressed := Input.is_action_just_pressed("jump")
	var jump_released := Input.is_action_just_released("jump")
	var dash_pressed := Input.is_action_just_pressed("dash")
	var dash_released := Input.is_action_just_released("dash")
	var launch_pressed := Input.is_action_just_pressed("launch_ball")

	movement_controller.physics_step(
		move_axis,
		jump_pressed,
		jump_released,
		dash_pressed,
		dash_released,
		delta
	)
	player_visual.set_facing_direction(movement_controller.facing_direction)
	player_visual.set_dashing(movement_controller.is_dashing)
	ball_launcher.try_launch(launch_pressed)

func reset_to_spawn(spawn_position: Vector2) -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
	movement_controller.reset()
	ball_launcher.reset()

func get_movement_status() -> Dictionary:
	return movement_controller.get_status()

func get_aim_target_position() -> Vector2:
	return aim_controller.aim_target_position

func _find_projectile_parent() -> Node:
	var player_parent := get_parent()
	if player_parent != null:
		var ball_container := player_parent.get_node_or_null("BallContainer")
		if ball_container != null:
			return ball_container
	return player_parent
