class_name TrainingTarget
extends StaticBody2D

## Sentinela estacionária de contenção integrada ao contrato antigo TrainingTarget.

signal defeated

enum AttackState { IDLE, WINDUP, ACTIVE, RECOVERY }

const PLAYER_MASK: int = 2
const WORLD_MASK: int = 1
const MAX_QUERY_RESULTS: int = 32
const CLAIMED_META := &"_target_claimed"

@export_range(1, 100, 1) var max_health: int = 3
@export_range(0.0, 1.0, 0.01) var flash_duration: float = 0.12
@export_range(16.0, 400.0, 1.0) var attack_radius: float = 140.0
@export var attack_center_offset: Vector2 = Vector2.ZERO
@export_range(0.05, 3.0, 0.01) var windup_duration: float = 0.65
@export_range(0.05, 1.0, 0.01) var active_window: float = 0.14
@export_range(1, 100, 1) var attack_damage: int = 1
@export_range(0.05, 5.0, 0.01) var recovery_duration: float = 1.4
@export_range(0.0, 0.5, 0.01) var recovery_fade_duration: float = 0.18

@export_group("Spawn")
## Posiciona o inimigo automaticamente em cima de uma plataforma da sala.
@export var spawn_on_platform: bool = true
## Distância mínima entre o inimigo e as bordas da plataforma.
@export var edge_margin: float = 16.0
@export var authored_support_enabled: bool = false
@export var fixed_support_path: NodePath = NodePath("")
@export var fallback_support_path: NodePath = NodePath("")

@onready var _body_sprite: AnimatedSprite2D = $Visuals/BodySprite
@onready var _health_fill: Polygon2D = $Visuals/HealthFill
@onready var _attack_visual: Node2D = $AttackAreaVisual

var health: int
var _flash_remaining: float = 0.0
var _attack_state: AttackState = AttackState.IDLE
var _state_remaining: float = 0.0
var _recovery_fade_remaining: float = 0.0
var _locked_attack_center: Vector2 = Vector2.ZERO
var _locked_player: PhysicsBody2D
var _damaged_player_ids: Dictionary = {}
var _defeated_emitted: bool = false
var _area_shape: CircleShape2D
var _area_query: PhysicsShapeQueryParameters2D
var _line_of_sight_query: PhysicsRayQueryParameters2D
var _placement_pending: bool = false

func _ready() -> void:
	health = maxi(max_health, 1)
	add_to_group("damageable")
	add_to_group("combat_enemy")
	if not _parent_room_allows_enemy_activation():
		process_mode = Node.PROCESS_MODE_DISABLED
		return

	if authored_support_enabled:
		var room := get_parent()
		if room == null or not room.has_method("get_prepared_authored_target_position"):
			push_error("TrainingTarget: a sala não preparou a posição autoral.")
			process_mode = Node.PROCESS_MODE_DISABLED
			return
		var prepared_position_value: Variant = room.call("get_prepared_authored_target_position", self)
		if typeof(prepared_position_value) != TYPE_VECTOR2:
			push_error("TrainingTarget: posição autoral preparada inválida.")
			process_mode = Node.PROCESS_MODE_DISABLED
			return
		var prepared_position: Vector2 = prepared_position_value
		position = prepared_position

	_configure_physics_queries()
	_set_attack_visual(&"hidden", 0.0)
	_update_visuals()
	if spawn_on_platform and not authored_support_enabled:
		# Fica inativo até ser posicionado, para não detectar o jogador no lugar errado.
		_placement_pending = true
		# Deferido para rodar depois que todas as plataformas já se posicionaram.
		_place_on_platform.call_deferred()

func _parent_room_allows_enemy_activation() -> bool:
	var room := get_parent()
	if room == null or not room.has_method("is_authored_layout_valid"):
		return true
	return bool(room.call("is_authored_layout_valid"))
