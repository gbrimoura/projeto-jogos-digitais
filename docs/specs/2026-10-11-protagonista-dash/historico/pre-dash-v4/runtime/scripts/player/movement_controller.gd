class_name MovementController
extends Node

## Componente de fisica do jogador. Ele recebe comandos simples e nao conhece
## mira, combate ou regras de build, mantendo essas extensoes desacopladas.

enum DashState { READY, ACTIVE, COOLDOWN }

var _body: CharacterBody2D
var _config: MovementConfig
var _coyote_timer: float = 0.0
var _jump_buffer_timer: float = 0.0
var _dash_timer: float = 0.0
var _dash_cooldown_timer: float = 0.0
var _dash_direction: Vector2 = Vector2.ZERO
var _facing_direction: int = 1
var _dash_state: int = DashState.READY
var _air_dashes_remaining: int = 0
var _dash_input_armed: bool = true

var is_dashing: bool:
	get:
		return _dash_state == DashState.ACTIVE

var can_dash: bool:
	get:
		if _body == null or _config == null or not _config.dash_enabled or _dash_state != DashState.READY:
			return false
		return _body.is_on_floor() or _air_dashes_remaining > 0

var facing_direction: int:
	get:
		return _facing_direction

var dash_cooldown_remaining: float:
	get:
		return _dash_cooldown_timer

func configure(body: CharacterBody2D, config: MovementConfig) -> void:
	_body = body
	_config = config
	_air_dashes_remaining = _config.max_air_dashes

func physics_step(
	input_axis: float,
	jump_pressed: bool,
	jump_released: bool,
	dash_pressed: bool,
	dash_released: bool,
	delta: float
) -> void:
	if _body == null or _config == null:
		return

	_update_timers(delta)
	_update_jump_windows(jump_pressed, delta)

	if dash_released:
		_dash_input_armed = true
	if dash_pressed and _dash_input_armed and can_dash:
		_start_dash(input_axis)
		_dash_input_armed = false
		# Dash e pulo no mesmo frame: o dash tem prioridade explicita.
		_jump_buffer_timer = 0.0

	if is_dashing:
		_process_dash(delta)
		return

	_apply_gravity(delta)
	_try_consume_jump()
	if jump_released:
		_apply_jump_cut()
	_apply_horizontal(input_axis, delta)
	_body.move_and_slide()

func reset() -> void:
	_coyote_timer = 0.0
	_jump_buffer_timer = 0.0
	_dash_timer = 0.0
	_dash_cooldown_timer = 0.0
	_dash_direction = Vector2.ZERO
	_dash_state = DashState.READY
	_dash_input_armed = true
	_facing_direction = 1
	_air_dashes_remaining = _config.max_air_dashes if _config != null else 0
	if _body != null:
		_body.velocity = Vector2.ZERO

func get_status() -> Dictionary:
	return {
		"is_dashing": is_dashing,
		"can_dash": can_dash,
		"dash_cooldown_remaining": dash_cooldown_remaining,
		"air_dashes_remaining": _air_dashes_remaining,
		"dash_state": _dash_state,
		"facing_direction": facing_direction,
	}

func _update_timers(delta: float) -> void:
	_dash_cooldown_timer = maxf(_dash_cooldown_timer - delta, 0.0)
	if _dash_state == DashState.COOLDOWN and _dash_cooldown_timer <= 0.0:
		_dash_state = DashState.READY

func _update_jump_windows(jump_pressed: bool, delta: float) -> void:
	if _body.is_on_floor():
		_coyote_timer = _config.coyote_time
		_air_dashes_remaining = _config.max_air_dashes
	else:
		_coyote_timer = maxf(_coyote_timer - delta, 0.0)

	if jump_pressed:
		_jump_buffer_timer = _config.jump_buffer_time
	else:
		_jump_buffer_timer = maxf(_jump_buffer_timer - delta, 0.0)

func _apply_horizontal(input_axis: float, delta: float) -> void:
	var axis := clampf(input_axis, -1.0, 1.0)
	if not is_zero_approx(axis):
		_facing_direction = 1 if axis > 0.0 else -1

	var target_speed := axis * _config.move_speed
	var change_rate := _config.acceleration if not is_zero_approx(axis) else _config.deceleration
	_body.velocity.x = move_toward(_body.velocity.x, target_speed, change_rate * delta)

func _apply_gravity(delta: float) -> void:
	if not _body.is_on_floor():
		_body.velocity.y = minf(_body.velocity.y + _config.gravity * delta, _config.max_fall_speed)
	elif _body.velocity.y > 0.0:
		_body.velocity.y = 0.0

func _apply_jump_cut() -> void:
	if _body.velocity.y < 0.0:
		_body.velocity.y *= _config.jump_cut_multiplier

func _try_consume_jump() -> void:
	if _jump_buffer_timer <= 0.0 or _coyote_timer <= 0.0:
		return

	_body.velocity.y = -_config.jump_velocity
	_jump_buffer_timer = 0.0
	_coyote_timer = 0.0

func _start_dash(input_axis: float) -> void:
	var direction := float(_facing_direction)
	if input_axis > 0.0:
		direction = 1.0
	elif input_axis < 0.0:
		direction = -1.0
	if not _body.is_on_floor():
		_air_dashes_remaining = maxi(_air_dashes_remaining - 1, 0)

	_dash_direction = Vector2(direction, 0.0)
	_facing_direction = int(direction)
	_dash_timer = _config.dash_duration
	_dash_cooldown_timer = 0.0
	_dash_state = DashState.ACTIVE

func _process_dash(delta: float) -> void:
	_body.velocity = _dash_direction * _config.dash_speed
	_body.move_and_slide()

	if _has_horizontal_blocking_collision():
		_dash_timer = 0.0
	else:
		_dash_timer = maxf(_dash_timer - delta, 0.0)

	if _dash_timer <= 0.0:
		_finish_dash()

func _has_horizontal_blocking_collision() -> bool:
	for index in range(_body.get_slide_collision_count()):
		var collision := _body.get_slide_collision(index)
		if collision.get_normal().dot(_dash_direction) < -0.5:
			return true
	return false

func _finish_dash() -> void:
	_dash_timer = 0.0
	_dash_direction = Vector2.ZERO
	_body.velocity.x = 0.0
	_dash_cooldown_timer = _config.dash_cooldown
	_dash_state = DashState.COOLDOWN if _dash_cooldown_timer > 0.0 else DashState.READY
