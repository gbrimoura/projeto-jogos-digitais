class_name CombatFeedback
extends RefCounted

enum EffectKind { PARRY, WALL_RICOCHET, ENEMY_HIT, CHARGED_HIT }

const BURST_SCENE: PackedScene = preload("res://scenes/feedback/combat_feedback_burst.tscn")
const HitScreenShake = preload("res://scripts/feedback/hit_screen_shake.gd")
const MAX_ACTIVE_BURSTS_PER_SCENE: int = 20
const REFERENCE_SHOT_SPEED: float = 760.0
const PENDING_META := &"_combat_feedback_pending_dispatches"

static func enqueue(
	scene_root: Node, world_position: Vector2, effect_kind: int,
	direction: Vector2 = Vector2.ZERO, impact_speed: float = 0.0, scope: Node = null
) -> void:
	if not is_instance_valid(scene_root) or scene_root.is_queued_for_deletion() or not scene_root.is_inside_tree():
		return
	var tree := scene_root.get_tree()
	if tree.current_scene != scene_root:
		return
	var owner_id := scope.get_instance_id() if is_instance_valid(scope) else scene_root.get_instance_id()
	var pending_count := int(scene_root.get_meta(PENDING_META, 0))
	if _count_active_bursts(scene_root, tree) + pending_count >= MAX_ACTIVE_BURSTS_PER_SCENE:
		return
	scene_root.set_meta(PENDING_META, pending_count + 1)
	Callable(CombatFeedback, "_spawn_if_current").call_deferred(
		scene_root.get_instance_id(), owner_id, tree, world_position, effect_kind, direction, impact_speed
	)

static func _spawn_if_current(
	scene_id: int, owner_id: int, tree: SceneTree, world_position: Vector2,
	effect_kind: int, direction: Vector2, impact_speed: float
) -> void:
	var scene_root := instance_from_id(scene_id) as Node
	if is_instance_valid(scene_root):
		_decrement_pending(scene_root)
	if not is_instance_valid(scene_root) or scene_root.is_queued_for_deletion():
		return
	if not is_instance_valid(tree) or not scene_root.is_inside_tree() \
		or scene_root.get_tree() != tree or tree.current_scene != scene_root:
		return
	var effect_parent := instance_from_id(owner_id) as Node
	if not is_instance_valid(effect_parent) or effect_parent.is_queued_for_deletion() \
		or not effect_parent.is_inside_tree():
		return
	if effect_parent != scene_root and not scene_root.is_ancestor_of(effect_parent):
		return
	if _count_active_bursts(scene_root, tree) >= MAX_ACTIVE_BURSTS_PER_SCENE:
		return

	var burst := BURST_SCENE.instantiate() as CombatFeedbackBurst
	if burst == null:
		return
	var speed_ratio := impact_speed / REFERENCE_SHOT_SPEED
	burst.configure(effect_kind, direction, speed_ratio)
	effect_parent.add_child(burst)
	burst.global_position = world_position
	_kick_screen(effect_parent, effect_kind, direction, speed_ratio)

static func _kick_screen(room: Node, effect_kind: int, direction: Vector2, speed_ratio: float) -> void:
	var is_wall := effect_kind == EffectKind.WALL_RICOCHET
	var threshold := 1.28 if is_wall else 1.16
	if speed_ratio < threshold or not room.has_node("CombatRoom"):
		return
	var shaker := room.get_node_or_null("HitScreenShake") as HitScreenShake
	if shaker == null:
		shaker = HitScreenShake.new()
		shaker.name = "HitScreenShake"
		room.add_child(shaker)
	var strength := clampf(1.3 + (speed_ratio - threshold) * 3.0, 1.3, 3.0)
	shaker.kick(strength * (0.65 if is_wall else 1.0), direction)

static func _count_active_bursts(scene_root: Node, tree: SceneTree) -> int:
	var count := 0
	for node in tree.get_nodes_in_group("combat_feedback_burst"):
		if is_instance_valid(node) and scene_root.is_ancestor_of(node):
			count += 1
	return count

static func _decrement_pending(scene_root: Node) -> void:
	var pending_count := maxi(int(scene_root.get_meta(PENDING_META, 0)) - 1, 0)
	if pending_count == 0:
		if scene_root.has_meta(PENDING_META):
			scene_root.remove_meta(PENDING_META)
	else:
		scene_root.set_meta(PENDING_META, pending_count)
