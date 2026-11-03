extends RefCounted

const QUERY_MASK: int = 11 # World + Player + Damageable
const MAX_QUERY_RESULTS: int = 64
const MAX_SEGMENT_LENGTH: float = 8.0
const SAFE_MARGIN: float = 0.08
const EXIT_CLEARANCE: float = SAFE_MARGIN + 0.1
const EDGE_MARGIN: float = 16.0
const MIN_SUPPORT_WIDTH: float = 104.0
const MAX_HORIZONTAL: float = 360.0
const MAX_RISE: float = 144.0
const MAX_DROP: float = 200.0
const MAX_HORIZONTAL_SPEED: float = 480.0
const GRAVITY: float = 1400.0
const MIN_APEX: float = 72.0
const MAX_APEX: float = MAX_RISE + 48.0
const MIN_APEX_CLEARANCE: float = 48.0
const MAX_FLIGHT_TIME: float = 2.0
const POSITION_EPSILON: float = 0.01

var _owner: CharacterBody2D
var _query_shape: RectangleShape2D
var _query: PhysicsShapeQueryParameters2D
var _body_rect: Rect2

func configure(body: CharacterBody2D, body_rect: Rect2) -> void:
	_owner = body
	_body_rect = body_rect
	_query_shape = RectangleShape2D.new()
	_query_shape.size = body_rect.size
	_query = PhysicsShapeQueryParameters2D.new()
	_query.shape = _query_shape
	_query.collision_mask = QUERY_MASK
	_query.collide_with_bodies = true
	_query.collide_with_areas = false
	_query.margin = 0.0

func plan_jump(source: SolidPlatform, preferred_direction: int) -> Dictionary:
	if not _owner_is_ready() or not _support_is_valid(source) or not _standing_on(source):
		return {}
	var source_rect := _support_rect(source)
	var start_position := _owner.global_position
	var body_left := start_position.x + _body_rect.position.x
	var body_right := start_position.x + _body_rect.end.x
	if body_left < source_rect.position.x - 1.0 or body_right > source_rect.end.x + 1.0:
		return {}

	var candidates: Array[Dictionary] = []
	for node in _owner.get_tree().get_nodes_in_group(&"solid_platform"):
		var support := node as SolidPlatform
		if support == null or support == source or support.name == &"Floor":
			continue
		if not _support_is_valid(support):
			continue
		var rect := _support_rect(support)
		if rect.size.x < MIN_SUPPORT_WIDTH:
			continue
		var horizontal_gap := maxf(0.0, maxf(rect.position.x - source_rect.end.x, source_rect.position.x - rect.end.x))
		var rise := source_rect.position.y - rect.position.y
		if rise > MAX_RISE or rise < -MAX_DROP or horizontal_gap > MAX_HORIZONTAL:
			continue
		var minimum_x := rect.position.x + EDGE_MARGIN - _body_rect.position.x
		var maximum_x := rect.end.x - EDGE_MARGIN - _body_rect.end.x
		if maximum_x < minimum_x:
			continue
		var preferred := (rect.get_center().x - start_position.x) * signf(float(preferred_direction)) >= 0.0
		var rank := (0.0 if preferred else 10000.0) + absf(rect.get_center().x - start_position.x)
		candidates.append({"support": support, "rect": rect, "min_x": minimum_x, "max_x": maximum_x, "rank": rank})

	candidates.sort_custom(func(a: Dictionary, b: Dictionary) -> bool:
		return float(a["rank"]) < float(b["rank"])
	)
	for candidate in candidates:
		var support := candidate["support"] as SolidPlatform
		var rect: Rect2 = candidate["rect"]
		var xs := _candidate_landing_xs(
			start_position.x,
			float(candidate["min_x"]),
			float(candidate["max_x"])
		)
		for landing_x in xs:
			var route := _build_route(source, source_rect, support, rect, start_position, float(landing_x))
			if not route.is_empty():
				return route
	return {}

func is_support_compatible(support: SolidPlatform) -> bool:
	return _support_is_valid(support)

func support_rect(support: SolidPlatform) -> Rect2:
	if not _support_is_valid(support):
		return Rect2()
	return _support_rect(support)

