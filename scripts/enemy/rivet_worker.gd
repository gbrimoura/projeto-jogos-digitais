class_name RivetWorker
extends CharacterBody2D

## Inimigo terrestre que patrulha, se reposiciona, trava a mira e dispara.
signal defeated

enum AttackState { APPROACH, WINDUP, RECOVERY, RETREAT }

@export_range(1, 100, 1) var max_health: int = 3
@export_range(0.0, 1.0, 0.01) var flash_duration: float = 0.12
@export_range(1.0, 400.0, 1.0) var move_speed: float = 150.0
@export_range(0.0, 400.0, 1.0) var patrol_speed: float = 90.0
@export_range(0.0, 3.0, 0.01) var patrol_end_pause: float = 0.35
@export_range(0.0, 600.0, 1.0) var patrol_half_width: float = 250.0
@export var patrol_area_path: NodePath
@export_range(40.0, 800.0, 1.0) var minimum_attack_range: float = 220.0
@export_range(40.0, 1000.0, 1.0) var maximum_attack_range: float = 360.0
@export_range(0.05, 3.0, 0.01) var windup_duration: float = 0.65
@export_range(0.1, 1200.0, 1.0) var rivet_speed: float = 400.0
@export_range(1, 100, 1) var rivet_damage: int = 1
@export_range(0.05, 5.0, 0.01) var recovery_duration: float = 0.8
@export_range(0.1, 10.0, 0.01) var minimum_shot_interval: float = 2.6
@export_range(0.0, 96.0, 1.0) var close_range_retreat_step: float = 64.0
@export_range(0.0, 2.0, 0.01) var rivet_lifetime: float = 2.0
@export var player_aim_offset: Vector2 = Vector2(0.0, -60.0)
@export var rivet_scene: PackedScene
@export_range(-40.0, 0.0, 0.5) var warning_volume_db: float = -20.0

const WORLD_MASK: int = 1
const RIVET_SPAWN_OFFSET: float = 26.0
const MINIMUM_SAFE_SHOT_DISTANCE: float = 180.0
const BODY_HALF_WIDTH: float = 23.0
const REPOSITION_SEARCH_STEP: float = 16.0
const REPOSITION_SEARCH_DISTANCE: float = 128.0
const POSITION_EPSILON: float = 3.0

@onready var _body_fill: Polygon2D = $Visuals/BodyFill
@onready var _health_fill: Polygon2D = $Visuals/HealthFill
@onready var _visuals: Node2D = $Visuals
@onready var _warning_line: Line2D = $WarningLine
@onready var _warning_mark: Node2D = $WarningMark
@onready var _warning_sound: AudioStreamPlayer2D = $WarningSound

var health: int
var _player: Node2D
var _state: AttackState = AttackState.APPROACH
var _locked_direction: Vector2 = Vector2.RIGHT
var _windup_remaining: float = 0.0
var _recovery_remaining: float = 0.0
var _shot_cooldown_remaining: float = 0.0
var _retreat_remaining: float = 0.0
var _retreat_target_x: float = 0.0
var _retreat_used_this_cycle: bool = false
var _patrol_min_x: float = 0.0
var _patrol_max_x: float = 0.0
var _patrol_direction: float = 1.0
var _patrol_pause_remaining: float = 0.0
var _patrol_area_usable: bool = true
var _patrol_for_angle: bool = false
var _patrol_step_pending: bool = false
var _facing_direction: int = -1
var _flash_remaining: float = 0.0
var _defeated_emitted: bool = false
var _active_rivet: HostileRivet
var _query: PhysicsRayQueryParameters2D
var _ground_query: PhysicsRayQueryParameters2D
var _rivet_shape: CircleShape2D
var _rivet_query: PhysicsShapeQueryParameters2D
var _locked_muzzle_position: Vector2 = Vector2.ZERO

