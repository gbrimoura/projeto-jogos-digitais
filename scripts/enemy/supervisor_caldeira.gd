class_name SupervisorCaldeira
extends CharacterBody2D

signal defeated
signal purge_warned(region: Rect2, kind: int, duration: float)
signal purge_released(region: Rect2, kind: int)
signal purge_cancelled(region: Rect2, kind: int)
signal reinforcement_warned(spawn_position: Vector2)
signal reinforcement_arrived(spawn_position: Vector2)
signal reinforcement_cancelled(spawn_position: Vector2)

enum AttackState {
	IDLE,
	BURST_WARNING,
	BURST_FIRING,
	COLUMN_WARNING,
	FLOOR_WARNING,
	HIGH_WARNING,
	RECOVERY,
	PHASE_TRANSITION,
}

const PROJECTILE_SCENE: PackedScene = preload("res://scenes/hostile_rivet.tscn")
const REINFORCEMENT_SCENE: PackedScene = preload("res://scenes/rivet_worker.tscn")
const REINFORCEMENT_WARNING_DURATION: float = 1.05
const REINFORCEMENT_MIN_PLAYER_DISTANCE: float = 260.0
const REINFORCEMENT_ARRIVAL_CLEARANCE: float = 110.0
const REINFORCEMENT_MIN_ENEMY_DISTANCE: float = 156.0
const REINFORCEMENT_SPAWN_X: Array[float] = [192.0, 320.0, 448.0, 640.0, 704.0, 832.0, 960.0]
const CORE_OFFSET: Vector2 = Vector2(0.0, 36.0)
const BASE_HEALTH: int = 60
const PHASE_TWO_THRESHOLD: int = 30
const HIT_COOLDOWN: float = 0.13
const CORE_OPEN_AFTER_ATTACK: float = 1.05
const CORE_OPEN_AFTER_RETURNED_RIVET: float = 1.8
const MAX_CORE_DAMAGE_PER_ATTACK: int = 7
const BURST_ANGLES: Array[float] = [-0.16, 0.0, 0.16]
const GANTRY_LEFT_LIMIT: float = 468.0
const GANTRY_RIGHT_LIMIT: float = 684.0
const GANTRY_SPEED: float = 120.0
const BURST_RECOIL_DURATION: float = 0.10
const PURGE_DISCHARGE_DURATION: float = 0.18
const IDLE_POSE_INTERVAL: float = 0.38

@export var display_name: String = "SUPERVISOR"
var max_health: int = BASE_HEALTH
@export_range(1.0, 1000.0, 1.0) var rivet_speed: float = 360.0
@export_range(1, 5, 1) var rivet_damage: int = 1
@export_range(0.5, 6.0, 0.1) var rivet_lifetime: float = 3.0

@onready var _body_sprite: Sprite2D = $Visuals/BossSprite
@onready var _warning_sound: AudioStreamPlayer2D = $WarningSound

var health: int = BASE_HEALTH
var enemy_level: int = 1

var _state: AttackState = AttackState.IDLE
var _state_remaining: float = 1.1
var _hit_cooldown_remaining: float = 0.0
var _core_open_remaining: float = 0.0
var _core_damage_taken_this_attack: int = 0
var _impact_flash_remaining: float = 0.0
var _flash_remaining: float = 0.0
var _player: Player
var _phase_two: bool = false
var _defeated_emitted: bool = false
var _next_phase_one_attack: int = 0
var _phase_two_attack_index: int = 0
var _locked_aim_direction: Vector2 = Vector2.DOWN
var _shots_remaining: int = 0
var _shot_interval_remaining: float = 0.0
var _burst_recoil_remaining: float = 0.0
var _idle_pose_remaining: float = IDLE_POSE_INTERVAL
var _idle_pose_frame: int = 0
var _gantry_target_x: float = GANTRY_LEFT_LIMIT
var _warning_rect: Rect2 = Rect2()
var _warning_rect_active: bool = false
var _purge_damage_applied: bool = false
var _owned_rivets: Array[HostileRivet] = []
var _owned_reinforcements: Array[RivetWorker] = []
var _phase_one_reinforcement_called: bool = false
var _phase_two_reinforcement_called: bool = false
var _reinforcement_warning_active: bool = false
var _reinforcement_spawn_pending: bool = false
var _reinforcement_warning_remaining: float = 0.0

