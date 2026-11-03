extends CanvasLayer

const TRANCA_PORTRAIT: Texture2D = preload("res://assets/ui/hud_caldeira_v1/export/portrait-tranca-lata-32x28.png")
const RIVET_PORTRAIT: Texture2D = preload("res://assets/ui/hud_caldeira_v1/export/portrait-rivet-worker-24.png")

@export var scale_reference_size: Vector2 = Vector2(960.0, 540.0):
	set(value):
		var safe_size: Vector2 = Vector2(maxf(value.x, 576.0), maxf(value.y, 324.0)).round()
		if scale_reference_size == safe_size:
			return
		scale_reference_size = safe_size
		_has_scale_metrics = false
		if is_node_ready():
			_sync_stage_transform()

@onready var _hud: Control = $HudRoot

var _controller: Node
var _bound_room: Node
var _player: Node
var _current_target: Node
var _enemy_cache: Dictionary = {}
var _visibility_before: Dictionary = {}
var _token: int = 0
var _room_exit_callable: Callable
var _player_health_callable: Callable
var _player_died_callable: Callable
var _tree: SceneTree
var _viewport: Viewport
var _font_ready: bool = false
var _internal_visibility_change: bool = false
var _root_hidden_for_context: bool = false
var _externally_hidden: bool = false
var _restore_visibility_pending: bool = false
var _legacy_nodes_hidden: bool = false
var _last_visible_rect: Rect2
var _last_stretch_transform: Transform2D
var _last_scale_reference_size: Vector2
var _last_hud_minimum_size: Vector2
var _last_hud_module_pixel_scale: int = 1
var _has_scale_metrics: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	layer = 1
	_controller = get_parent()
	_tree = get_tree()
	_viewport = get_viewport()
	if _tree != null:
		var node_added_callback: Callable = Callable(self, "_on_tree_node_added")
		if not _tree.node_added.is_connected(node_added_callback):
			_tree.node_added.connect(node_added_callback)
	if _viewport != null:
		var resize_callback: Callable = Callable(self, "_on_viewport_size_changed")
		if not _viewport.size_changed.is_connected(resize_callback):
			_viewport.size_changed.connect(resize_callback)
	if _hud != null:
		_font_ready = bool(_hud.call("is_font_ready"))
		var visibility_callback: Callable = Callable(self, "_on_hud_visibility_changed")
		if not _hud.visibility_changed.is_connected(visibility_callback):
			_hud.visibility_changed.connect(visibility_callback)
		var enabled_callback: Callable = Callable(self, "_on_hud_enabled_changed")
		if _hud.has_signal("enabled_changed") and not _hud.is_connected("enabled_changed", enabled_callback):
			_hud.connect("enabled_changed", enabled_callback)
	if not _font_ready:
		push_warning("HUD Caldeira: fonte bitmap inválida; mantendo o HUD legado.")
	_sync_stage_transform()
	set_process(true)

func _process(_delta: float) -> void:
	if _tree == null or _hud == null or not _font_ready:
		return
	_sync_stage_transform()
	if _tree.paused or _has_overlay_blocker():
		visible = false
		return
	visible = true
	if _restore_visibility_pending:
		_restore_legacy_visibility()
		_restore_visibility_pending = false
	if not bool(_hud.get("enabled")) or _externally_hidden:
		_deactivate(true)
		return
	if not bool(_hud.get("visible")) and not _root_hidden_for_context:
		_externally_hidden = true
		_deactivate(true)
		return
	var current_room: Node = _controller.get("current_room_instance") as Node
	if not _is_live_node(current_room):
		_unbind_room(true)
		_set_root_visible(false)
		_root_hidden_for_context = true
		return
	if current_room != _bound_room:
		_unbind_room(true)
		if not _bind_room(current_room):
			_set_root_visible(false)
			_root_hidden_for_context = true
			return
	if not _is_live_node(_bound_room) or not _is_live_node(_player):
		_unbind_room(true)
		_set_root_visible(false)
		_root_hidden_for_context = true
		return
	_root_hidden_for_context = false
	_set_root_visible(true)
	_ensure_legacy_hidden()
	_update_presentation()

