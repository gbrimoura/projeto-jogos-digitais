class_name PlayerVisual
extends Node2D

const IDLE_ANIMATION: StringName = &"idle"
const WALK_ANIMATION: StringName = &"walk"
const DASH_ANIMATION: StringName = &"dash"
const WALK_REFERENCE_SPEED: float = 260.0
const WALK_SPEED_SCALE_MIN: float = 0.65
const WALK_SPEED_SCALE_MAX: float = 1.35

@onready var dash_trail: Line2D = $DashTrail
@onready var character_sprite: AnimatedSprite2D = $AnimatedSprite2D

var _facing_direction: int = 1
var _is_walking: bool = false
var _is_dashing: bool = false
var _is_grounded: bool = true
var _is_invulnerable: bool = false
var _is_dead: bool = false
var _dash_phase: float = 0.0
var _walk_speed_magnitude: float = 0.0

func _ready() -> void:
	character_sprite.animation_changed.connect(_apply_facing)
	_apply_facing()
	character_sprite.play(IDLE_ANIMATION)

func _process(delta: float) -> void:
	if _is_dead:
		return
	if _is_invulnerable:
		var damage_pulse := 0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.035)
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
	if _is_walking and _is_grounded and not _is_dashing and not _is_dead:
		character_sprite.speed_scale = clampf(
			_walk_speed_magnitude / WALK_REFERENCE_SPEED,
			WALK_SPEED_SCALE_MIN,
			WALK_SPEED_SCALE_MAX
		)
	else:
		character_sprite.speed_scale = 1.0

func set_grounded(value: bool) -> void:
	if value == _is_grounded:
		return
	_is_grounded = value
	_apply_animation_state()

func set_dashing(value: bool) -> void:
	if value == _is_dashing:
		return
	if value and _is_dead:
		return
	_is_dashing = value
	dash_trail.visible = _is_dashing
	if _is_dashing:
		_dash_phase = 0.0
		_restart_dash_animation()
	else:
		_dash_phase = 0.0
		_apply_animation_state()
	_update_dash_trail_scale()

func set_invulnerable(value: bool) -> void:
	_is_invulnerable = value

func set_dead(value: bool) -> void:
	if value:
		if _is_dead:
			return
		_is_dead = true
		_is_invulnerable = false
		_is_walking = false
		set_dashing(false)
		character_sprite.speed_scale = 1.0
		character_sprite.stop()
		modulate = Color("#6f747a")
		return

	_is_dead = false
	_is_invulnerable = false
	_is_walking = false
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

	if _is_dashing:
		character_sprite.speed_scale = 1.0
		if character_sprite.animation != DASH_ANIMATION:
			character_sprite.play(DASH_ANIMATION)
		return

	if not _is_grounded:
		character_sprite.speed_scale = 1.0
		_set_static_idle_pose()
		return

	var target_animation := WALK_ANIMATION if _is_walking else IDLE_ANIMATION
	_set_walk_speed_scale()
	if character_sprite.animation != target_animation or not character_sprite.is_playing():
		character_sprite.play(target_animation)

func _restart_dash_animation() -> void:
	character_sprite.speed_scale = 1.0
	character_sprite.stop()
	character_sprite.animation = DASH_ANIMATION
	character_sprite.frame = 0
	character_sprite.frame_progress = 0.0
	character_sprite.play(DASH_ANIMATION)

func _set_static_idle_pose() -> void:
	if character_sprite.animation == IDLE_ANIMATION \
			and not character_sprite.is_playing() \
			and character_sprite.frame == 0 \
			and is_zero_approx(character_sprite.frame_progress):
		return
	character_sprite.stop()
	character_sprite.animation = IDLE_ANIMATION
	character_sprite.frame = 0
	character_sprite.frame_progress = 0.0

func _apply_facing() -> void:
	var native_direction := 1 if character_sprite.animation == DASH_ANIMATION else -1
	character_sprite.flip_h = _facing_direction != native_direction
	_update_dash_trail_scale()

func _update_dash_trail_scale() -> void:
	var pulse_scale := 1.0
	if _is_dashing:
		var dash_pulse := 0.5 + 0.5 * sin(_dash_phase)
		pulse_scale += dash_pulse * 0.2
	dash_trail.scale.x = float(_facing_direction) * pulse_scale
