class_name Player
extends CharacterBody2D

const MOTOR_ACELERADO_DEFINITION: UpgradeDefinitionResource = preload("res://resources/upgrades/motor_acelerado.tres")

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
@onready var racket_visual: RacketVisual = $PlayerVisual/RacketVisual

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

var _base_movement_config: MovementConfig
var _death_presentation_applied: bool = false

func _ready() -> void:
	add_to_group("player")
	if movement_config == null:
		movement_config = MovementConfig.new()
	_base_movement_config = movement_config.duplicate(true) as MovementConfig
	movement_controller.configure(self, _base_movement_config.duplicate(true) as MovementConfig)
	movement_controller.reset()
	health.health_changed.connect(_on_health_changed)
	health.damage_accepted.connect(_on_damage_accepted)
	health.died.connect(_on_died)
	_on_health_changed(health.current_health, health.maximum_health)
	aim_controller.aim_changed.connect(reticle_visual.set_aim)
	reticle_visual.set_aim(aim_controller.aim_direction, aim_controller.aim_target_position)
	racket_controller.set_aim_direction(aim_controller.aim_direction)
	ball_launcher.configure(self, aim_controller, shot_origin, _find_projectile_parent())
	ball_launcher.launch_accepted.connect(racket_visual.start_shot)
	racket_controller.swing_started.connect(racket_visual.start_parry)
	racket_controller.swing_cancelled.connect(racket_visual.clear_transient)
	trajectory_preview.call("configure", aim_controller, shot_origin, ball_launcher)

func apply_run_build(build: RunBuild) -> void:
	if _base_movement_config == null:
		return
	var derived_config := _base_movement_config.duplicate(true) as MovementConfig
	if build != null and build.has_upgrade(MOTOR_ACELERADO_DEFINITION.upgrade_id):
		derived_config.dash_cooldown = MOTOR_ACELERADO_DEFINITION.dash_cooldown_override
	movement_controller.configure(self, derived_config)
	movement_controller.reset()
	ball_launcher.apply_run_build(build)

func _physics_process(delta: float) -> void:
	if is_dead:
		velocity = Vector2.ZERO
		return

	var move_axis := Input.get_axis("move_left", "move_right")
	var jump_blocked := is_discrete_input_blocked(&"jump")
	var dash_blocked := is_discrete_input_blocked(&"dash")
	var launch_blocked := is_discrete_input_blocked(&"launch_ball")
	var jump_pressed := not jump_blocked and Input.is_action_just_pressed("jump")
	var jump_released := not jump_blocked and Input.is_action_just_released("jump")
	var dash_pressed := not dash_blocked and Input.is_action_just_pressed("dash")
	var dash_released := not dash_blocked and Input.is_action_just_released("dash")
	var launch_pressed := not launch_blocked and Input.is_action_just_pressed("launch_ball")

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
	player_visual.set_grounded(is_on_floor(), velocity.y)
	var is_walking := is_on_floor() \
		and not movement_controller.is_dashing \
		and absf(velocity.x) > 8.0
	player_visual.set_walking(is_walking, absf(velocity.x))
	ball_launcher.try_launch(launch_pressed)

func _process(_delta: float) -> void:
	if is_dead:
		return
	player_visual.set_invulnerable(health.is_invulnerable)
	racket_controller.set_aim_direction(aim_controller.aim_direction)

func take_damage(amount: int, source: Node = null) -> bool:
	return health.take_damage(amount, source)

func is_discrete_input_blocked(action: StringName) -> bool:
	var room_root := get_parent()
	return room_root != null \
		and room_root.has_method("is_gameplay_action_blocked") \
		and bool(room_root.call("is_gameplay_action_blocked", action))

func reset_to_spawn(spawn_position: Vector2) -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
	movement_controller.reset()
	player_visual.reset_air_state()
	player_visual.set_facing_direction(movement_controller.facing_direction)
	player_visual.set_dashing(false)
	player_visual.set_walking(false)
	racket_controller.reset()
	racket_visual.clear_transient()
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

func _on_damage_accepted(_amount: int, _current: int, _maximum: int) -> void:
	if health.is_dead:
		return
	player_visual.play_hurt()

func _on_died() -> void:
	# take_damage may be called from a projectile sweep; only request a stop here.
	racket_visual.clear_transient()
	ball_launcher.request_stop_active_sweep()
	died.emit()

func finish_death_after_physics() -> void:
	if _death_presentation_applied:
		return
	_death_presentation_applied = true
	velocity = Vector2.ZERO
	movement_controller.reset()
	racket_controller.cancel()
	trajectory_preview.hide()
	trajectory_preview.set_physics_process(false)
	reticle_visual.hide()
	player_visual.set_dead(true)

func _find_projectile_parent() -> Node:
	var player_parent := get_parent()
	if player_parent != null:
		var ball_container := player_parent.get_node_or_null("BallContainer")
		if ball_container != null:
			return ball_container
	return player_parent
