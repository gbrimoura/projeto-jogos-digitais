class_name PlayerVisual
extends Node2D

const IDLE_ANIMATION: StringName = &"idle"
const WALK_ANIMATION: StringName = &"walk"
const DASH_ANIMATION: StringName = &"dash"
const JUMP_RISE_ANIMATION: StringName = &"jump_rise"
const JUMP_APEX_ANIMATION: StringName = &"jump_apex"
const JUMP_FALL_ANIMATION: StringName = &"jump_fall"
const JUMP_LAND_ANIMATION: StringName = &"jump_land"
const HURT_ANIMATION: StringName = &"hurt"
const PARRY_BODY_ANIMATION: StringName = &"parry_body"
const JUMP_APEX_SPEED_LIMIT: float = 80.0
const WALK_REFERENCE_SPEED: float = 260.0
const WALK_SPEED_SCALE_MIN: float = 0.65
const WALK_SPEED_SCALE_MAX: float = 1.35
const PARRY_FRAME_DURATIONS: Array[float] = [0.030, 0.035, 0.025, 0.025, 0.040, 0.045]
const PARRY_TOTAL_DURATION: float = 0.200

@onready var dash_trail: Line2D = $DashTrail
@onready var character_sprite: AnimatedSprite2D = $AnimatedSprite2D

var _facing_direction: int = 1
var _is_walking: bool = false
var _is_dashing: bool = false
var _is_grounded: bool = true
var _vertical_speed: float = 0.0
var _has_ground_contact: bool = false
var _airborne_seen: bool = false
var _is_landing: bool = false
var _is_invulnerable: bool = false
var _is_hurt: bool = false
var _is_dead: bool = false
var _is_parrying: bool = false
var _parry_progress: float = 0.0
var _parry_facing: int = 1
var _dash_phase: float = 0.0
var _walk_speed_magnitude: float = 0.0

func _ready() -> void:
	character_sprite.animation_changed.connect(_apply_facing)
	character_sprite.animation_finished.connect(_on_character_animation_finished)
	_apply_facing()
	character_sprite.play(IDLE_ANIMATION)

func _process(delta: float) -> void:
	if _is_dead:
		return
	if _is_invulnerable:
		var damage_pulse := 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.035)
		if _is_hurt:
			modulate = Color(1.0, 0.88 + damage_pulse * 0.1, 0.84 + damage_pulse * 0.1, 1.0)
		else:
			modulate = Color(1.0, 0.56 + damage_pulse * 0.34, 0.5 + damage_pulse * 0.42, 0.45 + damage_pulse * 0.35)
	else:
		modulate = Color.WHITE
	if not _is_dashing:
		return

	_dash_phase = fmod(_dash_phase + delta * 16.0, TAU)
	_update_dash_trail_scale()

func set_facing_direction(direction: int) -> void:
	if direction == 0 or direction == _facing_direction:
		return
	_facing_direction = 1 if direction > 0 else -1
	_apply_facing()

func set_walking(value: bool, horizontal_speed: float = 0.0) -> void:
	_walk_speed_magnitude = absf(horizontal_speed)
	if value == _is_walking:
		_set_walk_speed_scale()
		return
	_is_walking = value
	_set_walk_speed_scale()
	_apply_animation_state()

func _set_walk_speed_scale() -> void:
	if _is_walking and _is_grounded and not _is_landing and not _is_dashing and not _is_hurt and not _is_dead and not _is_parrying:
		character_sprite.speed_scale = clampf(
			_walk_speed_magnitude / WALK_REFERENCE_SPEED,
			WALK_SPEED_SCALE_MIN,
			WALK_SPEED_SCALE_MAX
		)
	else:
		character_sprite.speed_scale = 1.0

func set_grounded(value: bool, vertical_speed: float = 0.0) -> void:
	_vertical_speed = vertical_speed
	if not value:
		if _has_ground_contact:
			_airborne_seen = true
		_is_grounded = false
		_is_landing = false
		_apply_animation_state()
		return

	var landed_after_airborne := not _is_grounded and _airborne_seen
	_is_grounded = true
	_has_ground_contact = true
	_airborne_seen = false
	if landed_after_airborne and not _is_dashing and not _is_dead and not _is_hurt:
		_is_landing = true
		character_sprite.speed_scale = 1.0
		character_sprite.play(JUMP_LAND_ANIMATION)
		return

	_apply_animation_state()

func reset_air_state() -> void:
	_is_grounded = true
	_vertical_speed = 0.0
	_has_ground_contact = false
	_airborne_seen = false
	_is_landing = false
	_apply_animation_state()

func set_dashing(value: bool) -> void:
	if value == _is_dashing:
		return
	if value and _is_dead:
		return
	_is_dashing = value
	dash_trail.visible = _is_dashing
	if _is_dashing:
		_is_landing = false
		_dash_phase = 0.0
		_restart_dash_animation()
	else:
		_dash_phase = 0.0
		_apply_animation_state()
	_update_dash_trail_scale()

func set_invulnerable(value: bool) -> void:
	_is_invulnerable = value

func set_parry_state(active: bool, progress: float, frozen_direction: Vector2) -> void:
	if active:
		if not _is_parrying:
			_parry_facing = (1 if frozen_direction.x > 0.0 else -1) if not is_zero_approx(frozen_direction.x) else _facing_direction
			_is_parrying = true
			_apply_facing()
		_parry_progress = clampf(progress, 0.0, 1.0)
		_apply_animation_state()
		return
	if not _is_parrying:
		return
	_is_parrying = false
	_parry_progress = 0.0
	_apply_facing()
	_apply_animation_state()