func _ready() -> void:
	health = maxi(max_health, 1)
	_configure_patrol_bounds()
	add_to_group("damageable")
	add_to_group("combat_enemy")
	_player = get_tree().get_first_node_in_group("player") as Node2D
	_query = PhysicsRayQueryParameters2D.new()
	_query.collision_mask = WORLD_MASK
	_query.collide_with_bodies = true
	_query.collide_with_areas = false
	_ground_query = PhysicsRayQueryParameters2D.new()
	_ground_query.collision_mask = WORLD_MASK
	_ground_query.collide_with_bodies = true
	_ground_query.collide_with_areas = false
	_rivet_shape = CircleShape2D.new()
	_rivet_shape.radius = 6.0
	_rivet_query = PhysicsShapeQueryParameters2D.new()
	_rivet_query.shape = _rivet_shape
	_rivet_query.collision_mask = WORLD_MASK
	_rivet_query.collide_with_bodies = true
	_rivet_query.collide_with_areas = false
	_rivet_query.margin = 0.08
	_prepare_warning_sound()
	_update_visuals()
	_apply_facing_direction()
	_set_warning_visible(false)

func take_damage(amount: int, _source: Node = null) -> void:
	if _defeated_emitted or health <= 0 or amount <= 0:
		return

	health = maxi(health - amount, 0)
	_flash_remaining = maxf(flash_duration, 0.0)
	_update_visuals()
	if health == 0:
		_defeated_emitted = true
		_set_warning_visible(false)
		defeated.emit()
		queue_free()

func _physics_process(delta: float) -> void:
	_patrol_step_pending = false
	if _defeated_emitted or health <= 0:
		velocity = Vector2.ZERO
		_set_warning_visible(false)
		return
	if _flash_remaining > 0.0:
		_flash_remaining = maxf(_flash_remaining - delta, 0.0)
		_update_visuals()
	_shot_cooldown_remaining = maxf(_shot_cooldown_remaining - delta, 0.0)

	if not is_on_floor():
		velocity.y = minf(velocity.y + 1600.0 * delta, 900.0)
	else:
		velocity.y = 0.0

	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D
	if _player == null or not is_instance_valid(_player):
		_patrol_for_angle = false
		_set_warning_visible(false)
		if _state == AttackState.WINDUP:
			_state = AttackState.APPROACH
			_windup_remaining = 0.0
		elif _state == AttackState.RETREAT:
			_state = AttackState.APPROACH
			_retreat_remaining = 0.0
		var previous_x := global_position.x
		if _state == AttackState.RECOVERY:
			_process_recovery(delta)
			velocity.x = 0.0
		else:
			_process_patrol(delta)
		move_and_slide()
		_finish_patrol_step(previous_x)
		return
	if _player.get("is_dead") == true:
		_patrol_for_angle = false
		velocity.x = 0.0
		_set_warning_visible(false)
		move_and_slide()
		return

	var was_retreating := _state == AttackState.RETREAT
	var previous_x := global_position.x
	match _state:
		AttackState.WINDUP:
			_process_windup(delta)
			velocity.x = 0.0
		AttackState.RECOVERY:
			_process_recovery(delta)
			velocity.x = 0.0
		AttackState.RETREAT:
			_process_retreat(delta)
		AttackState.APPROACH:
			_decide_ready_state(delta)
			_apply_ready_motion(delta)

	move_and_slide()
	if was_retreating and _state == AttackState.RETREAT:
		var travelled := absf(global_position.x - previous_x)
		_retreat_remaining = maxf(_retreat_remaining - travelled, 0.0)
		if travelled < 0.01 or _retreat_remaining <= POSITION_EPSILON:
			velocity.x = 0.0
			_state = AttackState.APPROACH
	_finish_patrol_step(previous_x)

func _finish_patrol_step(previous_x: float) -> void:
	if not _patrol_step_pending:
		return
	_patrol_step_pending = false
	if absf(global_position.x - previous_x) < 0.01:
		_patrol_direction *= -1.0
		_patrol_pause_remaining = maxf(patrol_end_pause, 0.0)
		velocity.x = 0.0