func can_reach_support(source: SolidPlatform, destination: SolidPlatform) -> bool:
	if source == destination or not _support_is_valid(source) or not _support_is_valid(destination):
		return false
	var source_rect := _support_rect(source)
	var destination_rect := _support_rect(destination)
	if source_rect.size.x < MIN_SUPPORT_WIDTH or destination_rect.size.x < MIN_SUPPORT_WIDTH:
		return false
	var rise := source_rect.position.y - destination_rect.position.y
	if rise > MAX_RISE or rise < -MAX_DROP:
		return false
	var horizontal_gap := maxf(
		0.0,
		maxf(destination_rect.position.x - source_rect.end.x, source_rect.position.x - destination_rect.end.x)
	)
	return horizontal_gap <= MAX_HORIZONTAL

func plan_jump_to(
	source: SolidPlatform,
	destination: SolidPlatform,
	preferred_landing_x: float
) -> Dictionary:
	if not _owner_is_ready() or not _support_is_valid(source) or not _standing_on(source):
		return {}
	if not can_reach_support(source, destination):
		return {}
	var source_rect := _support_rect(source)
	var destination_rect := _support_rect(destination)
	var minimum_x := destination_rect.position.x + EDGE_MARGIN - _body_rect.position.x
	var maximum_x := destination_rect.end.x - EDGE_MARGIN - _body_rect.end.x
	if maximum_x < minimum_x:
		return {}
	var landing_xs := _candidate_landing_xs(preferred_landing_x, minimum_x, maximum_x)
	if destination.name == &"Floor":
		landing_xs = _floor_landing_xs(source_rect, minimum_x, maximum_x, preferred_landing_x)
	for landing_x in landing_xs:
		var route := _build_route(
			source,
			source_rect,
			destination,
			destination_rect,
			_owner.global_position,
			landing_x
		)
		if not route.is_empty():
			return route
	return {}

func _floor_landing_xs(source_rect: Rect2, minimum_x: float, maximum_x: float, preferred_x: float) -> Array[float]:
	var candidates := _candidate_landing_xs(preferred_x, minimum_x, maximum_x)
	var left_clear_x := source_rect.position.x - _body_rect.end.x - 4.0
	var right_clear_x := source_rect.end.x - _body_rect.position.x + 4.0
	if left_clear_x >= minimum_x and left_clear_x <= maximum_x:
		candidates.append(left_clear_x)
	if right_clear_x >= minimum_x and right_clear_x <= maximum_x:
		candidates.append(right_clear_x)
	var result: Array[float] = []
	for landing_x in candidates:
		var body_left := landing_x + _body_rect.position.x
		var body_right := landing_x + _body_rect.end.x
		if body_right > source_rect.position.x + 0.01 and body_left < source_rect.end.x - 0.01:
			continue
		var unique := true
		for existing in result:
			if absf(existing - landing_x) <= POSITION_EPSILON:
				unique = false
				break
		if unique:
			result.append(landing_x)
	result.sort_custom(func(a: float, b: float) -> bool:
		return absf(a - preferred_x) < absf(b - preferred_x)
	)
	return result
func revalidate_plan(plan: Dictionary, source: SolidPlatform) -> Dictionary:
	if plan.is_empty() or not _owner_is_ready() or source == null or not is_instance_valid(source):
		return {}
	var planned_source := plan.get("source") as SolidPlatform
	var destination := plan.get("destination") as SolidPlatform
	if planned_source != source or not _support_is_valid(source) or not _support_is_valid(destination):
		return {}
	var start_position: Vector2 = plan.get("start_position", Vector2.INF)
	if _owner.global_position.distance_to(start_position) > POSITION_EPSILON or not _standing_on(source):
		return {}
	var source_rect := _support_rect(source)
	var target_rect := _support_rect(destination)
	var landing_x := float(plan.get("landing_x", _owner.global_position.x))
	return _build_route(source, source_rect, destination, target_rect, _owner.global_position, landing_x)

