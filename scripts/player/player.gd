class_name Player
extends CharacterBody2D
signal health_changed(current_health: int, max_health: int)
signal died

@export_range(1, 20, 1)
var max_health: int = 5

var health: int = 0

@export var movement_config: MovementConfig

@onready var movement_controller: MovementController = $MovementController
@onready var aim_controller: AimController = $AimController
@onready var player_visual: PlayerVisual = $PlayerVisual
@onready var reticle_visual: ReticleVisual = $ReticleVisual
@onready var shot_origin: Node2D = $ShotOrigin
@onready var ball_launcher: BallLauncher = $BallLauncher
@onready var trajectory_preview: Node2D = $TrajectoryPreview

var aim_direction: Vector2:
	get:
		return aim_controller.aim_direction

var aim_target_position: Vector2:
	get:
		return aim_controller.aim_target_position

func _ready() -> void:
	health = maxi(max_health, 1)
	add_to_group("player")
	if movement_config == null:
		movement_config = MovementConfig.new()
	movement_controller.configure(self, movement_config)
	aim_controller.aim_changed.connect(reticle_visual.set_aim)
	reticle_visual.set_aim(aim_controller.aim_direction, aim_controller.aim_target_position)
	ball_launcher.configure(self, aim_controller, shot_origin, _find_projectile_parent())
	trajectory_preview.call("configure", aim_controller, shot_origin, ball_launcher)

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

func take_damage(amount: int) -> void:
	if amount <= 0 or health <= 0:
		return

	health = maxi(health - amount, 0)
	health_changed.emit(health, maxi(max_health, 1))
	queue_redraw()

	if health == 0:
		died.emit()
func restore_health(value: int) -> void:
	var safe_max := maxi(max_health, 1)
	health = clampi(value, 0, safe_max)
	health_changed.emit(health, safe_max)
	queue_redraw()

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

func _draw() -> void:
	var ratio := clampf(float(health) / float(maxi(max_health, 1)), 0.0, 1.0)
	var bar_rect := Rect2(Vector2(-24, -44), Vector2(48, 6))

	draw_rect(bar_rect, Color("#202733"))

	var health_color := Color("#56d27a")
	if health <= 2:
		health_color = Color("#e86b69")

	draw_rect(
		Rect2(bar_rect.position, Vector2(bar_rect.size.x * ratio, bar_rect.size.y)),
		health_color
	)
	draw_string(
		ThemeDB.fallback_font,
		Vector2(-40, -49),
		"ENERGIA %d/%d" % [health, max_health],
		HORIZONTAL_ALIGNMENT_CENTER,
		80,
		12,
		Color("#f3eadb")
	)