func _configure_patrol_bounds() -> void:
	var fallback_center := global_position.x
	var fallback_half_width := maxf(patrol_half_width, 0.0)
	_patrol_min_x = fallback_center - fallback_half_width
	_patrol_max_x = fallback_center + fallback_half_width
	if not patrol_area_path.is_empty():
		var patrol_area := get_node_or_null(patrol_area_path) as Node2D
		var left_marker: Marker2D = null
		var right_marker: Marker2D = null
		if patrol_area != null:
			left_marker = patrol_area.get_node_or_null("LeftLimit") as Marker2D
			right_marker = patrol_area.get_node_or_null("RightLimit") as Marker2D
		if left_marker != null and right_marker != null:
			_patrol_min_x = minf(left_marker.global_position.x, right_marker.global_position.x)
			_patrol_max_x = maxf(left_marker.global_position.x, right_marker.global_position.x)
		else:
			push_warning("RivetWorker: patrol_area_path inválido ou sem Marker2D LeftLimit/RightLimit; usando o fallback centrado no spawn.")

	if _patrol_max_x - _patrol_min_x <= BODY_HALF_WIDTH * 2.0 + POSITION_EPSILON * 2.0:
		_patrol_area_usable = false
		push_warning("RivetWorker: a área de patrulha não deixa espaço útil para o corpo; o inimigo ficará imóvel.")

func _get_safe_center_bounds() -> Vector2:
	return Vector2(_patrol_min_x + BODY_HALF_WIDTH, _patrol_max_x - BODY_HALF_WIDTH)

func _move_toward_area_x(target_x: float, speed: float, delta: float) -> bool:
	if not _patrol_area_usable or delta <= 0.0:
		velocity.x = 0.0
		return false
	var bounds := _get_safe_center_bounds()
	var destination_x := clampf(target_x, bounds.x, bounds.y)
	if global_position.x < bounds.x:
		destination_x = bounds.x
	elif global_position.x > bounds.y:
		destination_x = bounds.y
	var dx := destination_x - global_position.x
	var outside_bounds := global_position.x < bounds.x or global_position.x > bounds.y
	if absf(dx) <= POSITION_EPSILON and not outside_bounds:
		velocity.x = 0.0
		return true
	var direction := signf(dx)
	if not _has_ground_ahead(direction):
		velocity.x = 0.0
		return false
	_facing_direction = int(direction)
	_apply_facing_direction()
	var step_distance := minf(absf(dx), maxf(speed, 0.0) * delta)
	if step_distance <= 0.0:
		velocity.x = 0.0
		return true
	velocity.x = direction * step_distance / delta
	return true

func _process_patrol(delta: float) -> void:
	_set_warning_visible(false)
	if not _patrol_area_usable or delta <= 0.0:
		velocity.x = 0.0
		return
	var bounds := _get_safe_center_bounds()
	if global_position.x < bounds.x:
		_patrol_direction = 1.0
		_move_toward_area_x(bounds.x, patrol_speed, delta)
		return
	if global_position.x > bounds.y:
		_patrol_direction = -1.0
		_move_toward_area_x(bounds.y, patrol_speed, delta)
		return
	if _patrol_pause_remaining > 0.0:
		_patrol_pause_remaining = maxf(_patrol_pause_remaining - delta, 0.0)
		velocity.x = 0.0
		return
	if (_patrol_direction > 0.0 and global_position.x >= bounds.y - POSITION_EPSILON) or (_patrol_direction < 0.0 and global_position.x <= bounds.x + POSITION_EPSILON):
		_patrol_direction *= -1.0
		_patrol_pause_remaining = maxf(patrol_end_pause, 0.0)
		velocity.x = 0.0
		return
	var endpoint_x := bounds.y if _patrol_direction > 0.0 else bounds.x
	if not _move_toward_area_x(endpoint_x, patrol_speed, delta):
		_patrol_direction *= -1.0
		_patrol_pause_remaining = maxf(patrol_end_pause, 0.0)
		velocity.x = 0.0
		return
	_patrol_step_pending = not is_zero_approx(velocity.x)
func _process_windup(delta: float) -> void:
	_windup_remaining = maxf(_windup_remaining - delta, 0.0)
	_update_warning_line()
	if _windup_remaining <= 0.0:
		_fire_locked_rivet()
		_state = AttackState.RECOVERY
		_recovery_remaining = maxf(recovery_duration, 0.0)
		_shot_cooldown_remaining = maxf(minimum_shot_interval, 0.0)
		_retreat_used_this_cycle = false

func _process_recovery(delta: float) -> void:
	_recovery_remaining = maxf(_recovery_remaining - delta, 0.0)
	if _recovery_remaining <= 0.0:
		_state = AttackState.APPROACH