func _exit_tree() -> void:
	_unbind_room(true)
	if _tree != null:
		var node_added_callback: Callable = Callable(self, "_on_tree_node_added")
		if _tree.node_added.is_connected(node_added_callback):
			_tree.node_added.disconnect(node_added_callback)
	if _viewport != null:
		var resize_callback: Callable = Callable(self, "_on_viewport_size_changed")
		if _viewport.size_changed.is_connected(resize_callback):
			_viewport.size_changed.disconnect(resize_callback)

func _bind_room(room: Node) -> bool:
	if not _is_live_node(room):
		return false
	var candidate_player: Node = room.get_node_or_null("Player")
	var candidate_combat_room: Node = room.get_node_or_null("CombatRoom")
	if not _is_live_node(candidate_player) or not _is_live_node(candidate_combat_room) \
		or not candidate_player.has_signal("health_changed") \
		or not candidate_player.has_method("get_aim_target_position"):
		return false
	_bound_room = room
	_player = candidate_player
	_token += 1
	var bound_token: int = _token
	_room_exit_callable = Callable(self, "_on_bound_room_tree_exiting").bind(room, bound_token)
	if not room.tree_exiting.is_connected(_room_exit_callable):
		room.tree_exiting.connect(_room_exit_callable)
	_player_health_callable = Callable(self, "_on_player_health_changed").bind(candidate_player, bound_token)
	if not candidate_player.is_connected("health_changed", _player_health_callable):
		candidate_player.connect("health_changed", _player_health_callable)
	_player_died_callable = Callable(self, "_on_player_died").bind(candidate_player, bound_token)
	if candidate_player.has_signal("died") and not candidate_player.is_connected("died", _player_died_callable):
		candidate_player.connect("died", _player_died_callable)
	_scan_room_for_enemies(room, bound_token)
	_hide_root_legacy_labels()
	_hide_room_legacy_labels(room)
	_ensure_legacy_hidden()
	_hud.call("set_health", int(candidate_player.get("current_health")), int(candidate_player.get("maximum_health")))
	return true

func _unbind_room(restore_visibility: bool) -> void:
	var old_token: int = _token
	_token += 1
	if _is_live_node(_bound_room) and _room_exit_callable.is_valid() \
		and _bound_room.tree_exiting.is_connected(_room_exit_callable):
		_bound_room.tree_exiting.disconnect(_room_exit_callable)
	if _is_live_node(_player):
		if _player_health_callable.is_valid() and _player.is_connected("health_changed", _player_health_callable):
			_player.disconnect("health_changed", _player_health_callable)
		if _player_died_callable.is_valid() and _player.has_signal("died") \
			and _player.is_connected("died", _player_died_callable):
			_player.disconnect("died", _player_died_callable)
	for enemy_variant: Variant in _enemy_cache.keys():
		if not is_instance_valid(enemy_variant):
			_enemy_cache.erase(enemy_variant)
			continue
		if not (enemy_variant is Node):
			_enemy_cache.erase(enemy_variant)
			continue
		_disconnect_enemy(enemy_variant as Node, old_token)
	_enemy_cache.clear()
	_bound_room = null
	_player = null
	_current_target = null
	_room_exit_callable = Callable()
	_player_health_callable = Callable()
	_player_died_callable = Callable()
	if _hud != null:
		_hud.call("clear_target")
	if restore_visibility and (_tree == null or not _tree.paused):
		_restore_legacy_visibility()
	else:
		_restore_visibility_pending = not _visibility_before.is_empty()
	_legacy_nodes_hidden = false

func _on_bound_room_tree_exiting(room: Node, bound_token: int) -> void:
	if bound_token != _token or room != _bound_room:
		return
	_unbind_room(_tree == null or not _tree.paused)
	_root_hidden_for_context = true
	_set_root_visible(false)

func _on_player_health_changed(current: int, maximum: int, player: Node, bound_token: int) -> void:
	if bound_token != _token or player != _player or not _is_live_node(player) or _tree.paused:
		return
	_hud.call("set_health", current, maximum)