var _reinforcement_warning_position: Vector2 = Vector2.ZERO


func configure_level(level: int, _level_config: EnemyLevelConfigResource) -> bool:
	if is_inside_tree() or level < 1:
		return false
	# The boss keeps its authored 60 HP across run stages while still reporting
	# the encounter level to the normal target HUD.
	enemy_level = level
	return true


func _ready() -> void:
	health = maxi(max_health, 1)
	_player = get_parent().get_node_or_null("Player") as Player
	add_to_group("damageable")
	add_to_group("combat_enemy")
	add_to_group("boss_enemy")
	_sync_sprite_frame()
	queue_redraw()


func _exit_tree() -> void:
	if _reinforcement_warning_active:
		_cancel_reinforcement_warning()
	_cancel_owned_reinforcements()
	_cancel_owned_rivets()


func _process(delta: float) -> void:
	if _flash_remaining > 0.0:
		_flash_remaining = maxf(_flash_remaining - delta, 0.0)
		_body_sprite.modulate = Color(1.0, 0.72, 0.58) if _flash_remaining > 0.0 else Color.WHITE
		_sync_sprite_frame()
	if _state == AttackState.PHASE_TRANSITION and is_instance_valid(_body_sprite):
		_body_sprite.rotation = sin(float(Time.get_ticks_msec()) * 0.018) * 0.035
		_body_sprite.position = Vector2.ZERO
	elif _state == AttackState.BURST_FIRING and is_instance_valid(_body_sprite):
		if _burst_recoil_remaining > 0.0:
			var recoil_amount := _burst_recoil_remaining / BURST_RECOIL_DURATION
			_body_sprite.position = -_locked_aim_direction * 4.0 * recoil_amount
			_body_sprite.rotation = 0.04 * recoil_amount
		elif _shots_remaining > 0 and _shot_interval_remaining <= 0.06:
			var windup_amount := 1.0 - clampf(_shot_interval_remaining / 0.06, 0.0, 1.0)
			_body_sprite.position = _locked_aim_direction * 2.0 * windup_amount
			_body_sprite.rotation = -0.018 * windup_amount
		else:
			_body_sprite.position = Vector2.ZERO
			_body_sprite.rotation = 0.0
	elif is_instance_valid(_body_sprite):
		_body_sprite.position = Vector2.ZERO
		_body_sprite.rotation = 0.0


func _physics_process(delta: float) -> void:
	if _defeated_emitted:
		return
	_tick_reinforcement_warning(delta)
	_hit_cooldown_remaining = maxf(_hit_cooldown_remaining - delta, 0.0)
	_impact_flash_remaining = maxf(_impact_flash_remaining - delta, 0.0)
	_burst_recoil_remaining = maxf(_burst_recoil_remaining - delta, 0.0)
	if _core_open_remaining > 0.0:
		_core_open_remaining = maxf(_core_open_remaining - delta, 0.0)
		if _core_open_remaining <= 0.0:
			_sync_sprite_frame()

	match _state:
		AttackState.IDLE:
			_state_remaining -= delta
			if _state_remaining <= 0.0:
				_begin_next_attack()
		AttackState.BURST_WARNING:
			_state_remaining -= delta
			if _state_remaining <= 0.0:
				_warning_rect_active = false
				_shots_remaining = 3
				_shot_interval_remaining = 0.0
				_state = AttackState.BURST_FIRING
		AttackState.BURST_FIRING:
			_shot_interval_remaining -= delta
			if _shots_remaining > 0 and _shot_interval_remaining <= 0.0:
				var shot_index := 3 - _shots_remaining
				_fire_rivet(_locked_aim_direction.rotated(BURST_ANGLES[shot_index]))
				_shots_remaining -= 1
				_shot_interval_remaining = 0.15
				_burst_recoil_remaining = BURST_RECOIL_DURATION
			if _shots_remaining <= 0:
				_finish_attack()
		AttackState.COLUMN_WARNING, AttackState.FLOOR_WARNING, AttackState.HIGH_WARNING:
			_state_remaining -= delta
			if _state_remaining <= 0.0:
				_resolve_purge()
				_finish_attack()
		AttackState.RECOVERY:
			_state_remaining -= delta
			if _state_remaining <= 0.0:
				_state = AttackState.IDLE
				_state_remaining = 0.42 if _phase_two else 0.56
		AttackState.PHASE_TRANSITION:
			_state_remaining -= delta
			if _state_remaining <= 0.0:
				_state = AttackState.IDLE
				_state_remaining = 0.45

	_update_gantry_motion(delta)
	_update_idle_pose(delta)
	_sync_sprite_frame()
	queue_redraw()


