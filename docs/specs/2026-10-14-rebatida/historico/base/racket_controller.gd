class_name RacketController
extends Node2D

signal swing_started(direction: Vector2)
signal swing_cancelled

## Parry pur de uma janela: a direção é capturada no clique e o movimento do
## jogador continua independente da raquete.

@export_range(0.01, 1.0, 0.01) var active_duration: float = 0.20
@export_range(0.05, 2.0, 0.01) var cooldown_duration: float = 0.55
@export_range(5.0, 120.0, 1.0) var arc_degrees: float = 50.0
@export_range(1.0, 200.0, 1.0) var reach: float = 70.0

const ARC_SEGMENTS: int = 12
const WORLD_MASK: int = 1

@onready var _shot_origin: Node2D = get_parent().get_node_or_null("ShotOrigin") as Node2D
@onready var _racket_visual: RacketVisual = get_parent().get_node_or_null("PlayerVisual/RacketVisual") as RacketVisual
@onready var _parry_fill: Polygon2D = $ParryFill
@onready var _parry_outline: Line2D = $ParryOutline
@onready var _cooldown_ring: Line2D = $CooldownRing

var _aim_direction: Vector2 = Vector2.RIGHT
var _frozen_direction: Vector2 = Vector2.RIGHT
var _swing_id: int = 0
var _active: bool = false
var _active_remaining: float = 0.0
var _active_window_this_frame: float = 0.0
var _cooldown_remaining: float = 0.0
var _success_flash_remaining: float = 0.0
var _sector_points: PackedVector2Array = PackedVector2Array()
var _world_probe_shape: CircleShape2D
var _world_probe_query: PhysicsShapeQueryParameters2D
var _world_ray_query: PhysicsRayQueryParameters2D

func _ready() -> void:
	process_physics_priority = -100
	add_to_group("racket_controller")
	set_physics_process(true)
	_world_probe_shape = CircleShape2D.new()
	_world_probe_shape.radius = 0.1
	_world_probe_query = PhysicsShapeQueryParameters2D.new()
	_world_probe_query.shape = _world_probe_shape
	_world_probe_query.collision_mask = WORLD_MASK
	_world_probe_query.collide_with_areas = false
	_world_probe_query.collide_with_bodies = true
	_world_probe_query.margin = 0.0
	_world_ray_query = PhysicsRayQueryParameters2D.new()
	_world_ray_query.collision_mask = WORLD_MASK
	_world_ray_query.collide_with_areas = false
	_world_ray_query.collide_with_bodies = true
	_world_ray_query.hit_from_inside = true
	_sync_anchor()
	_rebuild_sector()
	_update_racket_visual()
	_update_feedback()

func set_aim_direction(direction: Vector2) -> void:
	if direction.is_zero_approx():
		return
	_aim_direction = direction.normalized()
	if not _active:
		rotation = _aim_direction.angle()
		_update_racket_visual()

func _physics_process(delta: float) -> void:
	_sync_anchor()
	_rebuild_sector()
	_active_window_this_frame = 0.0
	_success_flash_remaining = maxf(_success_flash_remaining - delta, 0.0)
	if _active:
		_active_remaining = maxf(_active_remaining - delta, 0.0)
		if _active_remaining <= 0.000001:
			_active = false
	_cooldown_remaining = maxf(_cooldown_remaining - delta, 0.0)

	var player := get_parent()
	if player == null or player.get("is_dead") == true:
		cancel()
		return

	var parry_blocked := player.has_method("is_discrete_input_blocked") \
		and bool(player.call("is_discrete_input_blocked", &"parry"))
	if not parry_blocked and Input.is_action_just_pressed("parry") and not _active and _cooldown_remaining <= 0.00001:
		_begin_swing()
	elif not _active:
		rotation = _aim_direction.angle()
		_update_racket_visual()

	if _active:
		_active_window_this_frame = _active_remaining
	_update_feedback()

func get_active_swing_id() -> int:
	return _swing_id if _active and _active_window_this_frame > 0.0 else -1

func get_swing_direction() -> Vector2:
	return _frozen_direction

func get_parry_origin() -> Vector2:
	_sync_anchor()
	return global_position

func get_catch_radius(projectile_radius: float = 0.0) -> float:
	return reach + maxf(projectile_radius, 0.0)