func _on_player_died(player: Node, bound_token: int) -> void:
	if bound_token != _token or player != _player or not _is_live_node(player) or _tree.paused:
		return
	_hud.call("set_health", int(player.get("current_health")), int(player.get("maximum_health")))

func _scan_room_for_enemies(room: Node, bound_token: int) -> void:
	for child: Node in room.get_children():
		_scan_node_for_enemy(child, room, bound_token)

func _scan_node_for_enemy(node: Node, room: Node, bound_token: int) -> void:
	if not _is_live_node(node):
		return
	_consider_enemy(node, room, bound_token)
	for child: Node in node.get_children():
		_scan_node_for_enemy(child, room, bound_token)

func _on_tree_node_added(node: Node) -> void:
	if _tree == null or _tree.paused or not _is_live_node(_bound_room) or not _is_live_node(node):
		return
	if node == _bound_room or _bound_room.is_ancestor_of(node):
		call_deferred("_consider_enemy", node, _bound_room, _token)

func _consider_enemy(node: Node, room: Node, bound_token: int) -> void:
	if bound_token != _token or room != _bound_room or _tree == null or _tree.paused \
		or not _is_live_node(room) or not _is_live_node(node):
		return
	if node == room or not room.is_ancestor_of(node) or not node.is_in_group("combat_enemy"):
		return
	if not _has_target_properties(node) or _enemy_cache.has(node):
		return
	_enemy_cache[node] = true
	var exit_callback: Callable = Callable(self, "_on_enemy_tree_exiting").bind(node, bound_token)
	if not node.tree_exiting.is_connected(exit_callback):
		node.tree_exiting.connect(exit_callback)
	if node.has_signal("defeated"):
		var defeated_callback: Callable = Callable(self, "_on_enemy_defeated").bind(node, bound_token)
		if not node.is_connected("defeated", defeated_callback):
			node.connect("defeated", defeated_callback)
	_hide_enemy_legacy_nodes(node)

func _has_target_properties(node: Node) -> bool:
	var found_health: bool = false
	var found_maximum: bool = false
	var found_name: bool = false
	for property_variant: Variant in node.get_property_list():
		if typeof(property_variant) != TYPE_DICTIONARY:
			continue
		var property_data: Dictionary = property_variant as Dictionary
		var property_name: String = String(property_data.get("name", ""))
		found_health = found_health or property_name == "health"
		found_maximum = found_maximum or property_name == "max_health"
		found_name = found_name or property_name == "display_name"
	return found_health and found_maximum and found_name

func _is_eligible_enemy(node: Node) -> bool:
	if not _is_live_node(node) or not node.is_in_group("combat_enemy") \
		or not (node is Node2D) or _bound_room == null or not _bound_room.is_ancestor_of(node):
		return false
	return int(node.get("health")) > 0 and int(node.get("max_health")) > 0

func _on_enemy_defeated(enemy: Node, bound_token: int) -> void:
	if bound_token != _token or enemy == null or not _enemy_cache.has(enemy):
		return
	_enemy_cache.erase(enemy)
	if enemy == _current_target:
		_current_target = null
		_hud.call("clear_target")

func _on_enemy_tree_exiting(enemy: Node, bound_token: int) -> void:
	if bound_token != _token:
		return
	_enemy_cache.erase(enemy)
	_restore_visibility_for_subtree(enemy)
	if enemy == _current_target:
		_current_target = null
		_hud.call("clear_target")
	_disconnect_enemy(enemy, bound_token)

func _disconnect_enemy(enemy: Node, bound_token: int) -> void:
	if not _is_live_node(enemy):
		return
	var exit_callback: Callable = Callable(self, "_on_enemy_tree_exiting").bind(enemy, bound_token)
	if enemy.tree_exiting.is_connected(exit_callback):
		enemy.tree_exiting.disconnect(exit_callback)
	if enemy.has_signal("defeated"):
		var defeated_callback: Callable = Callable(self, "_on_enemy_defeated").bind(enemy, bound_token)
		if enemy.is_connected("defeated", defeated_callback):
			enemy.disconnect("defeated", defeated_callback)

