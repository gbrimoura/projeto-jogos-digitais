class_name RacketVisual
extends Node2D

const ARM_MASK_SHADER: Shader = preload("res://scripts/player/racket_arm_mask.gdshader")
const OUTLINE: Color = Color("#001123")
const ARM_BLUE: Color = Color("#2E65B0")
const ARM_LIGHT: Color = Color("#3069B5")
const IVORY: Color = Color("#F5E9D8")
const GOLD: Color = Color("#FCC203")
const JOINT: Color = Color("#373F4D")
const GRIP: Color = Color("#897C76")
const GRIP_LIGHT: Color = Color("#CFC3B7")

const POSE_DURATION: Array[float] = [0.045, 0.030, 0.025, 0.035, 0.035, 0.030]
const PARRY_KEY_TIME: Array[float] = [0.0, 0.18, 0.32, 0.44, 0.5, 0.58, 0.82, 1.0]
const PARRY_GRIP_OFFSET: Array[Vector2] = [
	Vector2(24.0, 0.0), Vector2(10.0, -5.0), Vector2(17.0, -11.0),
	Vector2(24.0, -7.0), Vector2(25.0, 2.0), Vector2(23.0, 12.0),
	Vector2(24.5, 1.0), Vector2(24.0, 0.0)
]
const PARRY_HEAD_ANGLE: Array[float] = [
	0.0, -1.3962634, -1.04719755, -0.43633231,
	0.0, 1.04719755, 0.13962634, 0.0
]
const SHOT_HEAD_ANGLE: Array[float] = [
	-1.04719755, -0.61086524, 0.0,
	0.54105207, 0.76794487, 0.61086524
]
const SHOT_POSES: Array[int] = [2, 3, 4, 5]
const SHOT_CLEARANCE: float = 21.0
const UPPER_ARM_LENGTH: float = 14.0
const FOREARM_LENGTH: float = 12.0
const MIN_ARM_REACH: float = 2.001
const MAX_ARM_REACH: float = 26.0
const ARM_SIDE_EPSILON: float = 0.0001
const SHOULDER: Vector2 = Vector2(14.0, -44.0)

# Native 64x64 frame anchors for the hand already drawn in non-grounded poses.
# They are deliberately per-frame and only locate the separate racket grip.
const HAND_ANCHORS: Dictionary = {
	&"idle": [Vector2(41, 45), Vector2(41, 45), Vector2(41, 45), Vector2(41, 45), Vector2(41, 45), Vector2(41, 45)],
	&"walk": [Vector2(40, 45), Vector2(41, 44), Vector2(42, 44), Vector2(43, 44), Vector2(43, 45), Vector2(42, 45), Vector2(41, 45), Vector2(40, 45)],
	&"dash": [Vector2(47, 39), Vector2(49, 38), Vector2(48, 39)],
	&"jump_rise": [Vector2(42, 42), Vector2(43, 40), Vector2(44, 38)],
	&"jump_apex": [Vector2(45, 37)],
	&"jump_fall": [Vector2(45, 40)],
	&"jump_land": [Vector2(43, 44), Vector2(42, 45), Vector2(41, 45)],
	&"hurt": [Vector2(40, 43), Vector2(41, 44), Vector2(42, 45)]
}

@onready var _body_sprite: AnimatedSprite2D = get_parent().get_node("AnimatedSprite2D") as AnimatedSprite2D
@onready var _head: Sprite2D = $RacketHead
@onready var _racket_controller: RacketController = get_parent().get_parent().get_node_or_null("RacketController") as RacketController

var _mask_material: ShaderMaterial
var _attack_kind: StringName = &""
var _attack_direction: Vector2 = Vector2.RIGHT
var _aim_world_direction: Vector2 = Vector2.RIGHT
var _attack_world_direction: Vector2 = Vector2.RIGHT
var _shot_contact_offset: Vector2 = Vector2.ZERO
var _attack_elapsed: float = 0.0
var _parry_duration: float = 0.20
var _pose_index: int = 0
var _grip: Vector2 = Vector2.ZERO
var _elbow: Vector2 = Vector2.ZERO
var _head_center: Vector2 = Vector2.ZERO
var _head_direction: Vector2 = Vector2.RIGHT
var _ground_rig_active: bool = false

func _ready() -> void:
	_mask_material = ShaderMaterial.new()
	_mask_material.shader = ARM_MASK_SHADER
	_body_sprite.material = _mask_material
	set_process(true)

func set_aim_direction(world_direction: Vector2) -> void:
	if world_direction.is_zero_approx() or _attack_kind != &"":
		return
	_aim_world_direction = world_direction.normalized()
	queue_redraw()