func take_damage(amount: int, _source: Node = null) -> bool:
	if _defeated_emitted or health <= 0 or amount <= 0:
		return false

	health = maxi(health - amount, 0)
	_flash_remaining = maxf(flash_duration, 0.0)
	_update_visuals()
	if health == 0:
		_defeated_emitted = true
		_cancel_attack()
		defeated.emit()
		queue_free()
	return true

func _physics_process(delta: float) -> void:
	_update_hit_flash(delta)
	if _defeated_emitted or _placement_pending:
		return
	if not _is_inside_current_scene():
		_cancel_attack()
		return
	if _attack_state != AttackState.IDLE and not _is_alive_player(_locked_player):
		_cancel_attack()
		return

	var physics_step := maxf(delta, 0.0)
	match _attack_state:
		AttackState.IDLE:
			var detected_player := _find_player_in_attack_area(global_position + attack_center_offset)
			if detected_player != null:
				_begin_windup(detected_player)
		AttackState.WINDUP:
			_update_windup(physics_step)
		AttackState.ACTIVE:
			_update_active(physics_step)
		AttackState.RECOVERY:
			_update_recovery(physics_step)

func _configure_physics_queries() -> void:
	_area_shape = CircleShape2D.new()
	_area_shape.radius = _effective_attack_radius()
	_area_query = PhysicsShapeQueryParameters2D.new()
	_area_query.shape = _area_shape
	_area_query.collision_mask = PLAYER_MASK
	_area_query.collide_with_bodies = true
	_area_query.collide_with_areas = false
	_area_query.margin = 0.0
	_area_query.exclude = [get_rid()]

	_line_of_sight_query = PhysicsRayQueryParameters2D.new()
	_line_of_sight_query.collision_mask = WORLD_MASK
	_line_of_sight_query.collide_with_bodies = true
	_line_of_sight_query.collide_with_areas = false
	_line_of_sight_query.exclude = [get_rid()]

func _effective_attack_radius() -> float:
	return clampf(attack_radius, 16.0, 400.0)

func _find_player_in_attack_area(area_center: Vector2) -> PhysicsBody2D:
	if _area_query == null or _area_shape == null:
		return null
	_area_shape.radius = _effective_attack_radius()
	_area_query.transform = Transform2D(0.0, area_center)
	var overlaps: Array[Dictionary] = get_world_2d().direct_space_state.intersect_shape(
		_area_query,
		MAX_QUERY_RESULTS
	)
	for overlap in overlaps:
		var collider: Variant = overlap.get("collider")
		if not collider is PhysicsBody2D:
			continue
		var player_body := collider as PhysicsBody2D
		if not _is_alive_player(player_body):
			continue
		if _has_clear_line_of_sight(player_body, area_center):
			return player_body
	return null

func _is_alive_player(candidate: PhysicsBody2D) -> bool:
	if not is_instance_valid(candidate):
		return false
	if not candidate.is_in_group("player") or not candidate.has_method("take_damage"):
		return false
	var dead_value: Variant = candidate.get("is_dead")
	if typeof(dead_value) != TYPE_BOOL or bool(dead_value):
		return false
	return _node_is_inside_current_scene(candidate)

func _has_clear_line_of_sight(player_body: PhysicsBody2D, area_center: Vector2) -> bool:
	_line_of_sight_query.from = area_center
	_line_of_sight_query.to = _get_player_collider_center(player_body)
	var obstruction: Dictionary = get_world_2d().direct_space_state.intersect_ray(
		_line_of_sight_query
	)
	return obstruction.is_empty()

func _get_player_collider_center(player_body: PhysicsBody2D) -> Vector2:
	var player_shape := player_body.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if player_shape != null and not player_shape.disabled:
		return player_shape.global_position
	return player_body.global_position

func _begin_windup(player_body: PhysicsBody2D) -> void:
	_locked_player = player_body
	_locked_attack_center = global_position + attack_center_offset
	_damaged_player_ids.clear()
	_attack_state = AttackState.WINDUP
	_state_remaining = maxf(windup_duration, 0.05)
	_recovery_fade_remaining = 0.0
	_update_attack_area_visual()