func _update_presentation() -> void:
	var floor_index: int = int(_controller.get("current_floor"))
	var floor_total: int = int(_controller.get("floors_per_run"))
	var room_index: int = int(_controller.get("current_room"))
	var room_total: int = int(_controller.get("common_rooms_per_floor"))
	_hud.call("set_progress", floor_index, floor_total, room_index, room_total, room_index > room_total)
	var movement: Node = _player.get("movement_controller") as Node
	if _is_live_node(movement):
		var remaining: float = float(movement.get("dash_cooldown_remaining"))
		var duration: float = float(movement.call("get_dash_cooldown_duration"))
		var is_dashing: bool = bool(movement.get("is_dashing"))
		var can_dash: bool = bool(movement.get("can_dash"))
		var player_dead: bool = bool(_player.get("is_dead"))
		var state: StringName = &"UNAVAILABLE"
		if not player_dead and is_dashing:
			state = &"ACTIVE"
		elif not player_dead and remaining > 0.0:
			state = &"COOLDOWN"
		elif not player_dead and can_dash:
			state = &"READY"
		_hud.call("set_dash", state, remaining, duration)
	else:
		_hud.call("set_dash", &"UNAVAILABLE", 0.0, 0.0)
	var status_value: String = _read_status_text()
	var counter_value: String = _read_counter_text()
	var seed_value: String = _read_seed_text()
	if not counter_value.is_empty():
		status_value += "\n" if not status_value.is_empty() else ""
		status_value += counter_value
	if not seed_value.is_empty():
		status_value += "\n" if not status_value.is_empty() else ""
		status_value += seed_value
	_hud.call("set_status", status_value)
	_hud.call("set_build", _read_build_text())
	_hud.call("set_health", int(_player.get("current_health")), int(_player.get("maximum_health")))
	_update_target()

func _read_status_text() -> String:
	var local_status: Label = _bound_room.get_node_or_null("CombatRoom/HUD/StatusLabel") as Label
	var run_status: Label = _controller.get_node_or_null("HUD/StatusLabel") as Label
	if run_status != null and not run_status.text.is_empty() and run_status.text != "ENCONTRO ATIVO":
		return run_status.text
	return local_status.text if local_status != null else ""

func _read_counter_text() -> String:
	var counter: Label = _bound_room.get_node_or_null("CombatRoom/HUD/CounterLabel") as Label
	return counter.text if counter != null else ""

func _read_seed_text() -> String:
	if not _controller.has_method("get_resolved_run_seed"):
		return ""
	return "SEED %d" % int(_controller.call("get_resolved_run_seed"))

func _read_build_text() -> String:
	var build_label: Label = _bound_room.get_node_or_null("CombatRoom/HUD/BuildLabel") as Label
	return build_label.text if build_label != null else ""

func _update_target() -> void:
	var aim_position: Vector2 = _player.call("get_aim_target_position")
	var nearest: Node2D
	var nearest_distance_squared: float = INF
	var nearest_instance_id: int = 0
	for enemy_variant: Variant in _enemy_cache.keys():
		if not is_instance_valid(enemy_variant):
			_enemy_cache.erase(enemy_variant)
			continue
		if not (enemy_variant is Node):
			_enemy_cache.erase(enemy_variant)
			continue
		var enemy: Node = enemy_variant as Node
		if not _is_eligible_enemy(enemy):
			_enemy_cache.erase(enemy)
			continue
		var enemy_2d: Node2D = enemy as Node2D
		var distance_squared: float = enemy_2d.global_position.distance_squared_to(aim_position)
		var instance_id: int = enemy_2d.get_instance_id()
		if nearest == null or distance_squared < nearest_distance_squared \
			or (is_equal_approx(distance_squared, nearest_distance_squared) and instance_id < nearest_instance_id):
			nearest = enemy_2d
			nearest_distance_squared = distance_squared
			nearest_instance_id = instance_id
	if nearest == null:
		_current_target = null
		_hud.call("clear_target")
		return
	_current_target = nearest
	var target_level: int = maxi(int(nearest.get("enemy_level")), 1)
	var target_name: String = String(nearest.get("display_name"))
	var current_health: int = int(nearest.get("health"))
	var maximum_health: int = int(nearest.get("max_health"))
	_hud.call("set_target", target_name, current_health, maximum_health, _portrait_for(nearest), target_level)

