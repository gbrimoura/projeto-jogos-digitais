class_name CombatFeedback
extends RefCounted

enum EffectKind { PARRY, WALL_RICOCHET, ENEMY_HIT, CHARGED_HIT }

const BURST_SCENE: PackedScene = preload("res://scenes/feedback/combat_feedback_burst.tscn")
const MAX_ACTIVE_BURSTS_PER_SCENE: int = 20
const PENDING_META := &"_combat_feedback_pending_dispatches"

static func enqueue(scene_root: Node, world_position: Vector2, effect_kind: int) -> void:
	if not is_instance_valid(scene_root) or scene_root.is_queued_for_deletion() or not scene_root.is_inside_tree():
		return
	var tree := scene_root.get_tree()
	if tree.current_scene != scene_root:
		return
	var pending_count := int(scene_root.get_meta(PENDING_META, 0))
	if _count_active_bursts(scene_root, tree) + pending_count >= MAX_ACTIVE_BURSTS_PER_SCENE:
		return
	var scene_instance_id := scene_root.get_instance_id()
	scene_root.set_meta(PENDING_META, pending_count + 1)
	Callable(CombatFeedback, "_spawn_if_current").call_deferred(
		scene_root,
		scene_instance_id,
		tree,
		world_position,
		effect_kind
	)

static func _spawn_if_current(
	scene_root: Node,
	scene_instance_id: int,
	tree: SceneTree,
	world_position: Vector2,
	effect_kind: int
) -> void:
	if is_instance_valid(scene_root) and scene_root.get_instance_id() == scene_instance_id:
		_decrement_pending(scene_root)
	if not is_instance_valid(scene_root) or scene_root.is_queued_for_deletion():
		return
	if not is_instance_valid(tree) or scene_root.get_instance_id() != scene_instance_id:
		return
	if not scene_root.is_inside_tree() or scene_root.get_tree() != tree or tree.current_scene != scene_root:
		return

	if _count_active_bursts(scene_root, tree) >= MAX_ACTIVE_BURSTS_PER_SCENE:
		return

	var burst := BURST_SCENE.instantiate() as CombatFeedbackBurst
	if burst == null:
		return
	burst.configure(effect_kind)
	scene_root.add_child(burst)
	burst.global_position = world_position

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