func take_damage(amount: int, source: Node = null) -> bool:
	if _defeated_emitted or health <= 0 or amount <= 0 \
		or _hit_cooldown_remaining > 0.0 or _state == AttackState.PHASE_TRANSITION:
		return false

	var damage_budget_remaining := MAX_CORE_DAMAGE_PER_ATTACK - _core_damage_taken_this_attack
	if damage_budget_remaining <= 0:
		return false

	var is_returned_rivet := source != null and source.is_in_group("player")
	var is_own_ball := source is RicochetBall
	if is_returned_rivet:
		_core_open_remaining = maxf(_core_open_remaining, CORE_OPEN_AFTER_RETURNED_RIVET)
	elif not is_own_ball or _core_open_remaining <= 0.0:
		return false

	var accepted_damage := mini(amount, damage_budget_remaining)
	_hit_cooldown_remaining = HIT_COOLDOWN
	_flash_remaining = 0.12
	_core_damage_taken_this_attack += accepted_damage
	health = maxi(health - accepted_damage, 0)
	if _core_damage_taken_this_attack >= MAX_CORE_DAMAGE_PER_ATTACK:
		_core_open_remaining = 0.0
	if not _phase_two and health <= PHASE_TWO_THRESHOLD:
		# A large hit starts phase two at its authored threshold instead of
		# skipping the transition or defeating the encounter in one hit.
		health = PHASE_TWO_THRESHOLD
		_start_phase_two()
	elif health <= 0:
		_finish_defeat()
	_sync_sprite_frame()
	queue_redraw()
	return true


func _begin_next_attack() -> void:
	if _phase_two:
		match _phase_two_attack_index % 3:
			0:
				_begin_purge(AttackState.FLOOR_WARNING)
			1:
				_begin_purge(AttackState.HIGH_WARNING)
			_:
				_begin_burst_warning(true)
		_phase_two_attack_index += 1
		return

	if _next_phase_one_attack == 0:
		_begin_burst_warning(false)
	else:
		_begin_column_purge()
	_next_phase_one_attack = 1 - _next_phase_one_attack


func _begin_burst_warning(is_phase_two_burst: bool) -> void:
	if _player != null and is_instance_valid(_player):
		_locked_aim_direction = (_player.global_position + Vector2(0.0, -38.0) - global_position).normalized()
	if _locked_aim_direction.is_zero_approx():
		_locked_aim_direction = Vector2.DOWN
	_state = AttackState.BURST_WARNING
	_state_remaining = 0.62 if is_phase_two_burst else 0.8
	_burst_recoil_remaining = 0.0
	velocity = Vector2.ZERO
	_warning_rect_active = false
	_play_warning(1.18 if is_phase_two_burst else 1.0)