func _build_route(
	source: SolidPlatform,
	source_rect: Rect2,
	destination: SolidPlatform,
	destination_rect: Rect2,
	start_position: Vector2,
	landing_x: float
) -> Dictionary:
	if not _support_is_valid(source) or not _support_is_valid(destination):
		return {}
	var landing_min_x := destination_rect.position.x + EDGE_MARGIN - _body_rect.position.x
	var landing_max_x := destination_rect.end.x - EDGE_MARGIN - _body_rect.end.x
	if landing_x < landing_min_x - POSITION_EPSILON or landing_x > landing_max_x + POSITION_EPSILON:
		return {}
	var dx := landing_x - start_position.x
	if absf(dx) > MAX_HORIZONTAL:
		return {}
	var rise := source_rect.position.y - destination_rect.position.y
	if rise > MAX_RISE or rise < -MAX_DROP:
		return {}

	var apex_height := minf(maxf(MIN_APEX, rise + MIN_APEX_CLEARANCE), MAX_APEX)
	var launch_vy := -sqrt(2.0 * GRAVITY * apex_height)
	var landing_y := destination_rect.position.y - 0.5 - _body_rect.end.y
	var dy := landing_y - start_position.y
	var discriminant := launch_vy * launch_vy + 2.0 * GRAVITY * dy
	if discriminant < 0.0:
		return {}
	var final_vy := sqrt(discriminant)
	var flight_time := (-launch_vy + final_vy) / GRAVITY
	if flight_time <= 0.0 or flight_time > MAX_FLIGHT_TIME:
		return {}
	if apex_height + 0.01 < rise + MIN_APEX_CLEARANCE:
		return {}
	var launch_vx := dx / flight_time
	if absf(launch_vx) > MAX_HORIZONTAL_SPEED:
		return {}
	if not _trajectory_is_clear(
		start_position,
		launch_vx,
		launch_vy,
		flight_time,
		source_rect.position.y,
		source,
		destination
	):
		return {}
	return {
		"source": source,
		"destination": destination,
		"start_position": start_position,
		"landing_position": Vector2(landing_x, landing_y),
		"landing_x": landing_x,
		"launch_velocity": Vector2(launch_vx, launch_vy),
		"gravity": GRAVITY,
		"flight_time": flight_time
	}

func _trajectory_is_clear(
	start_position: Vector2,
	launch_vx: float,
	launch_vy: float,
	flight_time: float,
	source_top: float,
	source: SolidPlatform,
	_destination: SolidPlatform
) -> bool:
	var final_vy := launch_vy + GRAVITY * flight_time
	var maximum_speed := maxf(
		Vector2(launch_vx, launch_vy).length(),
		Vector2(launch_vx, final_vy).length()
	)
	var steps := maxi(1, int(ceil(maximum_speed * flight_time / MAX_SEGMENT_LENGTH)))
	var sample_times: Array[float] = [0.0]
	for step_index in range(1, steps):
		sample_times.append(flight_time * float(step_index) / float(steps))
	if is_instance_valid(source) and launch_vy < 0.0:
		var start_bottom := start_position.y + _body_rect.end.y
		var clearance := start_bottom - (source_top - EXIT_CLEARANCE)
		var discriminant := launch_vy * launch_vy - 2.0 * GRAVITY * clearance
		if clearance > 0.0 and discriminant >= 0.0:
			var clear_time := (-launch_vy - sqrt(discriminant)) / GRAVITY
			if clear_time > 0.000001 and clear_time < flight_time - 0.000001:
				sample_times.append(clear_time)
	sample_times.append(flight_time)
	sample_times.sort()

	var unique_times: Array[float] = []
	for t in sample_times:
		if unique_times.is_empty() or t - unique_times.back() > 0.000001:
			unique_times.append(t)
	var space := _owner.get_world_2d().direct_space_state
	var previous_center := start_position + _body_rect.get_center()
	var previous_source_exception := is_instance_valid(source) and launch_vy < 0.0 \
		and start_position.y + _body_rect.end.y > source_top - EXIT_CLEARANCE
	for step_index in range(unique_times.size()):
		var t: float = unique_times[step_index]
		var node_position := start_position + Vector2(launch_vx * t, launch_vy * t + 0.5 * GRAVITY * t * t)
		var center := node_position + _body_rect.get_center()
		var vy := launch_vy + GRAVITY * t
		var bottom := node_position.y + _body_rect.end.y
		var allow_source_exit := (
			bottom > source_top - EXIT_CLEARANCE
			and vy < 0.0
			and is_instance_valid(source)
		)
		if _overlaps_at(space, center, source, allow_source_exit):
			return false
		if step_index > 0:
			_query.transform = Transform2D(0.0, previous_center)
			_query.motion = center - previous_center
			_query.exclude = _exclusions(source, previous_source_exception)
			var cast := space.cast_motion(_query)
			if cast.size() > 0 and cast[0] < 0.9999:
				return false
		previous_center = center
		previous_source_exception = allow_source_exit
	return true