func start_parry(world_direction: Vector2, duration: float) -> void:
	if world_direction.is_zero_approx():
		return
	_attack_kind = &"parry"
	_attack_world_direction = world_direction.normalized()
	_attack_elapsed = 0.0
	_parry_duration = maxf(duration, 0.01)
	_pose_index = 0
	queue_redraw()

func start_shot(spawn_position: Vector2, world_direction: Vector2) -> void:
	if world_direction.is_zero_approx():
		return
	_attack_kind = &"shot"
	_attack_world_direction = world_direction.normalized()
	_shot_contact_offset = spawn_position - global_position - _attack_world_direction * SHOT_CLEARANCE
	_attack_elapsed = 0.0
	_pose_index = 2
	queue_redraw()

func clear_transient() -> void:
	_attack_kind = &""
	_attack_elapsed = 0.0
	_pose_index = 0
	queue_redraw()

func _process(delta: float) -> void:
	var player := get_parent().get_parent() as Player
	if player == null or player.is_dead:
		visible = false
		_set_arm_mask(false)
		return
	visible = true
	scale.x = -1.0 if _body_sprite.flip_h else 1.0
	var world_direction := _attack_world_direction if _attack_kind != &"" else _aim_world_direction
	_attack_direction = _world_direction_to_local(world_direction)
	_advance_attack(delta)
	_ground_rig_active = _body_sprite.animation == &"idle" or _body_sprite.animation == &"walk"
	_set_arm_mask(_ground_rig_active)
	_update_pose()
	queue_redraw()

func _advance_attack(delta: float) -> void:
	if _attack_kind == &"":
		return
	if _attack_kind == &"parry":
		if _racket_controller == null or not _racket_controller.is_swing_active():
			clear_transient()
			return
		_attack_elapsed = _parry_duration * _racket_controller.get_swing_progress()
		return
	_attack_elapsed += delta
	var shot_elapsed := _attack_elapsed
	for index in SHOT_POSES:
		if shot_elapsed < POSE_DURATION[index]:
			_pose_index = index
			return
		shot_elapsed -= POSE_DURATION[index]
	clear_transient()

func _update_pose() -> void:
	var direction := _attack_direction.normalized()
	var shoulder := SHOULDER
	var head_angle_offset := 0.0
	if _attack_kind == &"parry":
		var parry_progress := clampf(_attack_elapsed / _parry_duration, 0.0, 1.0)
		var parry_segment := 0
		while parry_segment < PARRY_KEY_TIME.size() - 2 \
			and parry_progress >= PARRY_KEY_TIME[parry_segment + 1]:
			parry_segment += 1
		var segment_start := PARRY_KEY_TIME[parry_segment]
		var segment_end := PARRY_KEY_TIME[parry_segment + 1]
		var segment_progress := (parry_progress - segment_start) / (segment_end - segment_start)
		var eased_progress := _ease_parry_segment(parry_segment, segment_progress)
		var grip_offset := PARRY_GRIP_OFFSET[parry_segment].lerp(
			PARRY_GRIP_OFFSET[parry_segment + 1], eased_progress
		)
		head_angle_offset = lerpf(
			PARRY_HEAD_ANGLE[parry_segment], PARRY_HEAD_ANGLE[parry_segment + 1], eased_progress
		)
		if _ground_rig_active:
			var side := direction.rotated(PI * 0.5)
			var target_grip := shoulder + direction * grip_offset.x + side * grip_offset.y
			_grip = _clamp_grip(target_grip, shoulder, direction)
			_elbow = _solve_elbow(shoulder, _grip, direction)
		else:
			_grip = _native_hand_anchor()
			_elbow = _grip
	elif _attack_kind == &"shot":
		head_angle_offset = SHOT_HEAD_ANGLE[_pose_index]
		if _ground_rig_active:
			var shot_racket_direction := direction.rotated(head_angle_offset)
			var contact := to_local(global_position + _shot_contact_offset)
			_grip = _clamp_grip(contact - shot_racket_direction * 18.0, shoulder, direction)
			_elbow = _solve_elbow(shoulder, _grip, direction)
		else:
			_grip = _native_hand_anchor()
			_elbow = _grip
	else:
		if _ground_rig_active:
			_grip = shoulder + direction * 24.0
			_elbow = _solve_elbow(shoulder, _grip, direction)
		else:
			_grip = _native_hand_anchor()
			_elbow = _grip
	var racket_direction := direction.rotated(head_angle_offset)
	_head_center = _grip + racket_direction * 18.0
	_head_direction = racket_direction
	_head.position = _head_center
	_head.rotation = _head_direction.angle()
	_head.visible = true

func _ease_parry_segment(segment: int, progress: float) -> float:
	var t := clampf(progress, 0.0, 1.0)
	match segment:
		0:
			return t * t * t
		1:
			return 1.0 - pow(1.0 - t, 3.0)
		2, 3:
			return t * t
		4, 6:
			return 1.0 - pow(1.0 - t, 3.0)
		_:
			return t * t * (3.0 - 2.0 * t)