func _decide_ready_state(delta: float) -> void:
	if _patrol_area_usable:
		var bounds := _get_safe_center_bounds()
		if global_position.x < bounds.x or global_position.x > bounds.y:
			return
	var target := _get_player_aim_point()
	var desired_facing := _get_facing_for_target(target)
	var muzzle := _get_muzzle_position_at(global_position.x, desired_facing)
	var distance := muzzle.distance_to(target)
	if distance < minimum_attack_range:
		if not _retreat_used_this_cycle:
			_patrol_for_angle = false
			_begin_close_range_retreat(delta)
		return

	if _shot_cooldown_remaining > 0.0:
		return
	if distance > maximum_attack_range:
		return
	if not _has_line_of_sight(muzzle, target):
		return

	_patrol_for_angle = false
	_locked_direction = (target - muzzle).normalized()
	if _locked_direction.is_zero_approx():
		_locked_direction = Vector2.LEFT
	_facing_direction = desired_facing
	_apply_facing_direction()
	_locked_muzzle_position = muzzle
	velocity.x = 0.0
	_windup_remaining = maxf(windup_duration, 0.0)
	_state = AttackState.WINDUP
	_set_warning_visible(true)
	_warning_sound.play()
	_update_warning_line()

func _apply_ready_motion(delta: float) -> void:
	if _state != AttackState.APPROACH:
		return
	if not _patrol_area_usable:
		velocity.x = 0.0
		return
	var bounds := _get_safe_center_bounds()
	if global_position.x < bounds.x or global_position.x > bounds.y:
		_patrol_for_angle = false
		_move_toward_area_x(global_position.x, move_speed, delta)
		return

	var target := _get_player_aim_point()
	var desired_facing := _get_facing_for_target(target)
	var muzzle := _get_muzzle_position_at(global_position.x, desired_facing)
	var distance := muzzle.distance_to(target)
	if distance < minimum_attack_range:
		# Depois do único recuo permitido, espera o jogador abrir espaço.
		velocity.x = 0.0
		return

	if _shot_cooldown_remaining > 0.0:
		_process_patrol(delta)
		return
	if _patrol_for_angle:
		var clear_position := _find_nearest_clear_x(target)
		if is_finite(clear_position):
			if _move_toward_area_x(clear_position, move_speed, delta):
				_patrol_for_angle = false
			else:
				_process_patrol(delta)
		else:
			_process_patrol(delta)
		return
	var target_visible := _has_line_of_sight(muzzle, target)
	if distance > maximum_attack_range:
		_move_toward_area_x(target.x, move_speed, delta)
		return
	if not target_visible:
		var reposition_x := _find_nearest_clear_x(target)
		if is_finite(reposition_x):
			_move_toward_area_x(reposition_x, move_speed, delta)
		else:
			_patrol_for_angle = true
			_process_patrol(delta)
		return
	velocity.x = 0.0
func _find_nearest_clear_x(target: Vector2) -> float:
	var current_x := global_position.x
	var bounds := _get_safe_center_bounds()
	var best_x := INF
	var best_distance := INF
	var steps := int(REPOSITION_SEARCH_DISTANCE / REPOSITION_SEARCH_STEP)
	for step in range(1, steps + 1):
		for direction_value in [-1.0, 1.0]:
			var direction := float(direction_value)
			var candidate_x: float = current_x + direction * float(step) * REPOSITION_SEARCH_STEP
			if candidate_x < bounds.x or candidate_x > bounds.y:
				continue
			var candidate_facing := 1 if target.x > candidate_x else -1
			var candidate_muzzle := _get_muzzle_position_at(candidate_x, candidate_facing)
			var candidate_distance := candidate_muzzle.distance_to(target)
			if candidate_distance < minimum_attack_range or candidate_distance > maximum_attack_range:
				continue
			if not _has_line_of_sight(candidate_muzzle, target):
				continue
			if not _has_ground_at_x(candidate_x):
				continue
			var movement_distance := absf(candidate_x - current_x)
			if movement_distance < best_distance:
				best_distance = movement_distance
				best_x = candidate_x
	return best_x

