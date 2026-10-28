extends RefCounted

const EDGE_HORIZONTAL_SCALE: float = 360.0
const EDGE_VERTICAL_SCALE: float = 200.0
const PLAYER_SUPPORT_TOLERANCE: float = 5.0
const MAX_PLAYER_FALL_LOOKAHEAD: float = 320.0

func choose_player_support(
	player: PhysicsBody2D,
	supports: Array[SolidPlatform],
	jump_solver: Object,
	previous_support: SolidPlatform
) -> SolidPlatform:
	if not is_instance_valid(player):
		return null
	var collision_shape := player.get_node_or_null("CollisionShape2D") as CollisionShape2D
	var player_rect := Rect2(player.global_position, Vector2.ZERO)
	var feet_y := player.global_position.y
	if collision_shape != null and not collision_shape.disabled and collision_shape.shape != null:
		var local_rect := collision_shape.shape.get_rect()
		player_rect = Rect2(collision_shape.global_position + local_rect.position, local_rect.size)
		feet_y = player_rect.end.y
	var character := player as CharacterBody2D
	var grounded := character != null and character.is_on_floor()
	var best_ground: SolidPlatform
	var best_ground_delta: float = INF
	var best_below: SolidPlatform
	var best_below_delta: float = INF
	for support in supports:
		if not bool(jump_solver.call("is_support_compatible", support)):
			continue
		var rect: Rect2 = jump_solver.call("support_rect", support)
		if player_rect.end.x < rect.position.x or player_rect.position.x > rect.end.x:
			continue
		var vertical_delta := rect.position.y - feet_y
		if absf(vertical_delta) <= PLAYER_SUPPORT_TOLERANCE:
			if absf(vertical_delta) < best_ground_delta:
				best_ground = support
				best_ground_delta = absf(vertical_delta)
		elif vertical_delta >= -PLAYER_SUPPORT_TOLERANCE and vertical_delta <= MAX_PLAYER_FALL_LOOKAHEAD:
			if vertical_delta < best_below_delta:
				best_below = support
				best_below_delta = vertical_delta
	if grounded and best_ground != null:
		return best_ground
	if is_instance_valid(previous_support) and bool(jump_solver.call("is_support_compatible", previous_support)):
		return previous_support
	if best_ground != null:
		return best_ground
	return best_below

func find_path(
	source: SolidPlatform,
	destination: SolidPlatform,
	supports: Array[SolidPlatform],
	jump_solver: Object,
	blocked_edges: Dictionary
) -> Array[SolidPlatform]:
	if source == destination:
		return [source]
	if not is_instance_valid(source) or not is_instance_valid(destination):
		return []
	var costs: Dictionary = {source.get_instance_id(): 0.0}
	var previous: Dictionary = {}
	var supports_by_id: Dictionary = {}
	var visited: Dictionary = {}
	var open: Array[SolidPlatform] = [source]
	supports_by_id[source.get_instance_id()] = source
	supports_by_id[destination.get_instance_id()] = destination
	for support in supports:
		supports_by_id[support.get_instance_id()] = support
	while not open.is_empty():
		var current_index: int = -1
		var current: SolidPlatform
		var current_cost: float = INF
		for index in range(open.size()):
			var candidate: SolidPlatform = open[index]
			var candidate_cost: float = float(costs.get(candidate.get_instance_id(), INF))
			if candidate_cost < current_cost:
				current_index = index
				current = candidate
				current_cost = candidate_cost
		if current_index < 0 or current == null:
			break
		open.remove_at(current_index)
		var current_id: int = current.get_instance_id()
		if visited.has(current_id):
			continue
		visited[current_id] = true
		if current == destination:
			break
		for neighbor in supports:
			if neighbor == current or not bool(jump_solver.call("can_reach_support", current, neighbor)):
				continue
			var neighbor_id: int = neighbor.get_instance_id()
			if visited.has(neighbor_id):
				continue
			if float(blocked_edges.get(edge_key(current, neighbor), 0.0)) > 0.0:
				continue
			var source_rect: Rect2 = jump_solver.call("support_rect", current)
			var destination_rect: Rect2 = jump_solver.call("support_rect", neighbor)
			var horizontal_cost := absf(source_rect.get_center().x - destination_rect.get_center().x) / EDGE_HORIZONTAL_SCALE
			var vertical_cost := absf(source_rect.position.y - destination_rect.position.y) / EDGE_VERTICAL_SCALE
			var edge_cost := 1.0 + horizontal_cost * 0.2 + vertical_cost * 0.25
			var next_cost: float = current_cost + edge_cost
			if next_cost >= float(costs.get(neighbor_id, INF)):
				continue
			costs[neighbor_id] = next_cost
			previous[neighbor_id] = current_id
			supports_by_id[neighbor_id] = neighbor
			if not open.has(neighbor):
				open.append(neighbor)
	var cursor_id: int = destination.get_instance_id()
	if not previous.has(cursor_id):
		return []
	var path: Array[SolidPlatform] = [destination]
	while cursor_id != source.get_instance_id():
		if not previous.has(cursor_id):
			return []
		cursor_id = int(previous[cursor_id])
		var step: SolidPlatform = supports_by_id.get(cursor_id) as SolidPlatform
		if step == null:
			return []
		path.append(step)
	path.reverse()
	return path

func edge_key(source: SolidPlatform, destination: SolidPlatform) -> String:
	if not is_instance_valid(source) or not is_instance_valid(destination):
		return ""
	return "%d>%d" % [source.get_instance_id(), destination.get_instance_id()]