func _begin_column_purge() -> void:
	var player_x := _player.global_position.x if _player != null and is_instance_valid(_player) else 576.0
	var column_index := 0 if player_x < 384.0 else (1 if player_x < 768.0 else 2)
	_warning_rect = Rect2(float(column_index * 384), 80.0, 384.0, 480.0)
	_warning_rect_active = true
	_impact_flash_remaining = 0.0
	_purge_damage_applied = false
	_state = AttackState.COLUMN_WARNING
	_state_remaining = 1.25
	velocity = Vector2.ZERO
	_play_warning(0.78)
	purge_warned.emit(_warning_rect, 0, _state_remaining)


func _begin_purge(purge_state: AttackState) -> void:
	if purge_state == AttackState.FLOOR_WARNING:
		_warning_rect = Rect2(32.0, 484.0, 1088.0, 76.0)
		_state_remaining = 1.55
		_play_warning(0.92)
	else:
		_warning_rect = Rect2(32.0, 330.0, 1088.0, 96.0)
		_state_remaining = 1.1
		_play_warning(1.42)
	_warning_rect_active = true
	_impact_flash_remaining = 0.0
	_purge_damage_applied = false
	_state = purge_state
	velocity = Vector2.ZERO
	var purge_kind := 1 if purge_state == AttackState.FLOOR_WARNING else 2
	purge_warned.emit(_warning_rect, purge_kind, _state_remaining)


func _resolve_purge() -> void:
	if _purge_damage_applied:
		return
	_purge_damage_applied = true
	var impact_rect := _warning_rect
	var purge_kind := _current_purge_kind()
	purge_released.emit(impact_rect, purge_kind)
	_warning_rect_active = false
	_impact_flash_remaining = PURGE_DISCHARGE_DURATION
	if not is_instance_valid(_player):
		return
	var collider := _player.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collider == null or collider.shape == null or collider.disabled:
		return
	var player_rect: Rect2 = collider.global_transform * collider.shape.get_rect()
	if impact_rect.intersects(player_rect):
		_player.take_damage(1, self)


func _finish_attack() -> void:
	_core_damage_taken_this_attack = 0
	_warning_rect_active = false
	_core_open_remaining = maxf(_core_open_remaining, CORE_OPEN_AFTER_ATTACK)
	_state = AttackState.RECOVERY
	_state_remaining = 0.65
	_maybe_schedule_phase_reinforcement()
	_sync_sprite_frame()


func _start_phase_two() -> void:
	_cancel_active_purge_warning()
	_cancel_reinforcement_warning()
	_phase_two = true
	_core_damage_taken_this_attack = 0
	_state = AttackState.PHASE_TRANSITION
	_state_remaining = 1.0
	_warning_rect_active = false
	_impact_flash_remaining = 0.0
	_core_open_remaining = 0.0
	_shots_remaining = 0
	_cancel_owned_rivets()
	_play_warning(1.34)
	_sync_sprite_frame()


func _finish_defeat() -> void:
	if _defeated_emitted:
		return
	_defeated_emitted = true
	_cancel_active_purge_warning()
	_state = AttackState.IDLE
	_warning_rect_active = false
	if _reinforcement_warning_active:
		_cancel_reinforcement_warning()
	_cancel_owned_reinforcements()
	_cancel_owned_rivets()
	defeated.emit()
	queue_free()


func _maybe_schedule_phase_reinforcement() -> void:
	if _reinforcement_warning_active:
		return
	if _phase_two:
		if _phase_two_reinforcement_called:
			return
	else:
		if _phase_one_reinforcement_called:
			return
	if _alive_reinforcement_count() >= 2:
		return
	var spawn_position := _choose_reinforcement_position()
	if spawn_position == Vector2.INF:
		return
	_reinforcement_warning_position = spawn_position
	_reinforcement_warning_remaining = REINFORCEMENT_WARNING_DURATION
	_reinforcement_warning_active = true
	_reinforcement_spawn_pending = false
	reinforcement_warned.emit(_reinforcement_warning_position)
	queue_redraw()