func _has_line_of_sight(from: Vector2, to: Vector2) -> bool:
	if from.distance_squared_to(to) <= 0.01:
		return false
	_rivet_query.transform = Transform2D(0.0, from)
	_rivet_query.motion = Vector2.ZERO
	var space_state := get_world_2d().direct_space_state
	if not space_state.intersect_shape(_rivet_query, 1).is_empty():
		return false
	_rivet_query.motion = to - from
	var fractions := space_state.cast_motion(_rivet_query)
	return fractions.size() >= 2 and fractions[0] >= 1.0

func _has_ground_ahead(direction: float) -> bool:
	return _has_ground_at_x(global_position.x + direction * (BODY_HALF_WIDTH + 7.0))

func _has_ground_at_x(x_position: float) -> bool:
	var space_state := get_world_2d().direct_space_state
	_ground_query.from = Vector2(x_position, global_position.y - 12.0)
	_ground_query.to = Vector2(x_position, global_position.y + 24.0)
	_ground_query.exclude = [get_rid()]
	var result := space_state.intersect_ray(_ground_query)
	if result.is_empty():
		return false
	var surface_normal: Vector2 = result.get("normal", Vector2.ZERO)
	var surface_position: Vector2 = result.get("position", Vector2.ZERO)
	var surface_y := surface_position.y
	return surface_normal.y <= -0.7 and absf(surface_y - global_position.y) <= 24.0

func _fire_locked_rivet() -> void:
	_set_warning_visible(false)
	if _defeated_emitted or health <= 0 or rivet_scene == null or _player == null or not is_instance_valid(_player):
		return
	var muzzle := _locked_muzzle_position
	if muzzle.distance_to(_get_player_aim_point()) < MINIMUM_SAFE_SHOT_DISTANCE:
		return
	if _active_rivet != null and is_instance_valid(_active_rivet):
		return
	var parent := get_tree().get_first_node_in_group("hostile_projectile_container")
	if parent == null:
		parent = get_parent()
	if parent == null:
		return
	if not _is_clear_rivet_spawn(muzzle, _locked_direction):
		return
	var rivet := rivet_scene.instantiate() as HostileRivet
	if rivet == null:
		return
	parent.add_child(rivet)
	rivet.global_position = muzzle + _locked_direction * RIVET_SPAWN_OFFSET
	rivet.launch(_locked_direction, self, rivet_speed, rivet_damage, rivet_lifetime)
	_active_rivet = rivet
	rivet.finished.connect(_on_rivet_finished.bind(rivet), CONNECT_ONE_SHOT)

func _on_rivet_finished(_reason: String, rivet: HostileRivet) -> void:
	if rivet == _active_rivet:
		_active_rivet = null

func _get_muzzle_position_at(x_position: float, facing: int) -> Vector2:
	return Vector2(x_position + float(facing) * 22.0, global_position.y - 36.0)

func _get_muzzle_position() -> Vector2:
	return _get_muzzle_position_at(global_position.x, _facing_direction)

func _get_facing_for_target(target: Vector2) -> int:
	var horizontal_delta := target.x - global_position.x
	if is_zero_approx(horizontal_delta):
		return _facing_direction
	return 1 if horizontal_delta > 0.0 else -1

func _get_player_aim_point() -> Vector2:
	return _player.global_position + player_aim_offset

func _set_warning_visible(value: bool) -> void:
	if is_instance_valid(_warning_line):
		_warning_line.visible = value
	if is_instance_valid(_warning_mark):
		_warning_mark.visible = value

func _update_warning_line() -> void:
	if _state != AttackState.WINDUP or _warning_line == null:
		return
	var start := _locked_muzzle_position
	var motion := _locked_direction * maximum_attack_range
	_rivet_query.transform = Transform2D(0.0, start)
	_rivet_query.motion = motion
	var fractions := get_world_2d().direct_space_state.cast_motion(_rivet_query)
	var end := start + motion
	if fractions.size() >= 2 and fractions[0] < 1.0:
		end = start + motion * fractions[0]
	_warning_line.points = PackedVector2Array([to_local(start), to_local(end)])
	_warning_mark.modulate.a = 0.65 + 0.35 * (0.5 + 0.5 * sin(Time.get_ticks_msec() * 0.025))