func _portrait_for(enemy: Node) -> Texture2D:
	if enemy is TrainingTarget:
		return TRANCA_PORTRAIT
	if enemy is RivetWorker:
		return RIVET_PORTRAIT
	return null

func _hide_root_legacy_labels() -> void:
	_hide_canvas_item(_controller.get_node_or_null("HUD/ProgressLabel"))
	_hide_canvas_item(_controller.get_node_or_null("HUD/StatusLabel"))

func _hide_room_legacy_labels(room: Node) -> void:
	for path: String in [
		"CombatRoom/HUD/CounterLabel",
		"CombatRoom/HUD/StatusLabel",
		"CombatRoom/HUD/RoomLabel",
		"CombatRoom/HUD/HealthLabel",
		"CombatRoom/HUD/BuildLabel",
	]:
		_hide_canvas_item(room.get_node_or_null(path))

func _hide_enemy_legacy_nodes(enemy: Node) -> void:
	_hide_canvas_item(enemy.get_node_or_null("Visuals/HealthFrame"))
	_hide_canvas_item(enemy.get_node_or_null("Visuals/HealthFill"))
	_hide_canvas_item(enemy.get_node_or_null("Visuals/NameLabel"))
	_hide_canvas_item(enemy.get_node_or_null("NameLabel"))

func _hide_canvas_item(node: Node) -> void:
	var canvas_item: CanvasItem = node as CanvasItem
	if canvas_item == null or not canvas_item.visible:
		return
	if not _visibility_before.has(canvas_item):
		_visibility_before[canvas_item] = true
	canvas_item.visible = false

func _ensure_legacy_hidden() -> void:
	if not _legacy_nodes_hidden:
		_hide_root_legacy_labels()
		_hide_room_legacy_labels(_bound_room)
		for enemy_variant: Variant in _enemy_cache.keys():
			if not is_instance_valid(enemy_variant):
				_enemy_cache.erase(enemy_variant)
				continue
			if not (enemy_variant is Node):
				_enemy_cache.erase(enemy_variant)
				continue
			var enemy: Node = enemy_variant as Node
			if _is_live_node(enemy):
				_hide_enemy_legacy_nodes(enemy)
		_legacy_nodes_hidden = true
	else:
		for node_variant: Variant in _visibility_before.keys():
			if not is_instance_valid(node_variant):
				_visibility_before.erase(node_variant)
				continue
			if not (node_variant is CanvasItem):
				_visibility_before.erase(node_variant)
				continue
			var canvas_item: CanvasItem = node_variant as CanvasItem
			if canvas_item.visible:
				canvas_item.visible = false

func _restore_visibility_for_subtree(root: Node) -> void:
	if root == null:
		return
	for node_variant: Variant in _visibility_before.keys():
		if not is_instance_valid(node_variant):
			_visibility_before.erase(node_variant)
			continue
		if not (node_variant is CanvasItem):
			_visibility_before.erase(node_variant)
			continue
		var canvas_item: CanvasItem = node_variant as CanvasItem
		var owner_node: Node = canvas_item
		if owner_node == root or root.is_ancestor_of(owner_node):
			canvas_item.visible = bool(_visibility_before[node_variant])
			_visibility_before.erase(node_variant)

func _restore_legacy_visibility() -> void:
	for node_variant: Variant in _visibility_before.keys():
		if not is_instance_valid(node_variant):
			_visibility_before.erase(node_variant)
			continue
		if not (node_variant is CanvasItem):
			_visibility_before.erase(node_variant)
			continue
		var canvas_item: CanvasItem = node_variant as CanvasItem
		canvas_item.visible = bool(_visibility_before[node_variant])
	_visibility_before.clear()
	_legacy_nodes_hidden = false