func _choose_reinforcement_position() -> Vector2:
	var room_root := get_parent() as Node2D
	if room_root == null:
		return Vector2.INF
	var player_position := _player.global_position if is_instance_valid(_player) else Vector2.INF
	var candidates: Array[Vector2] = []
	for spawn_x: float in REINFORCEMENT_SPAWN_X:
		var candidate: Vector2 = room_root.to_global(Vector2(spawn_x, 560.0))
		if is_instance_valid(_player) and candidate.distance_to(player_position) < REINFORCEMENT_MIN_PLAYER_DISTANCE:
			continue
		var occupied := false
		for reinforcement in _owned_reinforcements:
			if is_instance_valid(reinforcement) and not reinforcement.is_queued_for_deletion() \
				and candidate.distance_to(reinforcement.global_position) < REINFORCEMENT_MIN_ENEMY_DISTANCE:
				occupied = true
				break
		if not occupied:
			candidates.append(candidate)
	if candidates.is_empty():
		return Vector2.INF
	if not is_instance_valid(_player):
		return candidates[0]
	candidates.sort_custom(func(a: Vector2, b: Vector2) -> bool:
		return a.distance_squared_to(player_position) > b.distance_squared_to(player_position)
	)
	return candidates[0]


func _alive_reinforcement_count() -> int:
	var count := 0
	for reinforcement in _owned_reinforcements:
		if is_instance_valid(reinforcement) and not reinforcement.is_queued_for_deletion():
			count += 1
	return count


func _tick_reinforcement_warning(delta: float) -> void:
	if not _reinforcement_warning_active or _reinforcement_spawn_pending:
		return
	_reinforcement_warning_remaining = maxf(_reinforcement_warning_remaining - delta, 0.0)
	if _reinforcement_warning_remaining <= 0.0:
		_reinforcement_spawn_pending = true
		call_deferred("_spawn_reinforcement_now")


func _spawn_reinforcement_now() -> void:
	if not _reinforcement_warning_active:
		return
	_reinforcement_spawn_pending = false
	if _defeated_emitted or not is_inside_tree() or _alive_reinforcement_count() >= 2:
		_cancel_reinforcement_warning()
		return
	if is_instance_valid(_player) and _reinforcement_warning_position.distance_to(_player.global_position) < REINFORCEMENT_ARRIVAL_CLEARANCE:
		_cancel_reinforcement_warning()
		return
	var room_root := get_parent() as Node2D
	var encounter: CombatRoom = null
	if room_root != null:
		encounter = room_root.get_node_or_null("CombatRoom") as CombatRoom
	if room_root == null or encounter == null or encounter.room_is_cleared:
		_cancel_reinforcement_warning()
		return
	var reinforcement := REINFORCEMENT_SCENE.instantiate() as RivetWorker
	if reinforcement == null:
		_cancel_reinforcement_warning()
		return
	reinforcement.name = "SupervisorReinforcementPhase%d" % (2 if _phase_two else 1)
	reinforcement.patrol_half_width = 120.0
	reinforcement.patrol_speed = 72.0
	reinforcement.position = room_root.to_local(_reinforcement_warning_position)
	room_root.add_child(reinforcement)
	if not encounter.register_enemy(reinforcement):
		reinforcement.queue_free()
		_cancel_reinforcement_warning()
		return
	if _phase_two:
		_phase_two_reinforcement_called = true
	else:
		_phase_one_reinforcement_called = true
	_owned_reinforcements.append(reinforcement)
	reinforcement.defeated.connect(_on_reinforcement_defeated.bind(reinforcement), CONNECT_ONE_SHOT)
	_reinforcement_warning_active = false
	reinforcement_arrived.emit(_reinforcement_warning_position)
	queue_redraw()


func _on_reinforcement_defeated(reinforcement: Node) -> void:
	_owned_reinforcements.erase(reinforcement)