func _draw() -> void:
	if not visible:
		return
	var direction := _head_direction.normalized()
	var head_neck := _head_center - direction * 8.0
	draw_line(_grip - direction * 5.0, head_neck, OUTLINE, 6.0, false)
	draw_line(_grip - direction * 4.0, head_neck, GRIP, 2.0, false)
	draw_line(_grip + direction.rotated(PI * 0.5), _grip + direction.rotated(-PI * 0.5), GRIP_LIGHT, 2.0, false)
	if not _ground_rig_active:
		return
	draw_line(SHOULDER, _elbow, OUTLINE, 6.0, false)
	draw_line(SHOULDER, _elbow, ARM_BLUE, 2.0, false)
	draw_line(_elbow, _grip, OUTLINE, 6.0, false)
	draw_line(_elbow, _grip, ARM_BLUE, 2.0, false)
	draw_rect(Rect2(_elbow - Vector2(3.0, 3.0), Vector2(6.0, 6.0)), JOINT)
	draw_rect(Rect2(_elbow - Vector2(1.0, 1.0), Vector2(2.0, 2.0)), ARM_LIGHT)
	var upper_midpoint := (SHOULDER + _elbow) * 0.5 + (_elbow - SHOULDER).orthogonal().normalized() * 2.0
	draw_rect(Rect2(upper_midpoint, Vector2(2.0, 2.0)), ARM_LIGHT)
	draw_set_transform(_grip, direction.angle(), Vector2.ONE)
	draw_rect(Rect2(-Vector2(4.0, 4.0), Vector2(8.0, 8.0)), OUTLINE)
	draw_rect(Rect2(-Vector2(2.0, 2.0), Vector2(4.0, 4.0)), IVORY)
	draw_rect(Rect2(-Vector2(3.0, 4.0), Vector2(2.0, 8.0)), GOLD)
	draw_rect(Rect2(Vector2(0.0, -1.0), Vector2(2.0, 2.0)), ARM_LIGHT)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _native_hand_anchor() -> Vector2:
	var anchors: Array = HAND_ANCHORS.get(_body_sprite.animation, [Vector2(41, 45)])
	var frame_index := mini(_body_sprite.frame, anchors.size() - 1)
	var pixel: Vector2 = anchors[frame_index]
	return Vector2((pixel.x - 32.0) * 2.0, (pixel.y - 32.0) * 2.0 - 50.0)

func _set_arm_mask(active: bool) -> void:
	if _mask_material == null:
		return
	_mask_material.set_shader_parameter("arm_mask_active", active)
	_mask_material.set_shader_parameter("arm_mask_rect", Vector4(39.0, 37.0, 45.0, 44.0))

func _world_direction_to_local(direction: Vector2) -> Vector2:
	var local_direction := global_transform.basis_xform_inv(direction)
	return local_direction.normalized() if not local_direction.is_zero_approx() else Vector2.RIGHT

func _clamp_grip(target: Vector2, shoulder: Vector2, fallback_axis: Vector2) -> Vector2:
	var offset := target - shoulder
	var distance := offset.length()
	var axis := offset / distance if distance > 0.001 else fallback_axis.normalized()
	if axis.is_zero_approx():
		axis = Vector2.RIGHT
	if distance < MIN_ARM_REACH:
		return shoulder + axis * MIN_ARM_REACH
	if distance > MAX_ARM_REACH:
		return shoulder + axis * MAX_ARM_REACH
	return target

func _solve_elbow(shoulder: Vector2, grip: Vector2, preferred_direction: Vector2) -> Vector2:
	var offset := grip - shoulder
	var raw_distance := offset.length()
	var fallback_axis := preferred_direction.normalized()
	if fallback_axis.is_zero_approx():
		fallback_axis = Vector2.RIGHT
	var side_reference := fallback_axis.orthogonal()
	var axis := offset / raw_distance if raw_distance > 0.001 else fallback_axis
	if axis.is_zero_approx():
		axis = Vector2.RIGHT
	var distance := clampf(raw_distance, MIN_ARM_REACH, UPPER_ARM_LENGTH + FOREARM_LENGTH - 0.001)
	var along := (UPPER_ARM_LENGTH * UPPER_ARM_LENGTH - FOREARM_LENGTH * FOREARM_LENGTH + distance * distance) / (2.0 * distance)
	var perpendicular := sqrt(maxf(UPPER_ARM_LENGTH * UPPER_ARM_LENGTH - along * along, 0.0))
	var side := axis.orthogonal()
	if side.dot(side_reference) < -ARM_SIDE_EPSILON:
		side = -side
	return shoulder + axis * along + side * perpendicular