func _on_hud_visibility_changed() -> void:
	if _internal_visibility_change or _tree == null or _tree.paused or _hud == null:
		return
	if not bool(_hud.get("visible")):
		_externally_hidden = true
		_deactivate(true)
	else:
		_externally_hidden = false

func _on_hud_enabled_changed(is_enabled: bool) -> void:
	if _tree != null and _tree.paused:
		return
	if not is_enabled:
		_deactivate(true)

func _deactivate(restore_visibility: bool) -> void:
	_unbind_room(restore_visibility)
	if _tree == null or not _tree.paused:
		_set_root_visible(false)
		_root_hidden_for_context = true

func _set_root_visible(is_visible: bool) -> void:
	if _hud == null or bool(_hud.get("visible")) == is_visible:
		return
	_internal_visibility_change = true
	_hud.set("visible", is_visible)
	_internal_visibility_change = false

func _is_live_node(node: Node) -> bool:
	return node != null and is_instance_valid(node) and node.is_inside_tree() and not node.is_queued_for_deletion()

func _has_overlay_blocker() -> bool:
	if _controller == null or not is_instance_valid(_controller):
		return false
	for child: Node in _controller.get_children():
		if child.name in [&"GameOverOverlay", &"VictoryOverlay", &"RewardScreen", &"RewardOverlay", &"ActiveRewardScreen", &"ManagedRoomTechnicalError"]:
			return true
	return false

func _sync_stage_transform() -> void:
	if _viewport == null:
		return
	var visible_rect: Rect2 = _viewport.get_visible_rect()
	var stretch_transform: Transform2D = _viewport.get_stretch_transform()
	var hud_module_pixel_scale: int = int(_hud.get("module_pixel_scale")) if _hud != null else 1
	var hud_minimum_size: Vector2 = _hud.custom_minimum_size if _hud != null else Vector2.ZERO
	if _has_scale_metrics and visible_rect == _last_visible_rect \
		and stretch_transform == _last_stretch_transform \
		and scale_reference_size == _last_scale_reference_size \
		and hud_minimum_size == _last_hud_minimum_size \
		and hud_module_pixel_scale == _last_hud_module_pixel_scale:
		return
	var stretch_scale: Vector2 = stretch_transform.get_scale()
	if is_zero_approx(stretch_scale.x) or is_zero_approx(stretch_scale.y):
		stretch_scale = Vector2.ONE
	var final_size: Vector2 = visible_rect.size * stretch_scale
	if final_size.x <= 0.0 or final_size.y <= 0.0:
		return
	var safe_reference_size: Vector2 = Vector2(
		maxf(scale_reference_size.x, 576.0),
		maxf(scale_reference_size.y, 324.0)
	)
	var fit_scale: float = minf(final_size.x / safe_reference_size.x, final_size.y / safe_reference_size.y)
	var final_pixel_scale: int = maxi(1, int(floor(fit_scale)))
	var visible_origin: Vector2 = stretch_transform * visible_rect.position
	var final_origin: Vector2 = visible_origin.round()
	var inverse_stretch: Transform2D = stretch_transform.affine_inverse()
	var local_origin: Vector2 = inverse_stretch * final_origin
	var local_scale: Vector2 = Vector2(
		float(final_pixel_scale) / stretch_scale.x,
		float(final_pixel_scale) / stretch_scale.y
	)
	var available_stage_size: Vector2 = Vector2(
		floorf(final_size.x / float(final_pixel_scale)),
		floorf(final_size.y / float(final_pixel_scale))
	)
	if _hud != null:
		if _hud.has_method("set_available_stage_size"):
			_hud.call("set_available_stage_size", available_stage_size)
		else:
			_hud.size = available_stage_size
	transform = Transform2D(Vector2(local_scale.x, 0.0), Vector2(0.0, local_scale.y), local_origin)
	_last_visible_rect = visible_rect
	_last_stretch_transform = stretch_transform
	_last_scale_reference_size = scale_reference_size
	_last_hud_minimum_size = hud_minimum_size
	_last_hud_module_pixel_scale = hud_module_pixel_scale
	_has_scale_metrics = true

func _on_viewport_size_changed() -> void:
	_has_scale_metrics = false
	_sync_stage_transform()