## Continuous sweep against the rounded sector. A projectile already inside the
## arc can be parried at fraction zero only while closing toward the player.
func get_sweep_hit(
	start_position: Vector2,
	motion: Vector2,
	projectile_radius: float,
	frame_offset: float,
	segment_duration: float,
	last_swing_id: int,
	waiting_for_exit: bool
) -> Dictionary:
	if not _active or _active_window_this_frame <= 0.0 or last_swing_id == _swing_id:
		return {}
	if waiting_for_exit and start_position.distance_to(global_position) <= get_catch_radius(projectile_radius):
		return {}
	if motion.is_zero_approx():
		return {}

	var local_start := to_local(start_position)
	var local_motion := to_local(start_position + motion) - local_start
	var radius: float = maxf(projectile_radius, 0.0)
	var start_inside: bool = _point_inside_sector(local_start) or _distance_to_sector_edges(local_start) <= radius
	var fraction: float = 0.0 if start_inside else _first_rounded_polygon_entry(local_start, local_motion, radius)
	if not is_finite(fraction) or fraction < 0.0 or fraction > 1.0:
		return {}

	var hit_position: Vector2 = start_position + motion * fraction
	var relative_hit: Vector2 = hit_position - global_position
	if motion.dot(relative_hit) >= -0.0001:
		return {}
	var hit_time: float = frame_offset + segment_duration * fraction
	if hit_time > _active_window_this_frame + 0.000001:
		return {}
	if _world_path_blocked(hit_position):
		return {}
	return {"fraction": fraction, "swing_id": _swing_id, "direction": _frozen_direction}

func register_parry_success(swing_id: int) -> void:
	if swing_id != _swing_id:
		return
	_success_flash_remaining = 0.18
	_update_feedback()

func cancel() -> void:
	_active = false
	_active_remaining = 0.0
	_active_window_this_frame = 0.0
	_success_flash_remaining = 0.0
	swing_cancelled.emit()
	_update_feedback()

func reset() -> void:
	cancel()

	_update_feedback()

func _begin_swing() -> void:
	var mouse_offset := get_global_mouse_position() - global_position
	if not mouse_offset.is_zero_approx():
		_aim_direction = mouse_offset.normalized()
	_frozen_direction = _aim_direction
	rotation = _frozen_direction.angle()
	swing_started.emit(_frozen_direction)
	_swing_id += 1
	_active = true
	_active_remaining = maxf(active_duration, 0.01)
	_active_window_this_frame = _active_remaining
	_cooldown_remaining = maxf(cooldown_duration, 0.05)
	_update_racket_visual()
	_update_feedback()

func _sync_anchor() -> void:
	if _shot_origin != null:
		global_position = _shot_origin.global_position

func _rebuild_sector() -> void:
	_sector_points.clear()
	_sector_points.append(Vector2.ZERO)
	var half_angle := deg_to_rad(maxf(arc_degrees, 1.0) * 0.5)
	for index in range(ARC_SEGMENTS + 1):
		var angle := lerpf(-half_angle, half_angle, float(index) / float(ARC_SEGMENTS))
		_sector_points.append(Vector2.RIGHT.rotated(angle) * maxf(reach, 1.0))

func _point_inside_sector(point: Vector2) -> bool:
	return Geometry2D.is_point_in_polygon(point, _sector_points)

func _distance_to_sector_edges(point: Vector2) -> float:
	var closest := INF
	for index in range(_sector_points.size()):
		var a := _sector_points[index]
		var b := _sector_points[(index + 1) % _sector_points.size()]
		var edge := b - a
		var edge_length_squared := edge.length_squared()
		var t: float = 0.0
		if edge_length_squared > 0.0:
			t = clampf((point - a).dot(edge) / edge_length_squared, 0.0, 1.0)
		closest = minf(closest, point.distance_to(a + edge * t))
	return closest

func _first_rounded_polygon_entry(start: Vector2, motion: Vector2, radius: float) -> float:
	var best: float = INF
	for index in range(_sector_points.size()):
		var a := _sector_points[index]
		var b := _sector_points[(index + 1) % _sector_points.size()]
		best = minf(best, _sweep_point_capsule(start, motion, a, b, radius))
	return best