func _overlaps_at(
	space: PhysicsDirectSpaceState2D,
	center: Vector2,
	source: SolidPlatform,
	allow_source_exit: bool
) -> bool:
	_query.transform = Transform2D(0.0, center)
	_query.motion = Vector2.ZERO
	_query.exclude = _exclusions(source, allow_source_exit)
	return not space.intersect_shape(_query, MAX_QUERY_RESULTS).is_empty()

func _exclusions(source: SolidPlatform, allow_source_exit: bool) -> Array[RID]:
	var exclusions: Array[RID] = [_owner.get_rid()]
	if allow_source_exit and is_instance_valid(source):
		exclusions.append(source.get_rid())
	return exclusions

func _candidate_landing_xs(start_x: float, minimum_x: float, maximum_x: float) -> Array[float]:
	var raw: Array[float] = [
		clampf(start_x, minimum_x, maximum_x),
		minimum_x,
		maximum_x,
		lerpf(minimum_x, maximum_x, 0.5),
		lerpf(minimum_x, maximum_x, 0.25),
		lerpf(minimum_x, maximum_x, 0.75)
	]
	raw.sort_custom(func(a: float, b: float) -> bool:
		return absf(a - start_x) < absf(b - start_x)
	)
	var result: Array[float] = []
	for x in raw:
		var unique := true
		for existing in result:
			if absf(existing - x) <= POSITION_EPSILON:
				unique = false
				break
		if unique:
			result.append(x)
	return result

func _support_is_valid(support: SolidPlatform) -> bool:
	if support == null or not is_instance_valid(support) or not support.is_inside_tree():
		return false
	if support.get_parent() != _owner.get_parent() or not _node_is_in_current_scene(support):
		return false
	if absf(support.global_rotation) > 0.001 or not support.global_scale.is_equal_approx(Vector2.ONE):
		return false
	var shape_count := 0
	for child in support.get_children():
		var collision := child as CollisionShape2D
		if collision == null:
			continue
		shape_count += 1
		if collision.disabled or not collision.shape is RectangleShape2D:
			return false
		if collision.position.length() > 0.01 or absf(collision.rotation) > 0.001 or not collision.scale.is_equal_approx(Vector2.ONE):
			return false
	return shape_count == 1

func _support_rect(support: SolidPlatform) -> Rect2:
	for child in support.get_children():
		var collision := child as CollisionShape2D
		if collision == null:
			continue
		var rectangle := collision.shape as RectangleShape2D
		if rectangle == null:
			return Rect2()
		return Rect2(collision.global_position - rectangle.size * 0.5, rectangle.size)
	return Rect2()

func _standing_on(support: SolidPlatform) -> bool:
	if not _support_is_valid(support):
		return false
	var rect := _support_rect(support)
	var feet_y := _owner.global_position.y + _body_rect.end.y
	return absf(feet_y - rect.position.y) <= 1.0

func _owner_is_ready() -> bool:
	return _owner != null and is_instance_valid(_owner) and _owner.is_inside_tree() \
		and _query != null and _query_shape != null

func _node_is_in_current_scene(node: Node) -> bool:
	var scene_root := _owner.get_tree().current_scene
	return is_instance_valid(scene_root) and (node == scene_root or scene_root.is_ancestor_of(node))