func _update_windup(delta: float) -> void:
	var before_step := _state_remaining
	_state_remaining = maxf(_state_remaining - delta, 0.0)
	if _state_remaining <= 0.0:
		var overshoot := maxf(delta - before_step, 0.0)
		_enter_active()
		_apply_attack_area()
		if overshoot >= maxf(active_window, 0.05):
			_enter_recovery()
		else:
			_state_remaining = maxf(active_window, 0.05) - overshoot
		return
	_update_attack_area_visual()

func _enter_active() -> void:
	_attack_state = AttackState.ACTIVE
	_state_remaining = maxf(active_window, 0.05)
	_update_attack_area_visual()
	_update_visuals()

func _update_active(delta: float) -> void:
	_apply_attack_area()
	_state_remaining = maxf(_state_remaining - delta, 0.0)
	if _state_remaining <= 0.0:
		_enter_recovery()

func _apply_attack_area() -> void:
	if _defeated_emitted or _attack_state != AttackState.ACTIVE:
		return
	var overlaps: Array[Dictionary] = _find_overlaps_at_locked_center()
	for overlap in overlaps:
		var collider: Variant = overlap.get("collider")
		if not collider is PhysicsBody2D:
			continue
		var player_body := collider as PhysicsBody2D
		if not _is_alive_player(player_body):
			continue
		var player_id := player_body.get_instance_id()
		if _damaged_player_ids.has(player_id):
			continue
		if not _has_clear_line_of_sight(player_body, _locked_attack_center):
			continue
		_damaged_player_ids[player_id] = true
		var damage_result: Variant = player_body.call(
			"take_damage",
			maxi(attack_damage, 1),
			self
		)
		if typeof(damage_result) == TYPE_BOOL and bool(damage_result):
			_set_attack_visual(&"impact", 1.0)

func _find_overlaps_at_locked_center() -> Array[Dictionary]:
	_area_shape.radius = _effective_attack_radius()
	_area_query.transform = Transform2D(0.0, _locked_attack_center)
	return get_world_2d().direct_space_state.intersect_shape(
		_area_query,
		MAX_QUERY_RESULTS
	)

func _enter_recovery() -> void:
	_attack_state = AttackState.RECOVERY
	_state_remaining = maxf(recovery_duration, 0.05)
	_recovery_fade_remaining = maxf(recovery_fade_duration, 0.0)
	_update_attack_area_visual()
	_update_visuals()

func _update_recovery(delta: float) -> void:
	_state_remaining = maxf(_state_remaining - delta, 0.0)
	_recovery_fade_remaining = maxf(_recovery_fade_remaining - delta, 0.0)
	_update_attack_area_visual()
	if _state_remaining <= 0.0:
		_attack_state = AttackState.IDLE
		_state_remaining = 0.0
		_recovery_fade_remaining = 0.0
		_locked_player = null
		_damaged_player_ids.clear()
		_set_attack_visual(&"hidden", 0.0)
		_update_visuals()

func _update_attack_area_visual() -> void:
	match _attack_state:
		AttackState.WINDUP:
			var windup_progress := 1.0 - clampf(
				_state_remaining / maxf(windup_duration, 0.05),
				0.0,
				1.0
			)
			_set_attack_visual(&"windup", 0.58 + windup_progress * 0.34)
		AttackState.ACTIVE:
			_set_attack_visual(&"active", 1.0)
		AttackState.RECOVERY:
			var fade_alpha := 0.0
			if recovery_fade_duration > 0.0:
				fade_alpha = _recovery_fade_remaining / recovery_fade_duration
			_set_attack_visual(&"recovery", clampf(fade_alpha, 0.0, 1.0))
		_:
			_set_attack_visual(&"hidden", 0.0)

func _set_attack_visual(phase: StringName, alpha: float) -> void:
	if not is_instance_valid(_attack_visual) or not _attack_visual.has_method("set_area_state"):
		return
	_attack_visual.call(
		"set_area_state",
		_effective_attack_radius(),
		attack_center_offset if _attack_state == AttackState.IDLE else _locked_attack_center - global_position,
		phase,
		alpha
	)

