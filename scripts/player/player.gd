class_name Player
extends CharacterBody2D

signal health_changed(current_health: int, maximum_health: int)
signal died

@export var movement_config: MovementConfig

@onready var movement_controller: MovementController = $MovementController
@onready var aim_controller: AimController = $AimController
@onready var player_visual: PlayerVisual = $PlayerVisual
@onready var reticle_visual: ReticleVisual = $ReticleVisual
@onready var shot_origin: Node2D = $ShotOrigin
@onready var ball_launcher: BallLauncher = $BallLauncher
@onready var trajectory_preview: Node2D = $TrajectoryPreview
@onready var health: PlayerHealth = $Health
@onready var racket_controller: RacketController = $RacketController

var is_dead: bool:
	get:
		return health != null and health.is_dead
var current_health: int:
	get:
		return health.current_health if health != null else 0
var maximum_health: int:
	get:
		return health.maximum_health if health != null else 0

var aim_direction: Vector2:
	get:
		return aim_controller.aim_direction

var aim_target_position: Vector2:
	get:
		return aim_controller.aim_target_position

func _ready() -> void:
	add_to_group("player")
	if movement_config == null:
		movement_config = MovementConfig.new()
	movement_controller.configure(self, movement_config)
	health.health_changed.connect(_on_health_changed)
	health.died.connect(_on_died)
	_on_health_changed(health.current_health, health.maximum_health)
	aim_controller.aim_changed.connect(reticle_visual.set_aim)
	reticle_visual.set_aim(aim_controller.aim_direction, aim_controller.aim_target_position)
	racket_controller.set_aim_direction(aim_controller.aim_direction)
	ball_launcher.configure(self, aim_controller, shot_origin, _find_projectile_parent())
	trajectory_preview.call("configure", aim_controller, shot_origin, ball_launcher)

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		return

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

func _process(_delta: float) -> void:
	if is_dead:
		return
	player_visual.set_invulnerable(health.is_invulnerable)
	racket_controller.set_aim_direction(aim_controller.aim_direction)

func take_damage(amount: int, source: Node = null) -> bool:
	return health.take_damage(amount, source)

func reset_to_spawn(spawn_position: Vector2) -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
	movement_controller.reset()
	racket_controller.reset()
	ball_launcher.reset()
	if not is_dead:
		player_visual.set_dead(false)
		reticle_visual.show()
		trajectory_preview.show()
		trajectory_preview.set_physics_process(true)

func get_movement_status() -> Dictionary:
	return movement_controller.get_status()

func get_aim_target_position() -> Vector2:
	return aim_controller.aim_target_position

func _on_health_changed(current: int, maximum: int) -> void:
	health_changed.emit(current, maximum)

func _on_died() -> void:
	velocity = Vector2.ZERO
	movement_controller.reset()
	racket_controller.cancel()
	ball_launcher.reset()
	trajectory_preview.hide()
	trajectory_preview.set_physics_process(false)
	reticle_visual.hide()
	player_visual.set_dead(true)
	died.emit()

func _find_projectile_parent() -> Node:
	var player_parent := get_parent()
	if player_parent != null:
		var ball_container := player_parent.get_node_or_null("BallContainer")
		if ball_container != null:
			return ball_container
	return player_parent