func _cancel_reinforcement_warning() -> void:
	if _reinforcement_warning_active:
		reinforcement_cancelled.emit(_reinforcement_warning_position)
	_reinforcement_warning_active = false
	_reinforcement_spawn_pending = false
	_reinforcement_warning_remaining = 0.0
	queue_redraw()


func _cancel_owned_reinforcements() -> void:
	var room_root := get_parent() as Node2D
	var encounter: CombatRoom = null
	if room_root != null:
		encounter = room_root.get_node_or_null("CombatRoom") as CombatRoom
	for reinforcement in _owned_reinforcements:
		if not is_instance_valid(reinforcement):
			continue
		if is_instance_valid(encounter) and encounter.is_inside_tree():
			encounter.unregister_enemy(reinforcement)
		reinforcement.queue_free()
	_owned_reinforcements.clear()


func _current_purge_kind() -> int:
	match _state:
		AttackState.COLUMN_WARNING:
			return 0
		AttackState.FLOOR_WARNING:
			return 1
		AttackState.HIGH_WARNING:
			return 2
	return -1


func _cancel_active_purge_warning() -> void:
	if not _warning_rect_active:
		return
	var purge_kind := _current_purge_kind()
	if purge_kind >= 0:
		purge_cancelled.emit(_warning_rect, purge_kind)
	_warning_rect_active = false
	_purge_damage_applied = true
	_impact_flash_remaining = 0.0
	queue_redraw()


func _fire_rivet(direction: Vector2) -> void:
	var parent := get_tree().get_first_node_in_group("hostile_projectile_container")
	if parent == null:
		parent = get_parent()
	if parent == null:
		return
	var rivet := PROJECTILE_SCENE.instantiate() as HostileRivet
	if rivet == null:
		return
	parent.add_child(rivet)
	var shot_direction := direction.normalized()
	rivet.global_position = global_position + shot_direction * 62.0
	rivet.launch(shot_direction, self, rivet_speed, rivet_damage, rivet_lifetime)
	_owned_rivets.append(rivet)
	rivet.finished.connect(_on_rivet_finished.bind(rivet), CONNECT_ONE_SHOT)


func _on_rivet_finished(_reason: String, rivet: HostileRivet) -> void:
	_owned_rivets.erase(rivet)


func _cancel_owned_rivets() -> void:
	for rivet in _owned_rivets:
		if not is_instance_valid(rivet):
			continue
		rivet.request_stop_sweep()
		rivet.hide()
		rivet.call_deferred("cancel")
	_owned_rivets.clear()


func _play_warning(pitch: float) -> void:
	if not is_instance_valid(_warning_sound):
		return
	_warning_sound.stop()
	_warning_sound.pitch_scale = pitch
	_warning_sound.play()


func _sync_sprite_frame() -> void:
	if not is_instance_valid(_body_sprite):
		return
	var pose_frame := 0
	if _flash_remaining > 0.0:
		pose_frame = 7
	elif _state == AttackState.PHASE_TRANSITION:
		pose_frame = 7
	elif _impact_flash_remaining > 0.0:
		pose_frame = 5
	elif _state == AttackState.BURST_WARNING:
		pose_frame = 2
	elif _state == AttackState.BURST_FIRING:
		pose_frame = 3
	elif _burst_recoil_remaining > 0.0 and _state == AttackState.RECOVERY:
		# The final shot can finish the attack immediately; keep its recoil pose
		# visible without changing the existing recovery or vulnerability timing.
		pose_frame = 3
	elif _state == AttackState.COLUMN_WARNING or _state == AttackState.FLOOR_WARNING or _state == AttackState.HIGH_WARNING:
		pose_frame = 4
	elif _core_open_remaining > 0.0:
		pose_frame = 6
	else:
		pose_frame = _idle_pose_frame
	_body_sprite.frame = pose_frame + (8 if _phase_two else 0)