func play_hurt() -> void:
	if _is_dead:
		return
	_is_hurt = true
	_is_landing = false
	character_sprite.speed_scale = 1.0
	character_sprite.stop()
	character_sprite.animation = HURT_ANIMATION
	character_sprite.frame = 0
	character_sprite.frame_progress = 0.0
	character_sprite.play(HURT_ANIMATION)

func set_dead(value: bool) -> void:
	if value:
		if _is_dead:
			return
		_is_dead = true
		_is_invulnerable = false
		_is_hurt = false
		_is_parrying = false
		_parry_progress = 0.0
		_is_walking = false
		_is_landing = false
		_airborne_seen = false
		_has_ground_contact = false
		set_dashing(false)
		character_sprite.speed_scale = 1.0
		character_sprite.stop()
		modulate = Color("#6f747a")
		return

	_is_dead = false
	_is_invulnerable = false
	_is_hurt = false
	_is_parrying = false
	_parry_progress = 0.0
	_is_walking = false
	_is_grounded = true
	_vertical_speed = 0.0
	_has_ground_contact = false
	_airborne_seen = false
	_is_landing = false
	set_dashing(false)
	dash_trail.visible = false
	_dash_phase = 0.0
	_apply_facing()
	character_sprite.speed_scale = 1.0
	character_sprite.stop()
	character_sprite.animation = IDLE_ANIMATION
	character_sprite.frame = 0
	character_sprite.frame_progress = 0.0
	_apply_animation_state()
	modulate = Color.WHITE

func _apply_animation_state() -> void:
	if _is_dead:
		character_sprite.speed_scale = 1.0
		character_sprite.stop()
		return

	if _is_hurt:
		character_sprite.speed_scale = 1.0
		if character_sprite.animation != HURT_ANIMATION:
			character_sprite.play(HURT_ANIMATION)
		return

	if _is_dashing:
		character_sprite.speed_scale = 1.0
		if character_sprite.animation != DASH_ANIMATION:
			character_sprite.play(DASH_ANIMATION)
		return

	if not _is_grounded:
		character_sprite.speed_scale = 1.0
		var target_animation := JUMP_APEX_ANIMATION
		if _vertical_speed < -JUMP_APEX_SPEED_LIMIT:
			target_animation = JUMP_RISE_ANIMATION
		elif _vertical_speed > JUMP_APEX_SPEED_LIMIT:
			target_animation = JUMP_FALL_ANIMATION
		if character_sprite.animation != target_animation:
			character_sprite.play(target_animation)
		return

	if _is_landing:
		character_sprite.speed_scale = 1.0
		if character_sprite.animation != JUMP_LAND_ANIMATION or not character_sprite.is_playing():
			character_sprite.play(JUMP_LAND_ANIMATION)
		return

	if _is_parrying:
		character_sprite.speed_scale = 1.0
		if character_sprite.animation != PARRY_BODY_ANIMATION:
			character_sprite.stop()
			character_sprite.animation = PARRY_BODY_ANIMATION
		elif character_sprite.is_playing():
			character_sprite.stop()
		_sync_parry_frame()
		return

	var target_animation := WALK_ANIMATION if _is_walking else IDLE_ANIMATION
	_set_walk_speed_scale()
	if character_sprite.animation != target_animation or not character_sprite.is_playing():
		character_sprite.play(target_animation)

func _restart_dash_animation() -> void:
	character_sprite.speed_scale = 1.0
	if _is_hurt:
		return
	character_sprite.stop()
	character_sprite.animation = DASH_ANIMATION
	character_sprite.frame = 0
	character_sprite.frame_progress = 0.0
	character_sprite.play(DASH_ANIMATION)

func _on_character_animation_finished() -> void:
	if _is_hurt and character_sprite.animation == HURT_ANIMATION:
		_is_hurt = false
		_apply_animation_state()
		return
	if not _is_landing or not _is_grounded or character_sprite.animation != JUMP_LAND_ANIMATION:
		return
	_is_landing = false
	_apply_animation_state()

func _apply_facing() -> void:
	var native_direction := -1
	if character_sprite.animation == DASH_ANIMATION or character_sprite.animation == PARRY_BODY_ANIMATION:
		native_direction = 1
	var facing_direction := _parry_facing if _is_parrying and character_sprite.animation == PARRY_BODY_ANIMATION else _facing_direction
	character_sprite.flip_h = facing_direction != native_direction
	_update_dash_trail_scale()

func _sync_parry_frame() -> void:
	var elapsed := minf(_parry_progress * PARRY_TOTAL_DURATION, PARRY_TOTAL_DURATION - 0.000001)
	for frame_index in range(PARRY_FRAME_DURATIONS.size()):
		var frame_duration := PARRY_FRAME_DURATIONS[frame_index]
		if elapsed < frame_duration or frame_index == PARRY_FRAME_DURATIONS.size() - 1:
			character_sprite.set_frame_and_progress(
				frame_index,
				clampf(elapsed / frame_duration, 0.0, 1.0)
			)
			return
		elapsed -= frame_duration

func _update_dash_trail_scale() -> void:
	var pulse_scale := 1.0
	if _is_dashing:
		var dash_pulse := 0.5 + 0.5 * sin(_dash_phase)
		pulse_scale += dash_pulse * 0.2
	dash_trail.scale.x = float(_facing_direction) * pulse_scale