func _is_clear_rivet_spawn(muzzle: Vector2, direction: Vector2) -> bool:
	var space_state := get_world_2d().direct_space_state
	_rivet_query.transform = Transform2D(0.0, muzzle)
	_rivet_query.motion = Vector2.ZERO
	if not space_state.intersect_shape(_rivet_query, 1).is_empty():
		return false
	var motion := direction.normalized() * RIVET_SPAWN_OFFSET
	_rivet_query.motion = motion
	var fractions := space_state.cast_motion(_rivet_query)
	if fractions.size() < 2 or fractions[0] < 1.0:
		return false
	var spawn_position := muzzle + motion
	_rivet_query.transform = Transform2D(0.0, spawn_position)
	_rivet_query.motion = Vector2.ZERO
	return space_state.intersect_shape(_rivet_query, 1).is_empty()

func _process_retreat(delta: float) -> void:
	_set_warning_visible(false)
	if not _patrol_area_usable:
		velocity.x = 0.0
		_retreat_remaining = 0.0
		_state = AttackState.APPROACH
		return
	var bounds := _get_safe_center_bounds()
	_retreat_target_x = clampf(_retreat_target_x, bounds.x, bounds.y)
	var away_direction := signf(_retreat_target_x - global_position.x)
	if _retreat_remaining <= POSITION_EPSILON or is_zero_approx(away_direction) or delta <= 0.0 or not _has_ground_ahead(away_direction):
		velocity.x = 0.0
		_retreat_remaining = 0.0
		_state = AttackState.APPROACH
		return
	var allowed_step := minf(move_speed * delta, minf(_retreat_remaining, absf(_retreat_target_x - global_position.x)))
	velocity.x = away_direction * allowed_step / delta

func _begin_close_range_retreat(delta: float) -> void:
	_retreat_used_this_cycle = true
	if not _patrol_area_usable:
		velocity.x = 0.0
		return
	var toward_player := signf(_player.global_position.x - global_position.x)
	if is_zero_approx(toward_player):
		toward_player = float(-_facing_direction)
	var away_direction := -toward_player
	var bounds := _get_safe_center_bounds()
	var destination_x := clampf(
		global_position.x + away_direction * maxf(close_range_retreat_step, 0.0),
		bounds.x,
		bounds.y
	)
	_retreat_target_x = destination_x
	_retreat_remaining = absf(destination_x - global_position.x)
	var retreat_direction := signf(destination_x - global_position.x)
	if _retreat_remaining <= POSITION_EPSILON or is_zero_approx(retreat_direction) or not _has_ground_ahead(retreat_direction):
		velocity.x = 0.0
		return
	_facing_direction = int(retreat_direction)
	_apply_facing_direction()
	_state = AttackState.RETREAT
	_set_warning_visible(false)
	if delta > 0.0:
		var allowed_step := minf(move_speed * delta, _retreat_remaining)
		velocity.x = retreat_direction * allowed_step / delta
		_retreat_remaining = maxf(_retreat_remaining - allowed_step, 0.0)
func _prepare_warning_sound() -> void:
	if _warning_sound.stream != null:
		return
	const sample_rate: int = 22050
	const duration: float = 0.09
	var sample_count := int(sample_rate * duration)
	var pcm := PackedByteArray()
	pcm.resize(sample_count * 2)
	for sample_index in range(sample_count):
		var time := float(sample_index) / float(sample_rate)
		var envelope := minf(time / 0.006, 1.0) * clampf((duration - time) / 0.022, 0.0, 1.0)
		var sample_value := int(sin(TAU * 880.0 * time) * envelope * 9000.0)
		pcm.encode_s16(sample_index * 2, sample_value)
	var warning_stream := AudioStreamWAV.new()
	warning_stream.format = AudioStreamWAV.FORMAT_16_BITS
	warning_stream.mix_rate = sample_rate
	warning_stream.stereo = false
	warning_stream.data = pcm
	_warning_sound.stream = warning_stream
	_warning_sound.volume_db = warning_volume_db

func _update_visuals() -> void:
	if not is_instance_valid(_body_fill) or not is_instance_valid(_health_fill):
		return
	_body_fill.color = Color("#fff1c7") if _flash_remaining > 0.0 else Color("#384759")
	var health_ratio := clampf(float(health) / float(maxi(max_health, 1)), 0.0, 1.0)
	_health_fill.scale.x = health_ratio

func _apply_facing_direction() -> void:
	if is_instance_valid(_visuals):
		_visuals.scale.x = float(_facing_direction)