func _sweep_point_capsule(start: Vector2, motion: Vector2, a: Vector2, b: Vector2, radius: float) -> float:
	var best: float = INF
	best = minf(best, _sweep_point_circle(start, motion, a, radius))
	best = minf(best, _sweep_point_circle(start, motion, b, radius))

	var edge := b - a
	var edge_length := edge.length()
	var motion_length_squared := motion.length_squared()
	if edge_length <= 0.000001 or motion_length_squared <= 0.000001:
		return best
	var normal := edge / edge_length
	var side := normal.orthogonal()
	var start_distance := (start - a).dot(side)
	var motion_distance := motion.dot(side)
	if absf(motion_distance) > 0.000001:
		for side_index in range(2):
			var offset: float = -radius if side_index == 0 else radius
			var fraction: float = (offset - start_distance) / motion_distance
			if fraction < 0.0 or fraction > 1.0:
				continue
			var along: float = (start + motion * fraction - a).dot(normal)
			if along >= 0.0 and along <= edge_length:
				best = minf(best, fraction)
	return best

func _sweep_point_circle(start: Vector2, motion: Vector2, center: Vector2, radius: float) -> float:
	var offset := start - center
	var c: float = offset.length_squared() - radius * radius
	if c <= 0.0:
		return 0.0
	var a: float = motion.length_squared()
	if a <= 0.000001:
		return INF
	var b: float = 2.0 * offset.dot(motion)
	var discriminant: float = b * b - 4.0 * a * c
	if discriminant < 0.0:
		return INF
	var fraction: float = (-b - sqrt(discriminant)) / (2.0 * a)
	return fraction if fraction >= 0.0 and fraction <= 1.0 else INF

func _world_path_blocked(hit_position: Vector2) -> bool:
	if _shot_origin == null:
		return true
	var origin := _shot_origin.global_position
	if _world_point_blocked(origin) or _world_point_blocked(hit_position):
		return true
	_world_ray_query.from = origin
	_world_ray_query.to = hit_position
	return not get_world_2d().direct_space_state.intersect_ray(_world_ray_query).is_empty()

func _world_point_blocked(point: Vector2) -> bool:
	_world_probe_query.transform = Transform2D(0.0, point)
	return not get_world_2d().direct_space_state.intersect_shape(_world_probe_query, 1).is_empty()

func _update_racket_visual() -> void:
	if _racket_visual == null:
		return
	var direction := _frozen_direction if _active else _aim_direction
	_racket_visual.set_aim_direction(direction)

func _update_feedback() -> void:
	var player := get_parent()
	var dead: bool = player != null and player.get("is_dead") == true
	if dead:
		_parry_fill.visible = false
		_parry_outline.visible = false
		_cooldown_ring.visible = false
		return

	var success_visible: bool = _success_flash_remaining > 0.0
	var active_visible: bool = _active
	var arc_visible: bool = success_visible or active_visible
	var color := Color(0.56, 0.66, 0.76, 0.7)
	if success_visible:
		color = Color(0.35, 1.0, 0.72, 0.95)
	elif active_visible:
		color = Color(1.0, 0.70, 0.30, 0.92)
	elif _cooldown_remaining <= 0.0:
		color = Color(0.94, 0.70, 0.35, 0.32)

	_parry_fill.polygon = _sector_points
	_parry_fill.color = Color(color.r, color.g, color.b, 0.16)
	_parry_fill.visible = arc_visible
	var outline_points := _sector_points.duplicate()
	outline_points.append(Vector2.ZERO)
	_parry_outline.points = outline_points
	_parry_outline.default_color = color
	_parry_outline.visible = arc_visible

	var cooldown_ratio: float = 1.0
	if cooldown_duration > 0.0 and _cooldown_remaining > 0.0:
		cooldown_ratio = clampf(1.0 - _cooldown_remaining / cooldown_duration, 0.0, 1.0)
	var ring_points := PackedVector2Array()
	var ring_segments: int = maxi(1, ceili(24.0 * cooldown_ratio))
	for index in range(ring_segments + 1):
		var ring_angle: float = -PI * 0.5 + TAU * cooldown_ratio * float(index) / float(ring_segments)
		ring_points.append(Vector2.RIGHT.rotated(ring_angle) * 10.0)
	_cooldown_ring.points = ring_points
	_cooldown_ring.default_color = color
	_cooldown_ring.visible = not arc_visible