func _update_hit_flash(delta: float) -> void:
	if _flash_remaining <= 0.0:
		return
	_flash_remaining = maxf(_flash_remaining - maxf(delta, 0.0), 0.0)
	_update_visuals()

func _update_visuals() -> void:
	if not is_instance_valid(_body_sprite) or not is_instance_valid(_health_fill):
		return
	var desired_animation: StringName = &"impact" if _flash_remaining > 0.0 or _attack_state == AttackState.ACTIVE else &"idle"
	if _body_sprite.animation != desired_animation or not _body_sprite.is_playing():
		_body_sprite.play(desired_animation)
	var hit_flash := _body_sprite.material as ShaderMaterial
	if hit_flash != null:
		hit_flash.set_shader_parameter("flash_amount", 1.0 if _flash_remaining > 0.0 else 0.0)
	var health_ratio := clampf(float(health) / float(maxi(max_health, 1)), 0.0, 1.0)
	_health_fill.scale.x = health_ratio

func _cancel_attack() -> void:
	_attack_state = AttackState.IDLE
	_state_remaining = 0.0
	_recovery_fade_remaining = 0.0
	_locked_player = null
	_damaged_player_ids.clear()
	_set_attack_visual(&"hidden", 0.0)
	_update_visuals()

func _is_inside_current_scene() -> bool:
	return _node_is_inside_current_scene(self)

func _node_is_inside_current_scene(node: Node) -> bool:
	if not is_instance_valid(node):
		return false
	var scene_root := get_tree().current_scene
	return is_instance_valid(scene_root) and (scene_root == node or scene_root.is_ancestor_of(node))

## Retângulo da colisão em coordenadas locais (relativo à origem do inimigo).
func _get_collision_rect() -> Rect2:
	for child in get_children():
		var collision := child as CollisionShape2D
		if collision != null and collision.shape != null:
			var rect := collision.shape.get_rect()
			rect.position += collision.position
			return rect
	# Sem CollisionShape2D: assume que a origem está no centro da base.
	return Rect2(-16.0, -32.0, 32.0, 32.0)

func _place_on_platform() -> void:
	_placement_pending = false
	var body := _get_collision_rect()
	var needed_width := body.size.x + edge_margin * 2.0

	# Prefere plataformas livres; o Floor só entra se não sobrar nenhuma,
	# e plataformas já ocupadas por outro inimigo ficam por último.
	var free: Array[SolidPlatform] = []
	var floors: Array[SolidPlatform] = []
	var taken: Array[SolidPlatform] = []
	for node in get_tree().get_nodes_in_group(&"solid_platform"):
		var candidate := node as SolidPlatform
		if candidate == null or candidate.size.x < needed_width:
			continue
		if candidate.name == &"Floor":
			floors.append(candidate)
		elif candidate.has_meta(CLAIMED_META):
			taken.append(candidate)
		else:
			free.append(candidate)

	var pool: Array[SolidPlatform] = free
	if pool.is_empty():
		pool = floors
	if pool.is_empty():
		pool = taken
	if pool.is_empty():
		push_warning("%s: nenhuma plataforma larga o bastante; mantendo a posição original." % name)
		return

	var rng := RandomNumberGenerator.new()
	if SolidPlatform.room_seed == 0:
		rng.randomize()
	else:
		rng.seed = hash([SolidPlatform.room_seed, get_index(), "training_target"])

	var platform := pool[rng.randi_range(0, pool.size() - 1)]
	platform.set_meta(CLAIMED_META, true)

	var platform_left := platform.global_position.x - platform.size.x * 0.5
	var platform_right := platform.global_position.x + platform.size.x * 0.5
	var platform_top := platform.global_position.y - platform.size.y * 0.5

	# Mantém a colisão do inimigo inteira sobre a plataforma, com a base tocando o topo.
	var min_x := platform_left + edge_margin - body.position.x
	var max_x := platform_right - edge_margin - body.end.x
	global_position = Vector2(rng.randf_range(min_x, max_x), platform_top - body.end.y)