func _update_gantry_motion(delta: float) -> void:
	if _state != AttackState.IDLE and _state != AttackState.RECOVERY:
		velocity = Vector2.ZERO
		return

	var current_x := global_position.x
	var distance_to_target := _gantry_target_x - current_x
	if absf(distance_to_target) <= GANTRY_SPEED * delta:
		global_position.x = _gantry_target_x
		_gantry_target_x = GANTRY_RIGHT_LIMIT if _gantry_target_x == GANTRY_LEFT_LIMIT else GANTRY_LEFT_LIMIT
		velocity = Vector2.ZERO
		return

	velocity = Vector2(signf(distance_to_target) * GANTRY_SPEED, 0.0)
	move_and_slide()
	global_position.x = clampf(global_position.x, GANTRY_LEFT_LIMIT, GANTRY_RIGHT_LIMIT)


func _update_idle_pose(delta: float) -> void:
	if (_state == AttackState.IDLE or _state == AttackState.RECOVERY) and _core_open_remaining <= 0.0:
		_idle_pose_remaining -= delta
		if _idle_pose_remaining <= 0.0:
			_idle_pose_frame = 1 - _idle_pose_frame
			_idle_pose_remaining = IDLE_POSE_INTERVAL


func _draw() -> void:
	var rail_y := 98.0 - global_position.y
	var rail_start := Vector2(GANTRY_LEFT_LIMIT - global_position.x, rail_y)
	var rail_end := Vector2(GANTRY_RIGHT_LIMIT - global_position.x, rail_y)
	var pulley := Vector2(0.0, rail_y)
	draw_line(rail_start, rail_end, Color("#27363f"), 8.0, true)
	draw_line(rail_start, rail_end, Color("#89999a"), 3.0, true)
	draw_line(Vector2(0.0, -86.0), pulley, Color("#27363f"), 6.0, true)
	draw_line(Vector2(0.0, -86.0), pulley, Color("#d0a765"), 2.0, true)
	draw_circle(pulley, 4.0, Color("#e5bd73"))
	if _warning_rect_active:
		var local_rect := Rect2(to_local(_warning_rect.position), _warning_rect.size)
		var pulse := (sin(float(Time.get_ticks_msec()) * 0.012) + 1.0) * 0.5
		var fill := Color(1.0, 0.21, 0.12, lerpf(0.10, 0.2, pulse))
		var edge := Color(1.0, 0.43, 0.2, lerpf(0.65, 0.95, pulse))
		draw_rect(local_rect, fill, true)
		draw_rect(local_rect, edge, false, 3.0)
		draw_string(ThemeDB.fallback_font, local_rect.position + Vector2(12.0, 22.0), "PURGA", HORIZONTAL_ALIGNMENT_LEFT, -1.0, 14, edge)
	elif _state == AttackState.BURST_WARNING:
		var endpoint := to_local(global_position + _locked_aim_direction * 1500.0)
		draw_line(Vector2.ZERO, endpoint, Color(1.0, 0.23, 0.16, 0.22), 10.0, true)
		draw_line(Vector2.ZERO, endpoint, Color(1.0, 0.53, 0.31, 0.9), 2.0, true)
		draw_circle(endpoint, 9.0, Color(1.0, 0.27, 0.17, 0.85), false, 3.0)

	if _phase_two:
		draw_string(ThemeDB.fallback_font, Vector2(-32.0, -106.0), "FASE 2", HORIZONTAL_ALIGNMENT_CENTER, 64.0, 12, Color("#f18a61"))
	else:
		draw_string(ThemeDB.fallback_font, Vector2(-32.0, -106.0), "FASE 1", HORIZONTAL_ALIGNMENT_CENTER, 64.0, 12, Color("#e7c271"))

	if _core_open_remaining > 0.0:
		var pulse := (sin(float(Time.get_ticks_msec()) * 0.01) + 1.0) * 0.5
		draw_circle(CORE_OFFSET, 31.0 + pulse * 3.0, Color(0.5, 0.96, 0.86, 0.7), false, 3.0)
