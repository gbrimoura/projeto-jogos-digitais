extends Node2D

signal run_progression_ready

const RoomTransition = preload("res://scripts/world/room_transition.gd")
const RoomTransitionOverlayScript = preload("res://scripts/world/room_transition_overlay.gd")
const RunBuild = preload("res://scripts/progression/run_build.gd")
const UpgradeOfferScene: PackedScene = preload("res://scenes/upgrade_offer.tscn")
const IMPACTO_REFORCADO_DEFINITION: UpgradeDefinitionResource = preload("res://resources/upgrades/impacto_reforcado.tres")
const MOTOR_ACELERADO_DEFINITION: UpgradeDefinitionResource = preload("res://resources/upgrades/motor_acelerado.tres")
const CARGA_REATIVA_DEFINITION: UpgradeDefinitionResource = preload("res://resources/upgrades/carga_reativa.tres")
const FALLBACK_PLAYER_SPAWN := Vector2(160.0, 560.0)
const WORLD_LAYER_BIT_MASK: int = 1
const AUTHORED_EDGE_MARGIN: float = 8.0
const AUTHORED_CONTACT_TOLERANCE: float = 0.5
const AUTHORED_OVERLAP_AREA_LIMIT: float = 0.01
const KNOWN_AUTHORED_PLATFORM_NAMES: Array[StringName] = [
	&"PlatformA", &"PlatformB", &"PlatformC", &"PlatformD", &"PlatformE",
	&"WestPlatform", &"UpperPlatform", &"EastPlatform",
]
const RoomLayoutGenerator = preload("res://scripts/world/room_layout_generator.gd")
const ManagedRoomTopologyScript = preload("res://scripts/world/managed_room_topology.gd")
const ManagedPlatformScene: PackedScene = preload("res://scenes/solid_platform.tscn")
const DISCRETE_INPUT_ACTIONS: Array[StringName] = [
	&"launch_ball",
	&"parry",
	&"dash",
	&"jump",
	&"interact",
]

enum UpgradeFlowState {
	INACTIVE,
	VICTORY_PENDING,
	OFFER_OPEN,
	SELECTED,
	EXIT_RELEASED,
	CANCELLED,
	COMPLETED,
}

@export var authored_layout_enabled: bool = false
@export var room_layout_seed: int = 0
@export_file("*.tscn") var next_room_scene_path: String = "res://scenes/second_room.tscn"
@export var room_title: String = "SALA 01"
@export var reward_enabled: bool = true
@export_range(0.0, 2.0, 0.01) var post_upgrade_input_guard_seconds: float = 0.25
@export var room_title_label_path: NodePath = NodePath("CombatRoom/HUD/RoomLabel")
@export var build_status_label_path: NodePath = NodePath("CombatRoom/HUD/BuildLabel")
@export var player_spawn_marker_path: NodePath = NodePath("PlayerSpawnMarker")

@onready var player: Player = $Player
@onready var combat_room: CombatRoom = $CombatRoom
@onready var exit_door: Node = get_node_or_null("ExitDoor")

var _transition_in_progress: bool = false
var _door_request_pending: bool = false
var _transition_token: int = 0
var _transition_source_scene: Node
var _transition_player: Player
var _transition_overlay: Node
var _transition_original_disable_mode: int = 0
var _transition_original_process_mode: int = Node.PROCESS_MODE_INHERIT
var _transition_player_locked: bool = false
var _standalone_swap_committed: bool = false
var _local_reward_resolved: bool = false
var _upgrade_flow_state: UpgradeFlowState = UpgradeFlowState.INACTIVE
var _death_pending: bool = false
var _post_flush_resolution_queued: bool = false
var _upgrade_offer: UpgradeOffer
var _offered_upgrade_ids: Array[StringName] = []
var _owned_offer_pause: bool = false
var _guard_active: bool = false
var _guard_waiting_for_release: bool = false
var _guard_quiet_remaining: float = 0.0
var run_build: RunBuild = RunBuild.new()
var _run_controller_managed: bool = false
var _managed_room_descriptor: Dictionary = {}
var _managed_topology: RefCounted
var _managed_transition_direction := Vector2i.RIGHT
var _managed_run_build: RunBuild
var _run_progression_notified: bool = false
var _authored_layout_prepared: bool = false
var _authored_layout_valid: bool = false
var _authored_layout_error: String = ""
var _suppress_authored_layout_errors: bool = false
var _authored_target_position: Vector2 = Vector2.ZERO
var _authored_target_node: Node
var _authored_target_support: SolidPlatform
var _authored_target_support_path: NodePath = NodePath("")
var _authored_target_patrol_enabled: bool = false
var _authored_target_patrol_min_x: float = 0.0
var _authored_target_patrol_max_x: float = 0.0
var _authored_world_obstacles: Array[Dictionary] = []
var _prepared_room_layout_seed: int = 0
var _prepared_platform_rects: Dictionary = {}
var _door_unlock_pending: bool = false

var _upgrade_definitions: Array[UpgradeDefinitionResource] = [
	IMPACTO_REFORCADO_DEFINITION,
	MOTOR_ACELERADO_DEFINITION,
	CARGA_REATIVA_DEFINITION,
]

func _enter_tree() -> void:
	if authored_layout_enabled:
		prepare_authored_layout()

func prepare_authored_layout() -> bool:
	if not authored_layout_enabled:
		return true
	if _authored_layout_prepared:
		return _authored_layout_valid

	_authored_layout_prepared = true
	_authored_layout_valid = false
	_authored_layout_error = ""
	_authored_target_position = Vector2.ZERO
	_authored_target_node = null
	_authored_target_support = null
	_authored_target_support_path = NodePath("")
	_authored_target_patrol_enabled = false
	_authored_target_patrol_min_x = 0.0
	_authored_target_patrol_max_x = 0.0
	_authored_world_obstacles.clear()
	_prepared_platform_rects.clear()

	var generation: Dictionary
	var authored_platform_names: Array[StringName] = []
	if _run_controller_managed:
		if _managed_room_descriptor.is_empty():
			return _fail_authored_layout("descritor gerenciado ausente")
		var family := StringName(_managed_room_descriptor.get("family", &""))
		var entry_dir: Vector2i = _managed_room_descriptor.get("entry_dir", Vector2i.ZERO)
		var exit_dir: Vector2i = _managed_room_descriptor.get("exit_dir", Vector2i.ZERO)
		var entry_offset := float(_managed_room_descriptor.get("entry_offset", -1.0))
		var exit_offset := float(_managed_room_descriptor.get("exit_offset", -1.0))
		generation = RoomLayoutGenerator.generate_managed_layout(
			family, room_layout_seed, entry_dir, exit_dir, entry_offset, exit_offset
		)
		if not bool(generation.get("valid", false)):
			return _fail_authored_layout("família %s: gerador recusou a geometria ou a orientação" % String(family))
		var generated_entries: Array = generation.get("platforms", [])
		if not _ensure_managed_platform_nodes(generated_entries.size()):
			return _fail_authored_layout("não foi possível preparar a contagem de apoios gerenciados")
		var managed_set: Dictionary = _detect_authored_platform_set()
		if not bool(managed_set.get("valid", false)):
			return _fail_authored_layout(String(managed_set.get("error", "fixture gerenciada inválida")))
		authored_platform_names = managed_set.get("names", [])
		_managed_topology = ManagedRoomTopologyScript.new()
		var topology_result: Dictionary = _managed_topology.call("configure", self, _managed_room_descriptor)
		if not bool(topology_result.get("valid", false)):
			return _fail_authored_layout(String(topology_result.get("error", "limites gerenciados inválidos")))
		if not _configure_managed_spawn(entry_dir, entry_offset):
			return _fail_authored_layout("spawn incompatível com a porta de entrada")
	else:
		var platform_set_result: Dictionary = _detect_authored_platform_set()
		if not bool(platform_set_result.get("valid", false)):
			return _fail_authored_layout(String(platform_set_result.get("error", "fixture de plataformas inválida")))
		authored_platform_names = platform_set_result.get("names", [])
		generation = RoomLayoutGenerator.generate_layout(
			authored_platform_names.size(),
			room_layout_seed,
			_get_player_spawn_x_for_layout()
		)
	_prepared_room_layout_seed = int(generation.get("seed", 0))
	if not bool(generation.get("valid", false)):
		return _fail_authored_layout(String(generation.get("error", "gerador de layout recusou a sala")))
	var generated_platforms: Array[Dictionary] = generation.get("platforms", [])
	if generated_platforms.size() != authored_platform_names.size():
		return _fail_authored_layout("gerador retornou quantidade diferente de plataformas")
	var target := get_node_or_null("TrainingTarget") as TrainingTarget
	if target == null or not target.authored_support_enabled:
		return _fail_authored_layout("TrainingTarget não está no modo de suporte autoral")
	var primary_index := int(generation.get("primary_index", -1))
	var fallback_index := int(generation.get("fallback_index", -1))
	if primary_index < 0 or primary_index >= authored_platform_names.size() or fallback_index < 0 or fallback_index >= authored_platform_names.size():
		return _fail_authored_layout("gerador não definiu suportes primário e fallback")
	target.fixed_support_path = NodePath("../" + String(authored_platform_names[primary_index]))
	target.fallback_support_path = NodePath("../" + String(authored_platform_names[fallback_index]))
	for platform_index in authored_platform_names.size():
		var platform_name: StringName = authored_platform_names[platform_index]
		var platform := get_node_or_null(NodePath(String(platform_name))) as SolidPlatform
		if platform == null:
			return _fail_authored_layout("plataforma ausente ou de tipo incorreto: %s" % String(platform_name))
		var generated: Dictionary = generated_platforms[platform_index]
		var generated_size: Vector2 = generated.get("size", Vector2.ZERO)
		var generated_position: Vector2 = generated.get("position", Vector2.ZERO)
		platform.randomize_position = false
		platform.randomize_width = false
		platform.size = generated_size
		platform.position = generated_position
		var platform_result: Dictionary = _validate_authored_platform(
			platform,
			generated_position,
			generated_size
		)
		if not bool(platform_result.get("valid", false)):
			return _fail_authored_layout(String(platform_result.get("error", "plataforma inválida")))
		_prepared_platform_rects[platform_name] = platform_result.get("rect", Rect2())

	if _run_controller_managed:
		_suppress_authored_layout_errors = true
		var candidate_route_valid := _validate_managed_generated_route(authored_platform_names, generation)
		_suppress_authored_layout_errors = false
		if not candidate_route_valid:
			var candidate_error := _authored_layout_error
			_authored_layout_error = ""
			_prepared_platform_rects.clear()
			var family := StringName(_managed_room_descriptor.get("family", &""))
			var entry_dir: Vector2i = _managed_room_descriptor.get("entry_dir", Vector2i.ZERO)
			var exit_dir: Vector2i = _managed_room_descriptor.get("exit_dir", Vector2i.ZERO)
			var entry_offset := float(_managed_room_descriptor.get("entry_offset", -1.0))
			var exit_offset := float(_managed_room_descriptor.get("exit_offset", -1.0))
			var fallback_generation := RoomLayoutGenerator.generate_managed_layout(
				family, room_layout_seed, entry_dir, exit_dir, entry_offset, exit_offset, true
			)
			if not bool(fallback_generation.get("valid", false)):
				return _fail_authored_layout("layout candidato inválido (%s); fallback da família %s: %s" % [
					candidate_error,
					String(family),
					String(fallback_generation.get("error", "geometria recusada")),
				])
			var fallback_platforms: Array[Dictionary] = fallback_generation.get("platforms", [])
			if fallback_platforms.size() != authored_platform_names.size():
				return _fail_authored_layout("fallback da família %s diverge da quantidade de apoios" % String(family))
			var fallback_primary := int(fallback_generation.get("primary_index", -1))
			var canonical_fallback_index := int(fallback_generation.get("fallback_index", -1))
			if fallback_primary < 0 or fallback_primary >= authored_platform_names.size() \
				or canonical_fallback_index < 0 or canonical_fallback_index >= authored_platform_names.size():
				return _fail_authored_layout("fallback da família %s não definiu suportes de Tranca-Lata" % String(family))
			target.fixed_support_path = NodePath("../" + String(authored_platform_names[fallback_primary]))
			target.fallback_support_path = NodePath("../" + String(authored_platform_names[canonical_fallback_index]))
			for platform_index in authored_platform_names.size():
				var platform_name: StringName = authored_platform_names[platform_index]
				var platform := get_node_or_null(NodePath(String(platform_name))) as SolidPlatform
				if platform == null:
					return _fail_authored_layout("plataforma ausente durante fallback: %s" % String(platform_name))
				var generated: Dictionary = fallback_platforms[platform_index]
				var generated_size: Vector2 = generated.get("size", Vector2.ZERO)
				var generated_position: Vector2 = generated.get("position", Vector2.ZERO)
				platform.size = generated_size
				platform.position = generated_position
				var platform_result := _validate_authored_platform(platform, generated_position, generated_size)
				if not bool(platform_result.get("valid", false)):
					return _fail_authored_layout("fallback da família %s: %s" % [
						String(family),
						String(platform_result.get("error", "plataforma inválida")),
					])
				_prepared_platform_rects[platform_name] = platform_result.get("rect", Rect2())
			_suppress_authored_layout_errors = true
			var fallback_route_valid := _validate_managed_generated_route(authored_platform_names, fallback_generation)
			var fallback_error := _authored_layout_error
			_suppress_authored_layout_errors = false
			if not fallback_route_valid:
				return _fail_authored_layout("layout candidato da família %s falhou (%s); fallback canônico também falhou (%s)" % [
					String(family),
					candidate_error,
					fallback_error,
				])
			generation = fallback_generation
			_authored_layout_error = ""
		if not _validate_managed_room_boundaries():
			return false
	elif not _validate_generated_route(authored_platform_names):
		return false
	elif not _validate_authored_room_boundaries():
		return false
	if not _collect_authored_world_obstacles():
		return false
	if not _validate_authored_spawns_and_patrol():
		return false
	if not _validate_authored_target(_prepared_platform_rects):
		return false

	_authored_layout_valid = true
	return true

func is_authored_layout_valid() -> bool:
	return not authored_layout_enabled or (_authored_layout_prepared and _authored_layout_valid)

func get_authored_layout_error() -> String:
	return _authored_layout_error

func get_prepared_authored_target_position(target: Node) -> Variant:
	if not authored_layout_enabled or not _authored_layout_prepared or not _authored_layout_valid or target != _authored_target_node:
		return null
	return _authored_target_position

func get_prepared_authored_target_binding(target: Node) -> Dictionary:
	if not authored_layout_enabled or not _authored_layout_prepared or not _authored_layout_valid or target != _authored_target_node:
		return {}
	return {
		"position": _authored_target_position,
		"support": _authored_target_support,
		"support_path": _authored_target_support_path,
		"patrol_enabled": _authored_target_patrol_enabled,
		"patrol_min_x": _authored_target_patrol_min_x,
		"patrol_max_x": _authored_target_patrol_max_x,
		"edge_margin": AUTHORED_EDGE_MARGIN,
	}

func get_prepared_room_layout_seed() -> int:
	return _prepared_room_layout_seed

func _fail_authored_layout(message: String) -> bool:
	_authored_layout_valid = false
	_authored_layout_error = message
	if not _suppress_authored_layout_errors:
		push_error("Main: layout autoral inválido — " + message)
	return false

func _detect_authored_platform_set() -> Dictionary:
	var present_names: Array[StringName] = []
	for child in get_children():
		var child_name: StringName = StringName(child.name)
		if child_name == &"Floor":
			continue
		var platform := child as SolidPlatform
		var known_platform: bool = KNOWN_AUTHORED_PLATFORM_NAMES.has(child_name)
		if not known_platform:
			if platform != null:
				return {"valid": false, "error": "plataforma autoral desconhecida: %s" % String(child_name)}
			continue
		if platform == null:
			return {"valid": false, "error": "nó de plataforma tem tipo incorreto: %s" % String(child_name)}
		present_names.append(child_name)

	if present_names.size() < RoomLayoutGenerator.MIN_PLATFORM_COUNT \
		or present_names.size() > RoomLayoutGenerator.MAX_PLATFORM_COUNT:
		return {"valid": false, "error": "quantidade de plataformas fora do intervalo suportado (2..5)"}
	return {"valid": true, "names": present_names}

func _ensure_managed_platform_nodes(required_count: int) -> bool:
	if required_count < RoomLayoutGenerator.MIN_PLATFORM_COUNT or required_count > RoomLayoutGenerator.MAX_PLATFORM_COUNT:
		return false
	var platforms: Array[SolidPlatform] = []
	for child in get_children():
		var platform := child as SolidPlatform
		if platform != null and platform.name != &"Floor":
			platforms.append(platform)
	while platforms.size() < required_count:
		var platform := ManagedPlatformScene.instantiate() as SolidPlatform
		if platform == null:
			return false
		var extra_index := platforms.size() - 3
		if extra_index < 0 or extra_index >= 2:
			platform.free()
			return false
		platform.name = [&"PlatformD", &"PlatformE"][extra_index]
		platform.randomize_position = false
		platform.randomize_width = false
		add_child(platform)
		platforms.append(platform)
	if platforms.size() > required_count:
		for index in range(platforms.size() - 1, required_count - 1, -1):
			var extra := platforms[index]
			if extra.name != &"PlatformD" and extra.name != &"PlatformE":
				return false
			remove_child(extra)
			extra.free()
	return platforms.size() == required_count

func _configure_managed_spawn(entry_dir: Vector2i, entry_offset: float) -> bool:
	var marker := get_node_or_null(player_spawn_marker_path) as Marker2D
	if marker == null:
		return false
	if entry_dir == Vector2i(-1, 0):
		marker.position = Vector2(160.0, 560.0)
	elif entry_dir == Vector2i(1, 0):
		marker.position = Vector2(992.0, 560.0)
	elif entry_dir == Vector2i(0, 1):
		marker.position = Vector2(entry_offset, 560.0)
	elif entry_dir == Vector2i(0, -1):
		marker.position = Vector2(entry_offset, 160.0)
	else:
		return false
	_managed_transition_direction = _managed_room_descriptor.get("exit_dir", Vector2i.RIGHT)
	return true

func _validate_managed_room_boundaries() -> bool:
	var floor_platform := get_node_or_null("Floor") as SolidPlatform
	var world := get_node_or_null("WorldCollision") as StaticBody2D
	if floor_platform == null or world == null or _managed_topology == null:
		return _fail_authored_layout("limites principais da sala gerenciada ausentes")
	if floor_platform.position.distance_to(Vector2(576.0, 604.0)) > 0.01 \
		or floor_platform.size.distance_to(Vector2(1152.0, 88.0)) > 0.01:
		return _fail_authored_layout("Floor gerenciado precisa permanecer em 1152×88 na posição 576×604")
	var floor_shape_count := 0
	var floor_collision := floor_platform.get_node_or_null("CollisionShape2D") as CollisionShape2D
	for child in floor_platform.get_children():
		if child is CollisionShape2D:
			floor_shape_count += 1
	if floor_shape_count != 1 or floor_collision == null or floor_collision.disabled:
		return _fail_authored_layout("Floor deve conservar exatamente um shape ativo durante o combate")
	var floor_rect := floor_collision.shape as RectangleShape2D
	if floor_rect == null or floor_rect.size.distance_to(Vector2(1152.0, 88.0)) > 0.01:
		return _fail_authored_layout("shape único de Floor gerenciado tem dimensão incompatível")
	if absf(world.rotation) > 0.001 or not world.scale.is_equal_approx(Vector2.ONE):
		return _fail_authored_layout("WorldCollision gerenciado tem transform incompatível")
	var exit_dir: Vector2i = _managed_room_descriptor.get("exit_dir", Vector2i.ZERO)
	var offset := float(_managed_room_descriptor.get("exit_offset", -1.0))
	var gate := _managed_topology.call("get_exit_gate") as CollisionShape2D
	if gate == null or gate.disabled:
		return _fail_authored_layout("gate de saída gerenciado ausente ou aberto antes do clear")
	var expected_position := Vector2(1120.0, 496.0)
	var expected_size := Vector2(64.0, 128.0)
	if exit_dir == Vector2i(-1, 0):
		expected_position = Vector2(32.0, 496.0)
	elif exit_dir == Vector2i(0, -1):
		expected_position = Vector2(offset, 16.0)
		expected_size = Vector2(256.0, 96.0)
	elif exit_dir == Vector2i(0, 1):
		expected_position = Vector2(offset, 604.0)
		expected_size = Vector2(256.0, 88.0)
	var gate_shape := gate.shape as RectangleShape2D
	if gate.position.distance_to(expected_position) > 0.01 or gate_shape == null \
		or gate_shape.size.distance_to(expected_size) > 0.01:
		return _fail_authored_layout("dimensão ou posição do gate não corresponde ao slot descrito")
	var topology_contract: Dictionary = _managed_topology.call("validate_contract")
	if not bool(topology_contract.get("valid", false)):
		return _fail_authored_layout(String(topology_contract.get("error", "contrato de colisões gerenciadas inválido")))
	return true

func _validate_managed_generated_route(platform_names: Array[StringName], generation: Dictionary) -> bool:
	var platform_data: Array = generation.get("platforms", [])
	if platform_data.size() != platform_names.size():
		return _fail_authored_layout("descritor gerenciado e nós de plataforma divergem")
	var family := StringName(_managed_room_descriptor.get("family", &""))
	var entry_dir: Vector2i = _managed_room_descriptor.get("entry_dir", Vector2i.ZERO)
	var exit_dir: Vector2i = _managed_room_descriptor.get("exit_dir", Vector2i.ZERO)
	if entry_dir == Vector2i.ZERO or exit_dir == Vector2i.ZERO or entry_dir == exit_dir:
		return _fail_authored_layout("direções de entrada e saída gerenciadas são inválidas")
	var rects: Array[Rect2] = []
	for name in platform_names:
		if not _prepared_platform_rects.has(name):
			return _fail_authored_layout("retângulo gerenciado ausente para %s" % String(name))
		rects.append(_prepared_platform_rects[name])
	for first_index in rects.size():
		for second_index in range(first_index + 1, rects.size()):
			if _positive_overlap_area(rects[first_index], rects[second_index]) > AUTHORED_OVERLAP_AREA_LIMIT:
				return _fail_authored_layout("apoios gerenciados se sobrepõem")
	var primary_index := int(generation.get("primary_index", -1))
	if primary_index < 0 or primary_index >= rects.size():
		return _fail_authored_layout("suporte primário gerenciado inválido")
	var reachable := _managed_reachable_supports(rects, entry_dir, exit_dir)
	if not reachable.has(primary_index):
		return _fail_authored_layout("suporte primário não tem arco ou queda segura a partir do spawn")
	if exit_dir == Vector2i(0, -1):
		var final_index := rects.size() - 1
		if not reachable.has(final_index):
			return _fail_authored_layout("apoio final da saída superior não é alcançável com o gate liberado")
		if not _managed_can_reach_top_sensor(rects[final_index], float(_managed_room_descriptor.get("exit_offset", -1.0))):
			return _fail_authored_layout("último arco não cruza o sensor superior dentro da abertura")
	elif exit_dir == Vector2i(0, 1):
		var down_floor_rect := Rect2(Vector2(0.0, 560.0), Vector2(1152.0, 88.0))
		var down_reaches_floor := false
		for support_index in reachable:
			if _managed_can_drop_between(rects[support_index], down_floor_rect, rects, support_index):
				down_reaches_floor = true
				break
		if not down_reaches_floor:
			return _fail_authored_layout("saída inferior não tem rota segura até o piso")
		var offset := float(_managed_room_descriptor.get("exit_offset", -1.0))
		if offset != 248.0 and offset != 904.0:
			return _fail_authored_layout("saída inferior fora do slot canônico")
		if not _managed_can_reach_bottom_sensor(offset):
			return _fail_authored_layout("queda inferior não cruza o sensor dentro da abertura")
	elif exit_dir.x != 0:
		if float(_managed_room_descriptor.get("exit_offset", -1.0)) != 496.0:
			return _fail_authored_layout("saída lateral fora do centro vertical canônico")
	if entry_dir == Vector2i(0, -1):
		var entry_floor_rect := Rect2(Vector2(0.0, 560.0), Vector2(1152.0, 88.0))
		var entry_reaches_floor := false
		for support_index in reachable:
			if _managed_can_drop_between(rects[support_index], entry_floor_rect, rects, support_index):
				entry_reaches_floor = true
				break
		if not entry_reaches_floor:
			return _fail_authored_layout("spawn superior não tem rota de descida segura ao piso")
	return true

func _managed_reachable_supports(rects: Array[Rect2], entry_dir: Vector2i, exit_dir: Vector2i) -> Array[int]:
	var reachable: Array[int] = []
	var frontier: Array[int] = []
	if entry_dir == Vector2i(0, -1):
		frontier.append(rects.size() - 1)
	else:
		var floor_rect := Rect2(Vector2(0.0, 560.0), Vector2(1152.0, 88.0))
		for index in rects.size():
			if _managed_can_jump_between(floor_rect, rects[index], rects, -1, false):
				frontier.append(index)
	while not frontier.is_empty():
		var source_index: int = frontier.pop_front()
		if reachable.has(source_index):
			continue
		reachable.append(source_index)
		for target_index in rects.size():
			if target_index == source_index or reachable.has(target_index) or frontier.has(target_index):
				continue
			var can_move := _managed_can_jump_between(rects[source_index], rects[target_index], rects, source_index, false) \
				or _managed_can_drop_between(rects[source_index], rects[target_index], rects, source_index)
			if exit_dir == Vector2i(0, -1) and target_index == rects.size() - 1:
				can_move = _managed_can_jump_between(rects[source_index], rects[target_index], rects, source_index, true)
			if can_move:
				frontier.append(target_index)
	return reachable

func _managed_can_jump_between(source: Rect2, target: Rect2, rects: Array[Rect2], source_index: int, top_open: bool) -> bool:
	var required_rise := source.position.y - target.position.y
	if required_rise < 0.0 or required_rise > 128.0:
		return false
	var movement := _managed_movement_values()
	var max_speed := float(movement.get("move_speed", 260.0))
	var acceleration := float(movement.get("acceleration", 1600.0))
	var deceleration := float(movement.get("deceleration", 2200.0))
	var gravity := float(movement.get("gravity", 1600.0))
	var jump_velocity := float(movement.get("jump_velocity", 640.0))
	var max_fall_speed := float(movement.get("max_fall_speed", 900.0))
	var dt := 1.0 / float(ProjectSettings.get_setting("physics/common/physics_ticks_per_second", 60))
	var launch_min := source.position.x + 14.0
	var launch_max := source.end.x - 14.0
	if launch_max < launch_min:
		return false
	var launch_points := _managed_launch_points(source, target, launch_min, launch_max)
	var speed_candidates: Array[float] = [0.0, -100.0, 100.0, -180.0, 180.0, -260.0, 260.0]
	for launch_x in launch_points:
		var approach_axis := 0.0
		if launch_x < target.position.x + 22.0:
			approach_axis = 1.0
		elif launch_x > target.end.x - 22.0:
			approach_axis = -1.0
		for initial_speed in speed_candidates:
			if not is_zero_approx(initial_speed) and signf(initial_speed) != approach_axis:
				continue
			var runway := initial_speed * initial_speed / maxf(2.0 * acceleration, 1.0)
			if initial_speed > 0.0 and launch_x - launch_min + 0.01 < runway:
				continue
			if initial_speed < 0.0 and launch_max - launch_x + 0.01 < runway:
				continue
			var root := Vector2(launch_x, source.position.y)
			var vx := initial_speed
			var vy := 0.0
			var candidate_blocked := false
			for frame in 120:
				vy = minf(vy + gravity * dt, max_fall_speed)
				if frame == 0:
					vy = -jump_velocity
				var horizontal_rate := acceleration if not is_zero_approx(approach_axis) else deceleration
				vx = move_toward(vx, approach_axis * max_speed, horizontal_rate * dt)
				var next := root + Vector2(vx, vy) * dt
				var body := Rect2(Vector2(next.x - 14.0, next.y - 76.0), Vector2(28.0, 76.0))
				if body.position.x < 64.0 or body.end.x > 1088.0:
					candidate_blocked = true
					break
				var descending_landing := vy > 0.0 and root.y <= target.position.y and next.y >= target.position.y
				if descending_landing:
					var crossing_fraction := clampf((target.position.y - root.y) / (next.y - root.y), 0.0, 1.0)
					var landing_x := lerpf(root.x, next.x, crossing_fraction)
					if landing_x >= target.position.x + 22.0 and landing_x <= target.end.x - 22.0:
						return true
				for blocker_index in rects.size():
					if blocker_index == source_index:
						continue
					if _positive_overlap_area(body, rects[blocker_index]) <= 0.01:
						continue
					# Plataformas sólidas também bloqueiam subida e colisões laterais.
					# Só a aterrissagem descendente no topo do alvo é uma rota válida.
					candidate_blocked = true
					break
				if candidate_blocked:
					break
				if body.position.y < 64.0 and body.end.y > -32.0:
					var portal_x := float(_managed_room_descriptor.get("exit_offset", -1.0))
					var inside_open_hatch := top_open \
						and _managed_room_descriptor.get("exit_dir", Vector2i.ZERO) == Vector2i(0, -1) \
						and body.position.x >= portal_x - 128.0 \
						and body.end.x <= portal_x + 128.0
					if not inside_open_hatch:
						candidate_blocked = true
						break
				root = next
				if root.y > source.position.y + 180.0:
					break
			# Um bloqueio invalida apenas este lançamento; os demais são testados.
			if candidate_blocked:
				continue
	return false

func _managed_can_drop_between(source: Rect2, target: Rect2, rects: Array[Rect2], source_index: int) -> bool:
	if target.position.y <= source.position.y or target.position.y - source.position.y > 400.0:
		return false
	var movement := _managed_movement_values()
	var max_speed := float(movement.get("move_speed", 260.0))
	var acceleration := float(movement.get("acceleration", 1600.0))
	var gravity := float(movement.get("gravity", 1600.0))
	var max_fall_speed := float(movement.get("max_fall_speed", 900.0))
	var dt := 1.0 / float(ProjectSettings.get_setting("physics/common/physics_ticks_per_second", 60))
	var launch_min := source.position.x - 14.0
	var launch_max := source.end.x + 14.0
	var launch_points := _managed_launch_points(source, target, launch_min, launch_max)
	for launch_x in launch_points:
		for direction in [-1.0, 1.0]:
			var root := Vector2(launch_x, source.position.y)
			var vx := 0.0
			var vertical_speed := 0.0
			for _frame in 120:
				var previous := root
				vx = move_toward(vx, direction * max_speed, acceleration * dt)
				root.x += vx * dt
				var still_supported := root.x + 14.0 > source.position.x and root.x - 14.0 < source.end.x
				if still_supported:
					root.y = source.position.y
					vertical_speed = 0.0
				else:
					vertical_speed = minf(vertical_speed + gravity * dt, max_fall_speed)
					root.y += vertical_speed * dt
				var body := Rect2(Vector2(root.x - 14.0, root.y - 76.0), Vector2(28.0, 76.0))
				if body.position.x < 64.0 or body.end.x > 1088.0:
					break
				var descending_landing := not still_supported and previous.y <= target.position.y and root.y >= target.position.y
				if descending_landing:
					var crossing_fraction := clampf((target.position.y - previous.y) / (root.y - previous.y), 0.0, 1.0)
					var landing_x := lerpf(previous.x, root.x, crossing_fraction)
					if landing_x >= target.position.x + 22.0 and landing_x <= target.end.x - 22.0:
						return true
				var blocked := false
				for blocker_index in rects.size():
					if blocker_index == source_index:
						continue
					if _positive_overlap_area(body, rects[blocker_index]) > 0.01:
						blocked = true
						break
				if blocked:
					break
				if root.y > target.position.y + 80.0:
					break
	return false

func _managed_launch_points(source: Rect2, target: Rect2, launch_min: float, launch_max: float) -> Array[float]:
	var points: Array[float] = []
	var candidates: Array[float] = [
		launch_min + 8.0,
		launch_min + 32.0,
		source.get_center().x,
		launch_max - 32.0,
		launch_max - 8.0,
		target.position.x - 64.0,
		target.position.x - 32.0,
		target.position.x + 22.0,
		target.get_center().x,
		target.end.x - 22.0,
		target.end.x + 32.0,
		target.end.x + 64.0,
	]
	for candidate in candidates:
		var point := clampf(snappedf(candidate, 8.0), launch_min, launch_max)
		if not points.has(point):
			points.append(point)
	return points

func _managed_movement_values() -> Dictionary:
	var config := MovementConfig.new()
	var player_node := get_node_or_null("Player") as Player
	if player_node != null and player_node.movement_config != null:
		config = player_node.movement_config
	return {
		"move_speed": config.move_speed,
		"acceleration": config.acceleration,
		"deceleration": config.deceleration,
		"gravity": config.gravity,
		"jump_velocity": config.jump_velocity,
		"max_fall_speed": config.max_fall_speed,
	}
func _managed_can_reach_bottom_sensor(portal_x: float) -> bool:
	if portal_x != 248.0 and portal_x != 904.0:
		return false
	var movement := _managed_movement_values()
	var gravity := float(movement.get("gravity", 1600.0))
	var max_fall_speed := float(movement.get("max_fall_speed", 900.0))
	var dt := 1.0 / float(ProjectSettings.get_setting("physics/common/physics_ticks_per_second", 60))
	var root_y := 560.0
	var vertical_speed := 0.0
	for _frame in 120:
		vertical_speed = minf(vertical_speed + gravity * dt, max_fall_speed)
		var previous_center_y := root_y - 38.0
		root_y += vertical_speed * dt
		var center_y := root_y - 38.0
		if previous_center_y < 604.0 and center_y >= 604.0:
			var body_left := portal_x - 14.0
			var body_right := portal_x + 14.0
			return body_left >= portal_x - 128.0 \
				and body_right <= portal_x + 128.0 \
				and root_y <= 660.0
	return false

func _managed_can_reach_top_sensor(source: Rect2, portal_x: float) -> bool:
	if absf(source.get_center().x - portal_x) > 0.01 \
		or absf(source.position.y - 160.0) > 0.01 \
		or _managed_room_descriptor.get("exit_dir", Vector2i.ZERO) != Vector2i(0, -1):
		return false
	var movement := _managed_movement_values()
	var gravity := float(movement.get("gravity", 1600.0))
	var jump_velocity := float(movement.get("jump_velocity", 640.0))
	var max_fall_speed := float(movement.get("max_fall_speed", 900.0))
	var dt := 1.0 / float(ProjectSettings.get_setting("physics/common/physics_ticks_per_second", 60))
	var root_y := source.position.y
	var vertical_speed := 0.0
	for frame in 30:
		vertical_speed = minf(vertical_speed + gravity * dt, max_fall_speed)
		if frame == 0:
			vertical_speed = -jump_velocity
		var previous_center_y := root_y - 38.0
		root_y += vertical_speed * dt
		var center_y := root_y - 38.0
		var body_left := portal_x - 14.0
		var body_right := portal_x + 14.0
		if previous_center_y > 32.0 and center_y <= 32.0:
			var head_y := root_y - 76.0
			return head_y > -48.0 \
				and body_left >= portal_x - 128.0 \
				and body_right <= portal_x + 128.0 \
				and body_left >= 64.0 and body_right <= 1088.0
	return false
func _get_player_spawn_x_for_layout() -> float:
	var spawn_marker := get_node_or_null(player_spawn_marker_path) as Marker2D
	return spawn_marker.position.x if spawn_marker != null else FALLBACK_PLAYER_SPAWN.x

func _validate_generated_route(platform_names: Array[StringName]) -> bool:
	var previous_rect := Rect2()
	for index in platform_names.size():
		var platform_name: StringName = platform_names[index]
		if not _prepared_platform_rects.has(platform_name):
			return _fail_authored_layout("retângulo físico ausente para %s" % String(platform_name))
		var rect: Rect2 = _prepared_platform_rects[platform_name]
		if rect.size.y != 24.0 or rect.size.x < 104.0 or rect.size.x > 216.0:
			return _fail_authored_layout("dimensão física inválida em %s" % String(platform_name))
		if rect.position.x < 64.0 or rect.end.x > 980.0 or fposmod(rect.position.x, 8.0) > 0.01 or fposmod(rect.size.x, 8.0) > 0.01:
			return _fail_authored_layout("%s ultrapassa a faixa de geração" % String(platform_name))
		if rect.position.y < 376.0 or rect.position.y > 440.0:
			return _fail_authored_layout("%s está fora dos limites verticais" % String(platform_name))
		if rect.end.y > 464.0 or 560.0 - rect.end.y < 96.0:
			return _fail_authored_layout("%s reduz a folga livre do piso abaixo de 96 px" % String(platform_name))
		if index == 0:
			if absf(rect.position.y - 440.0) > 0.01:
				return _fail_authored_layout("a primeira plataforma deve ter topo y=440")
			var spawn_x := _get_player_spawn_x_for_layout()
			if rect.position.x < 208.0 or rect.position.x > 256.0 or rect.position.x - (spawn_x + 14.0) < 24.0:
				return _fail_authored_layout("a primeira plataforma invade a margem do spawn")
		else:
			var gap := rect.position.x - previous_rect.end.x
			var rise := previous_rect.position.y - rect.position.y
			if gap < 56.0 or gap > 96.0 or rise < 0.0 or rise > 64.0:
				return _fail_authored_layout("vão ou desnível inválido entre plataformas")
			if _positive_overlap_area(rect, previous_rect) > AUTHORED_OVERLAP_AREA_LIMIT:
				return _fail_authored_layout("plataformas adjacentes se sobrepõem")
		previous_rect = rect
	return true

func _validate_authored_room_boundaries() -> bool:
	var floor_platform := get_node_or_null("Floor") as SolidPlatform
	if floor_platform == null:
		return _fail_authored_layout("Floor ausente ou de tipo incorreto")
	if floor_platform.position.distance_to(Vector2(576.0, 604.0)) > 0.01:
		return _fail_authored_layout("Floor fora da posição 576×604")
	if floor_platform.size.distance_to(Vector2(1152.0, 88.0)) > 0.01:
		return _fail_authored_layout("Floor deve medir 1152×88")
	if absf(floor_platform.rotation) > 0.001 or not floor_platform.scale.is_equal_approx(Vector2.ONE):
		return _fail_authored_layout("Floor tem transform incompatível")
	var floor_collision := floor_platform.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if floor_collision == null or floor_collision.disabled:
		return _fail_authored_layout("Floor sem CollisionShape2D ativo")
	var floor_rectangle := floor_collision.shape as RectangleShape2D
	if floor_rectangle == null or floor_rectangle.size.distance_to(Vector2(1152.0, 88.0)) > 0.01:
		return _fail_authored_layout("shape físico de Floor deve medir 1152×88")
	if floor_collision.position.length() > 0.01 or absf(floor_collision.rotation) > 0.001 or not floor_collision.scale.is_equal_approx(Vector2.ONE):
		return _fail_authored_layout("shape físico de Floor está deslocado")

	var world_collision := get_node_or_null("WorldCollision") as StaticBody2D
	if world_collision == null:
		return _fail_authored_layout("WorldCollision ausente ou de tipo incorreto")
	if world_collision.position.length() > 0.01 or absf(world_collision.rotation) > 0.001 or not world_collision.scale.is_equal_approx(Vector2.ONE):
		return _fail_authored_layout("WorldCollision tem transform incompatível")

	var boundary_names: Array[StringName] = [
		&"LeftWall", &"RightWallUpper", &"RightWallLower", &"ExitGate", &"RightOuterGuard", &"Ceiling",
	]
	var boundary_positions: Array[Vector2] = [
		Vector2(32.0, 324.0), Vector2(1120.0, 216.0), Vector2(1120.0, 604.0),
		Vector2(1120.0, 496.0), Vector2(1156.0, 324.0), Vector2(576.0, -16.0),
	]
	var boundary_sizes: Array[Vector2] = [
		Vector2(64.0, 648.0), Vector2(64.0, 432.0), Vector2(64.0, 88.0),
		Vector2(64.0, 128.0), Vector2(8.0, 648.0), Vector2(1152.0, 32.0),
	]
	for boundary_index in boundary_names.size():
		var boundary := world_collision.get_node_or_null(NodePath(String(boundary_names[boundary_index]))) as CollisionShape2D
		if boundary == null:
			return _fail_authored_layout("shape de limite ausente: %s" % String(boundary_names[boundary_index]))
		if boundary_names[boundary_index] != &"ExitGate" and boundary.disabled:
			return _fail_authored_layout("shape de limite desativado: %s" % String(boundary_names[boundary_index]))
		if boundary.position.distance_to(boundary_positions[boundary_index]) > 0.01:
			return _fail_authored_layout("%s fora da posição autoral" % String(boundary_names[boundary_index]))
		var rectangle := boundary.shape as RectangleShape2D
		if rectangle == null or rectangle.size.distance_to(boundary_sizes[boundary_index]) > 0.01:
			return _fail_authored_layout("%s tem shape físico incompatível" % String(boundary_names[boundary_index]))
		if absf(boundary.rotation) > 0.001 or not boundary.scale.is_equal_approx(Vector2.ONE):
			return _fail_authored_layout("%s tem transform incompatível" % String(boundary_names[boundary_index]))

	var ceiling_band := world_collision.get_node_or_null("CeilingBand") as CollisionShape2D
	if ceiling_band == null or ceiling_band.disabled:
		return _fail_authored_layout("faixa física visível do teto ausente ou desativada")
	if ceiling_band.position.distance_to(Vector2(576.0, 32.0)) > 0.01:
		return _fail_authored_layout("CeilingBand fora da faixa y=0..64")
	var ceiling_rectangle := ceiling_band.shape as RectangleShape2D
	if ceiling_rectangle == null or ceiling_rectangle.size.distance_to(Vector2(1152.0, 64.0)) > 0.01:
		return _fail_authored_layout("CeilingBand deve medir 1152×64")
	if absf(ceiling_band.rotation) > 0.001 or not ceiling_band.scale.is_equal_approx(Vector2.ONE):
		return _fail_authored_layout("CeilingBand tem transform incompatível")
	return true

func _validate_authored_platform(
	platform: SolidPlatform,
	expected_position: Vector2,
	expected_size: Vector2
) -> Dictionary:
	if platform.position.distance_to(expected_position) > 0.01:
		return {"valid": false, "error": "%s fora da posição autoral" % platform.name}
	if platform.size.distance_to(expected_size) > 0.01:
		return {"valid": false, "error": "%s fora do tamanho autoral" % platform.name}
	if platform.randomize_position or platform.randomize_width:
		return {"valid": false, "error": "%s ainda permite aleatoriedade" % platform.name}
	if absf(platform.rotation) > 0.001 or not platform.scale.is_equal_approx(Vector2.ONE):
		return {"valid": false, "error": "%s tem transform autoral incompatível" % platform.name}

	var collision := platform.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if collision == null or collision.disabled:
		return {"valid": false, "error": "%s sem CollisionShape2D ativo" % platform.name}
	var rectangle := collision.shape as RectangleShape2D
	if rectangle == null or rectangle.size.distance_to(expected_size) > 0.01:
		return {"valid": false, "error": "%s tem shape diferente do tamanho autoral" % platform.name}
	if collision.position.length() > 0.01 or absf(collision.rotation) > 0.001 or not collision.scale.is_equal_approx(Vector2.ONE):
		return {"valid": false, "error": "%s tem shape fora da origem local" % platform.name}
	return {"valid": true, "rect": Rect2(platform.position - expected_size * 0.5, expected_size)}

func _collect_authored_world_obstacles() -> bool:
	_authored_world_obstacles.clear()
	for child in get_children():
		var body := child as StaticBody2D
		if body == null or (body.collision_layer & WORLD_LAYER_BIT_MASK) == 0:
			continue
		var found_shape := false
		for shape_child in body.get_children():
			var collision := shape_child as CollisionShape2D
			if collision == null or collision.disabled:
				continue
			if collision.name == &"RightOuterGuard":
				continue
			if collision.shape == null:
				return _fail_authored_layout("shape ausente em %s" % body.name)
			found_shape = true
			_authored_world_obstacles.append({
				"owner": body,
				"rect": _collision_shape_aabb_in_main(collision),
			})
		if not found_shape:
			return _fail_authored_layout("nenhum shape ativo em World layer 1: %s" % body.name)
	return true

func _validate_authored_spawns_and_patrol() -> bool:
	var player_body := get_node_or_null("Player") as CollisionObject2D
	var player_spawn := get_node_or_null("PlayerSpawnMarker") as Marker2D
	if player_body == null or player_spawn == null:
		return _fail_authored_layout("spawn do jogador ausente")
	var player_bounds_result: Dictionary = _body_aabb(player_body, false)
	if not bool(player_bounds_result.get("valid", false)):
		return _fail_authored_layout("collider do jogador ausente")
	var player_bounds: Rect2 = player_bounds_result.get("rect", Rect2())
	var player_spawn_offset: Vector2 = player_spawn.position - player_body.position
	player_bounds = Rect2(player_bounds.position + player_spawn_offset, player_bounds.size)
	if not _validate_clear_of_world_layer(player_bounds, "spawn do jogador"):
		return false

	var worker_body := get_node_or_null("RivetWorker") as CollisionObject2D
	var patrol_area := get_node_or_null("WorkerPatrolArea") as Node2D
	if worker_body == null or patrol_area == null:
		return _fail_authored_layout("spawn ou patrulha do worker ausente")
	var worker_bounds_result: Dictionary = _body_aabb(worker_body, false)
	var worker_local_result: Dictionary = _body_aabb(worker_body, true)
	if not bool(worker_bounds_result.get("valid", false)) or not bool(worker_local_result.get("valid", false)):
		return _fail_authored_layout("collider do worker ausente")
	var worker_bounds: Rect2 = worker_bounds_result.get("rect", Rect2())
	var worker_local_bounds: Rect2 = worker_local_result.get("rect", Rect2())
	if not _validate_clear_of_world_layer(worker_bounds, "spawn do worker"):
		return false

	var left_limit := patrol_area.get_node_or_null("LeftLimit") as Marker2D
	var right_limit := patrol_area.get_node_or_null("RightLimit") as Marker2D
	if left_limit == null or right_limit == null:
		return _fail_authored_layout("limites de patrulha ausentes")
	var left_center: Vector2 = _local_transform_to_main(left_limit) * Vector2.ZERO
	var right_center: Vector2 = _local_transform_to_main(right_limit) * Vector2.ZERO
	var minimum_center_x := minf(left_center.x, right_center.x)
	var maximum_center_x := maxf(left_center.x, right_center.x)
	var sweep_bounds := Rect2(
		Vector2(minimum_center_x + worker_local_bounds.position.x, worker_body.position.y + worker_local_bounds.position.y),
		Vector2(maximum_center_x - minimum_center_x + worker_local_bounds.size.x, worker_local_bounds.size.y)
	)
	if sweep_bounds.position.x < 64.0 or sweep_bounds.end.x > 1088.0:
		return _fail_authored_layout("patrulha do worker cruza as faces internas das paredes")
	return _validate_clear_of_world_layer(sweep_bounds, "intervalo de patrulha do worker")

func _validate_authored_target(platform_rects: Dictionary) -> bool:
	var target := get_node_or_null("TrainingTarget") as TrainingTarget
	if target == null or not target.authored_support_enabled:
		return _fail_authored_layout("TrainingTarget não está no modo de suporte autoral")
	if target.collision_layer != 8:
		return _fail_authored_layout("TrainingTarget deve permanecer na collision layer 8")
	if target.collision_mask != 3:
		return _fail_authored_layout("TrainingTarget deve manter collision_mask 3 para World e Player")
	var player_body := get_node_or_null("Player") as CollisionObject2D
	if player_body == null or player_body.collision_mask != 9:
		return _fail_authored_layout("Player deve manter collision_mask 9 para World e TrainingTarget vivo")
	var target_local_result: Dictionary = _body_aabb(target, true)
	if not bool(target_local_result.get("valid", false)):
		return _fail_authored_layout("collider do TrainingTarget ausente")
	var target_local_bounds: Rect2 = target_local_result.get("rect", Rect2())
	if target.fixed_support_path.is_empty() or target.fallback_support_path.is_empty():
		return _fail_authored_layout("caminho de suporte autoral vazio")

	var support_paths: Array[NodePath] = [target.fixed_support_path, target.fallback_support_path]
	var first_safe_position: Dictionary = {}
	var selected_patrol: Dictionary = {}
	for support_path in support_paths:
		var support := _resolve_authored_support(target, support_path)
		if support == null or not platform_rects.has(support.name):
			continue
		var support_is_compatible := _is_target_support_compatible(support)
		var support_rect: Rect2 = platform_rects[support.name]
		if support_rect.size.x < target_local_bounds.size.x + AUTHORED_EDGE_MARGIN * 2.0:
			continue
		var target_origin := Vector2(
			support_rect.get_center().x - target_local_bounds.get_center().x,
			support_rect.position.y - target_local_bounds.end.y
		)
		var target_bounds: Rect2 = Rect2(target_local_bounds.position + target_origin, target_local_bounds.size)
		if target_bounds.position.x < support_rect.position.x + AUTHORED_EDGE_MARGIN - 0.01:
			continue
		if target_bounds.end.x > support_rect.end.x - AUTHORED_EDGE_MARGIN + 0.01:
			continue
		if absf(target_bounds.end.y - support_rect.position.y) > AUTHORED_CONTACT_TOLERANCE:
			continue
		if not _find_world_layer_overlap(target_bounds, support).is_empty():
			continue
		var minimum_center_x := support_rect.position.x + AUTHORED_EDGE_MARGIN - target_local_bounds.position.x
		var maximum_center_x := support_rect.end.x - AUTHORED_EDGE_MARGIN - target_local_bounds.end.x
		var route_is_useful := support_is_compatible and maximum_center_x - minimum_center_x >= 8.0
		var route_is_clear := false
		if route_is_useful:
			var sweep_bounds := Rect2(
				Vector2(minimum_center_x + target_local_bounds.position.x, target_origin.y + target_local_bounds.position.y),
				Vector2(maximum_center_x - minimum_center_x + target_local_bounds.size.x, target_local_bounds.size.y)
			)
			route_is_clear = _find_world_layer_overlap(sweep_bounds, support).is_empty()
		var candidate: Dictionary = {
			"position": target_origin,
			"support": support,
			"support_path": support_path,
			"minimum_center_x": minimum_center_x,
			"maximum_center_x": maximum_center_x,
		}
		if first_safe_position.is_empty():
			first_safe_position = candidate
		if route_is_clear:
			selected_patrol = candidate
			break

	var selected: Dictionary = selected_patrol if not selected_patrol.is_empty() else first_safe_position
	if selected.is_empty():
		return _fail_authored_layout("suportes primário e fallback do TrainingTarget são inválidos ou sem posição segura")
	_authored_target_position = selected.get("position", Vector2.ZERO)
	_authored_target_node = target
	_authored_target_support = selected.get("support") as SolidPlatform
	_authored_target_support_path = selected.get("support_path", NodePath(""))
	_authored_target_patrol_min_x = to_global(Vector2(float(selected.get("minimum_center_x", 0.0)), 0.0)).x
	_authored_target_patrol_max_x = to_global(Vector2(float(selected.get("maximum_center_x", 0.0)), 0.0)).x
	_authored_target_patrol_enabled = not selected_patrol.is_empty()
	if _run_controller_managed:
		var player_spawn := get_node_or_null("PlayerSpawnMarker") as Marker2D
		var player_bounds_result := _body_aabb(player_body, false) if player_body != null else {}
		if player_spawn == null or not bool(player_bounds_result.get("valid", false)):
			return _fail_authored_layout("spawn do jogador não pode ser comparado ao TrainingTarget")
		var player_bounds: Rect2 = player_bounds_result.get("rect", Rect2())
		player_bounds.position += player_spawn.position - player_body.position
		var target_bounds: Rect2 = target_local_bounds
		target_bounds.position += _authored_target_position
		if _positive_overlap_area(player_bounds, target_bounds) > AUTHORED_OVERLAP_AREA_LIMIT:
			return _fail_authored_layout("spawn do jogador intersecta o TrainingTarget preparado")
	return true

func _is_target_support_compatible(support: SolidPlatform) -> bool:
	if support == null or not is_instance_valid(support):
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

func _resolve_authored_support(target: TrainingTarget, path: NodePath) -> SolidPlatform:
	if target.get_parent() != self:
		return null
	var path_parts: PackedStringArray = String(path).split("/", false)
	if path_parts.size() != 2 or path_parts[0] != ".." or path_parts[1].is_empty():
		return null
	return get_node_or_null(NodePath(path_parts[1])) as SolidPlatform

func _validate_clear_of_world_layer(
	bounds: Rect2,
	label: String,
	allowed_support: CollisionObject2D = null
) -> bool:
	var blocker := _find_world_layer_overlap(bounds, allowed_support)
	if blocker.is_empty():
		return true
	return _fail_authored_layout("%s intersecta World layer 1 em %s" % [label, blocker])

func _find_world_layer_overlap(bounds: Rect2, allowed_support: CollisionObject2D = null) -> String:
	for obstacle_data: Dictionary in _authored_world_obstacles:
		var owner: CollisionObject2D = obstacle_data.get("owner") as CollisionObject2D
		if owner == null or owner == allowed_support:
			continue
		var obstacle_bounds: Rect2 = obstacle_data.get("rect", Rect2())
		if _positive_overlap_area(bounds, obstacle_bounds) > AUTHORED_OVERLAP_AREA_LIMIT:
			return String(owner.name)
	return ""

func _positive_overlap_area(first: Rect2, second: Rect2) -> float:
	var overlap_width := minf(first.end.x, second.end.x) - maxf(first.position.x, second.position.x)
	var overlap_height := minf(first.end.y, second.end.y) - maxf(first.position.y, second.position.y)
	if overlap_width <= 0.0 or overlap_height <= 0.0:
		return 0.0
	return overlap_width * overlap_height

func _body_aabb(body: CollisionObject2D, relative_to_body: bool) -> Dictionary:
	var found_shape := false
	var combined_bounds := Rect2()
	var body_transform := _local_transform_to_main(body)
	for shape_child in body.get_children():
		var collision := shape_child as CollisionShape2D
		if collision == null or collision.disabled or collision.shape == null:
			continue
		var shape_transform := _local_transform_to_main(collision)
		if relative_to_body:
			shape_transform = body_transform.affine_inverse() * shape_transform
		var shape_bounds := _transform_rect(collision.shape.get_rect(), shape_transform)
		if found_shape:
			combined_bounds = combined_bounds.merge(shape_bounds)
		else:
			combined_bounds = shape_bounds
			found_shape = true
	return {"valid": found_shape, "rect": combined_bounds}

func _collision_shape_aabb_in_main(collision: CollisionShape2D) -> Rect2:
	return _transform_rect(collision.shape.get_rect(), _local_transform_to_main(collision))

func _local_transform_to_main(node: Node2D) -> Transform2D:
	var transforms: Array[Transform2D] = []
	var current: Node = node
	while current != self:
		var current_2d := current as Node2D
		if current_2d == null:
			return Transform2D.IDENTITY
		transforms.append(current_2d.transform)
		current = current.get_parent()
		if current == null:
			return Transform2D.IDENTITY
	var result := Transform2D.IDENTITY
	for transform_index in range(transforms.size() - 1, -1, -1):
		result = result * transforms[transform_index]
	return result

func _transform_rect(rect: Rect2, transform: Transform2D) -> Rect2:
	var point_a := transform * rect.position
	var point_b := transform * Vector2(rect.end.x, rect.position.y)
	var point_c := transform * rect.end
	var point_d := transform * Vector2(rect.position.x, rect.end.y)
	var minimum_x := minf(minf(point_a.x, point_b.x), minf(point_c.x, point_d.x))
	var minimum_y := minf(minf(point_a.y, point_b.y), minf(point_c.y, point_d.y))
	var maximum_x := maxf(maxf(point_a.x, point_b.x), maxf(point_c.x, point_d.x))
	var maximum_y := maxf(maxf(point_a.y, point_b.y), maxf(point_c.y, point_d.y))
	return Rect2(minimum_x, minimum_y, maximum_x - minimum_x, maximum_y - minimum_y)

func _disable_invalid_authored_room() -> void:
	if player != null:
		player.process_mode = Node.PROCESS_MODE_DISABLED
	if combat_room != null:
		combat_room.process_mode = Node.PROCESS_MODE_DISABLED
	var target := get_node_or_null("TrainingTarget")
	if target != null:
		target.process_mode = Node.PROCESS_MODE_DISABLED
	var worker := get_node_or_null("RivetWorker")
	if worker != null:
		worker.process_mode = Node.PROCESS_MODE_DISABLED
	if exit_door != null:
		exit_door.call("set_room_cleared", false)

func _show_authored_layout_error() -> void:
	var error_layer := CanvasLayer.new()
	error_layer.name = "AuthoredLayoutError"
	error_layer.layer = 20
	add_child(error_layer)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	error_layer.add_child(center)
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(720.0, 200.0)
	center.add_child(panel)
	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 16)
	panel.add_child(content)
	var message := Label.new()
	message.text = "ERRO DE LAYOUT AUTORAL\n" + _authored_layout_error
	message.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(message)
	var restart := Button.new()
	restart.text = "REINICIAR SALA"
	restart.pressed.connect(_restart_authored_room)
	content.add_child(restart)

func _restart_authored_room() -> void:
	if _door_request_pending or _transition_in_progress or is_instance_valid(_transition_overlay):
		return
	_cancel_standalone_transition()
	get_tree().reload_current_scene()

func _managed_descriptor_error(requested_seed: int, descriptor: Dictionary) -> String:
	for key in [&"room_seed", &"family", &"entry_dir", &"exit_dir", &"coord", &"entry_offset", &"exit_offset"]:
		if not descriptor.has(key):
			return "descritor gerenciado sem campo obrigatório: %s" % String(key)
	if typeof(descriptor["room_seed"]) != TYPE_INT or requested_seed == 0 or int(descriptor["room_seed"]) != requested_seed:
		return "room_seed do descritor precisa ser inteiro não zero e coincidir com a seed solicitada"
	if typeof(descriptor["family"]) != TYPE_STRING_NAME:
		return "family do descritor precisa ser StringName"
	var family := StringName(descriptor["family"])
	if not [&"catwalk", &"ridge", &"valley", &"roof_four", &"roof_five"].has(family):
		return "family gerenciada desconhecida: %s" % String(family)
	if typeof(descriptor["entry_dir"]) != TYPE_VECTOR2I or typeof(descriptor["exit_dir"]) != TYPE_VECTOR2I or typeof(descriptor["coord"]) != TYPE_VECTOR2I:
		return "direções e coordenada do descritor precisam ser Vector2i"
	var entry_dir: Vector2i = descriptor["entry_dir"]
	var exit_dir: Vector2i = descriptor["exit_dir"]
	var directions: Array[Vector2i] = [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
	if not directions.has(entry_dir) or not directions.has(exit_dir) or entry_dir == exit_dir:
		return "direções do descritor são inválidas ou saída coincide com entrada"
	var requires_roof := entry_dir == Vector2i(0, -1) or exit_dir == Vector2i(0, -1)
	var is_roof_family := family == &"roof_four" or family == &"roof_five"
	if requires_roof != is_roof_family:
		return "família não corresponde à necessidade de hatch superior do descritor"
	for key in [&"entry_offset", &"exit_offset"]:
		var offset_value: Variant = descriptor[key]
		if typeof(offset_value) != TYPE_FLOAT and typeof(offset_value) != TYPE_INT:
			return "%s do descritor precisa ser numérico" % String(key)
		var expected := 496.0 if (entry_dir if key == &"entry_offset" else exit_dir).x != 0 else -1.0
		var offset := float(offset_value)
		if expected >= 0.0:
			if absf(offset - expected) > 0.01:
				return "%s fora do centro lateral canônico" % String(key)
		elif offset != 248.0 and offset != 904.0:
			return "%s fora dos slots verticais canônicos" % String(key)
	return ""


func configure_run_managed(shared_build: RunBuild, offer_build_upgrade: bool, requested_seed: int = 0, room_descriptor: Dictionary = {}) -> bool:
	if is_inside_tree() or shared_build == null:
		return false
	if _run_controller_managed:
		var same_request := _managed_room_descriptor == room_descriptor and _managed_run_build == shared_build \
			and reward_enabled == offer_build_upgrade and room_layout_seed == requested_seed
		return same_request and (not authored_layout_enabled or is_authored_layout_valid())
	if _authored_layout_prepared:
		return false
	var managed_exit_door := get_node_or_null("ExitDoor")
	if managed_exit_door == null or not managed_exit_door.has_signal("transition_requested"):
		return false
	if room_descriptor.is_empty():
		return _fail_authored_layout("descritor gerenciado ausente")
	var descriptor_error := _managed_descriptor_error(requested_seed, room_descriptor)
	if not descriptor_error.is_empty():
		return _fail_authored_layout(descriptor_error)
	_run_controller_managed = true
	_managed_room_descriptor = room_descriptor.duplicate(true)
	_managed_run_build = shared_build
	reward_enabled = offer_build_upgrade
	room_layout_seed = requested_seed
	if authored_layout_enabled and not prepare_authored_layout():
		return false
	return true


func _ready() -> void:
	if authored_layout_enabled and not is_authored_layout_valid():
		_disable_invalid_authored_room()
		_show_authored_layout_error()
		return
	set_process_input(true)
	if not combat_room.room_cleared.is_connected(_on_room_cleared):
		combat_room.room_cleared.connect(_on_room_cleared)
	if player != null and not player.died.is_connected(_on_player_died):
		player.died.connect(_on_player_died)
	if exit_door != null:
		exit_door.call("set_retry_enabled", true)
		var transition_callback := Callable(self, "_on_exit_door_transition_requested")
		if not exit_door.is_connected("transition_requested", transition_callback):
			exit_door.connect("transition_requested", transition_callback)

	var title_label := get_node_or_null(room_title_label_path) as Label
	if title_label != null:
		title_label.text = room_title

	if player != null:
		player.reset_to_spawn(_get_player_spawn_position())

	# Os filhos já executaram _ready. O controlador mantém o estado da run
	# entre encontros; cenas standalone continuam consumindo o snapshot one-shot.
	var incoming_snapshot: Dictionary = {}
	if not _run_controller_managed:
		incoming_snapshot = RoomTransition.consume_pending_snapshot(_load_current_packed_scene())
	if _run_controller_managed and _managed_run_build != null:
		run_build = _managed_run_build
	else:
		run_build = RunBuild.new()
	if player != null:
		if not incoming_snapshot.is_empty() and player.health != null:
			var restored_build := RunBuild.new()
			if restored_build.replace_state(
				incoming_snapshot.get("upgrade_ids"),
				incoming_snapshot.get("counts_by_id")
			):
				var health_restored := player.health.restore_health_for_room_transition(
					int(incoming_snapshot["hp_current"]),
					int(incoming_snapshot["hp_max"])
				)
				if health_restored:
					run_build = restored_build
		player.apply_run_build(run_build)

	_upgrade_offer = UpgradeOfferScene.instantiate() as UpgradeOffer
	if _upgrade_offer != null:
		add_child(_upgrade_offer)
		_upgrade_offer.upgrade_selected.connect(_on_upgrade_selected)
		_upgrade_offer.hide()

	_update_build_status()
	if exit_door != null:
		exit_door.call("set_room_cleared", false)
	if combat_room.room_is_cleared:
		_on_room_cleared()

func _exit_tree() -> void:
	if _upgrade_offer != null and is_instance_valid(_upgrade_offer):
		_upgrade_offer.close_offer()
	if not _standalone_swap_committed:
		if is_instance_valid(_transition_overlay) and _transition_overlay.has_method("cancel_transition"):
			_transition_overlay.call("cancel_transition")
		if not _run_controller_managed and (_door_request_pending or _transition_in_progress):
			RoomTransition.clear_pending_snapshot()
	_guard_active = false
	_guard_waiting_for_release = false
	_guard_quiet_remaining = 0.0
	# Do not unpause during teardown; the new room inherits the actual tree state.
	_owned_offer_pause = false

func _input(event: InputEvent) -> void:
	if _door_request_pending or _transition_in_progress or is_instance_valid(_transition_overlay):
		if event.is_action_pressed(&"ui_cancel") or event.is_action_pressed(&"interact") \
			or (event is InputEventKey and (event as InputEventKey).keycode == KEY_R):
			get_viewport().set_input_as_handled()
			return
	if authored_layout_enabled and not is_authored_layout_valid():
		for action in DISCRETE_INPUT_ACTIONS:
			if event.is_action_pressed(action):
				get_viewport().set_input_as_handled()
				return
	if _upgrade_flow_state == UpgradeFlowState.OFFER_OPEN and event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()
		return
	if not _guard_active:
		return
	for action in DISCRETE_INPUT_ACTIONS:
		if event.is_action_pressed(action):
			_guard_waiting_for_release = true
			_guard_quiet_remaining = 0.0
			get_viewport().set_input_as_handled()
			return

func _process(delta: float) -> void:
	if not _guard_active:
		return
	if _any_discrete_input_pressed():
		_guard_waiting_for_release = true
		_guard_quiet_remaining = 0.0
		return
	if _guard_waiting_for_release:
		_guard_waiting_for_release = false
		_guard_quiet_remaining = maxf(post_upgrade_input_guard_seconds, 0.0)
		if _guard_quiet_remaining <= 0.0:
			_end_input_guard()
		return

	_guard_quiet_remaining = maxf(_guard_quiet_remaining - delta, 0.0)
	if _guard_quiet_remaining <= 0.0:
		_end_input_guard()

func _physics_process(_delta: float) -> void:
	if authored_layout_enabled and not is_authored_layout_valid():
		return
	if player == null or not is_instance_valid(player) or player.is_dead:
		return
	if player.global_position.y > 760.0:
		player.reset_to_spawn(_get_player_spawn_position())

func is_gameplay_action_blocked(action: StringName) -> bool:
	if authored_layout_enabled and not is_authored_layout_valid():
		return true
	if _door_request_pending or _transition_in_progress or is_instance_valid(_transition_overlay):
		return true
	if not DISCRETE_INPUT_ACTIONS.has(action):
		return false
	if _upgrade_flow_state in [
		UpgradeFlowState.VICTORY_PENDING,
		UpgradeFlowState.OFFER_OPEN,
		UpgradeFlowState.SELECTED,
	]:
		return true
	return _guard_active

func _on_room_cleared() -> void:
	if authored_layout_enabled and not is_authored_layout_valid():
		return
	if _upgrade_flow_state != UpgradeFlowState.INACTIVE:
		return
	_upgrade_flow_state = UpgradeFlowState.VICTORY_PENDING
	if player != null and is_instance_valid(player):
		player.ball_launcher.request_stop_active_sweep()
	_queue_post_flush_resolution()

func _on_player_died() -> void:
	_cancel_standalone_transition()
	_death_pending = true
	_upgrade_flow_state = UpgradeFlowState.CANCELLED
	if player != null and is_instance_valid(player):
		player.ball_launcher.request_stop_active_sweep()
	_queue_post_flush_resolution()

func _queue_post_flush_resolution() -> void:
	if _post_flush_resolution_queued:
		return
	_post_flush_resolution_queued = true
	call_deferred("_resolve_after_physics_flush")

func _resolve_after_physics_flush() -> void:
	if authored_layout_enabled and not is_authored_layout_valid():
		_post_flush_resolution_queued = false
		return
	_post_flush_resolution_queued = false
	if player != null and is_instance_valid(player):
		player.ball_launcher.cleanup_active_ball_after_flush()
	combat_room.cleanup_hostile_projectiles_after_flush()
	combat_room.refresh_status_after_physics()

	if _death_pending or player == null or not is_instance_valid(player) or player.is_dead:
		_death_pending = true
		_upgrade_flow_state = UpgradeFlowState.CANCELLED
		_transition_in_progress = false
		run_build.clear()
		RoomTransition.clear_pending_snapshot()
		_offered_upgrade_ids.clear()
		if _upgrade_offer != null and is_instance_valid(_upgrade_offer):
			_upgrade_offer.close_offer()
		if exit_door != null:
			exit_door.call("set_room_cleared", false)
		_close_owned_offer_pause()
		_end_input_guard()
		_update_build_status()
		if player != null and is_instance_valid(player):
			player.finish_death_after_physics()
		return

	if _upgrade_flow_state != UpgradeFlowState.VICTORY_PENDING or not combat_room.room_is_cleared:
		return
	if reward_enabled and run_build.total_count() == 0:
		_open_upgrade_offer()
	else:
		_release_exit_or_complete()

func _open_upgrade_offer() -> void:
	if _upgrade_offer == null or not is_instance_valid(_upgrade_offer):
		_upgrade_flow_state = UpgradeFlowState.CANCELLED
		push_error("Main: não foi possível criar a oferta de upgrades.")
		if _run_controller_managed:
			_release_exit_or_complete()
		return
	_offered_upgrade_ids.clear()
	for definition in _upgrade_definitions:
		_offered_upgrade_ids.append(definition.upgrade_id)
	if not _upgrade_offer.present_options(_upgrade_definitions):
		_offered_upgrade_ids.clear()
		_upgrade_flow_state = UpgradeFlowState.CANCELLED
		push_error("Main: definições inválidas para a oferta.")
		if _run_controller_managed:
			_release_exit_or_complete()
		return

	_owned_offer_pause = not get_tree().paused
	_upgrade_flow_state = UpgradeFlowState.OFFER_OPEN
	if _owned_offer_pause:
		get_tree().paused = true

func _on_upgrade_selected(upgrade_id: StringName) -> void:
	if _upgrade_flow_state != UpgradeFlowState.OFFER_OPEN:
		return
	if player == null or not is_instance_valid(player) or player.is_dead:
		return
	if not _offered_upgrade_ids.has(upgrade_id):
		return
	if not RunBuild.is_known_upgrade_id(upgrade_id):
		return
	if run_build.count_for(upgrade_id) != 0 or run_build.total_count() >= RunBuild.MAX_UPGRADES:
		return

	# State changes before the build and player configurations are mutated.
	_upgrade_flow_state = UpgradeFlowState.SELECTED
	if not run_build.add_upgrade(upgrade_id):
		_upgrade_flow_state = UpgradeFlowState.OFFER_OPEN
		return
	player.apply_run_build(run_build)
	_update_build_status()
	_offered_upgrade_ids.clear()
	if _upgrade_offer != null and is_instance_valid(_upgrade_offer):
		_upgrade_offer.close_offer()
	_begin_input_guard()
	_close_owned_offer_pause()
	_release_exit_or_complete()

func _release_exit_or_complete() -> void:
	if exit_door == null:
		_upgrade_flow_state = UpgradeFlowState.COMPLETED
		return
	_upgrade_flow_state = UpgradeFlowState.EXIT_RELEASED
	_local_reward_resolved = true
	_door_unlock_pending = true
	_release_exit_door_if_ready()

func _release_exit_door_if_ready() -> void:
	if not _door_unlock_pending or _guard_active or _upgrade_flow_state != UpgradeFlowState.EXIT_RELEASED:
		return
	if not combat_room.room_is_cleared or player == null or not is_instance_valid(player) or player.is_dead:
		return
	_door_unlock_pending = false
	if not _run_controller_managed and next_room_scene_path.strip_edges().is_empty():
		_upgrade_flow_state = UpgradeFlowState.COMPLETED
		exit_door.call("set_terminal_complete")
		return
	exit_door.call("set_room_cleared", true)
	if _run_controller_managed and _managed_topology != null:
		_managed_topology.call("set_exit_open", true)

func _notify_run_progression_ready() -> void:
	if not _run_controller_managed or _run_progression_notified:
		return
	_run_progression_notified = true
	run_progression_ready.emit()

func _begin_input_guard() -> void:
	_guard_active = true
	_guard_waiting_for_release = _any_discrete_input_pressed()
	_guard_quiet_remaining = 0.0 if _guard_waiting_for_release else maxf(post_upgrade_input_guard_seconds, 0.0)
	if not _guard_waiting_for_release and _guard_quiet_remaining <= 0.0:
		_end_input_guard()

func _end_input_guard() -> void:
	_guard_active = false
	_guard_waiting_for_release = false
	_guard_quiet_remaining = 0.0
	_release_exit_door_if_ready()

func _any_discrete_input_pressed() -> bool:
	for action in DISCRETE_INPUT_ACTIONS:
		if Input.is_action_pressed(action):
			return true
	return false

func _close_owned_offer_pause() -> void:
	if _owned_offer_pause and get_tree().paused:
		get_tree().paused = false
	_owned_offer_pause = false

func _on_exit_door_transition_requested(requested_player: Player) -> void:
	if _door_request_pending or _transition_in_progress or _upgrade_flow_state != UpgradeFlowState.EXIT_RELEASED:
		return
	_door_request_pending = true
	_transition_token += 1
	_transition_player = requested_player
	_transition_source_scene = get_tree().current_scene if not _run_controller_managed else self
	call_deferred("_validate_exit_crossing_deferred", requested_player, _transition_token)

func _validate_exit_crossing_deferred(requested_player: Player, token: int) -> void:
	if token != _transition_token or not _door_request_pending:
		return
	var failure := _exit_crossing_validation_error(requested_player)
	if not failure.is_empty():
		if _run_controller_managed and _managed_transition_direction.y != 0 and not _death_pending and _is_current_room_source():
			_rollback_managed_vertical_crossing(requested_player, failure)
			return
		_door_request_pending = false
		if exit_door != null and is_instance_valid(exit_door):
			exit_door.call("report_transition_failure", failure)
		if _run_controller_managed and not _death_pending and _is_current_room_source():
			_report_managed_transition_failure(failure)
		return
	var destination_scene: PackedScene
	if not _run_controller_managed:
		var destination_path := next_room_scene_path.strip_edges()
		destination_scene = ResourceLoader.load(destination_path, "PackedScene") as PackedScene
		if destination_scene == null or destination_scene.resource_path.is_empty() \
			or not destination_scene.resource_path.begins_with("res://"):
			_door_request_pending = false
			exit_door.call("report_transition_failure", "FALHA AO CARREGAR SALA")
			return

	_door_request_pending = false
	_transition_in_progress = true
	_transition_source_scene = get_tree().current_scene if not _run_controller_managed else self
	_transition_player = requested_player
	_lock_player_for_transition(requested_player)
	if _run_controller_managed:
		_notify_run_progression_ready()
		return

	_transition_overlay = RoomTransitionOverlayScript.new()
	_transition_overlay.name = "RoomTransitionOverlay"
	get_tree().root.add_child(_transition_overlay)
	var overlay_started := bool(_transition_overlay.call(
		"begin_transition",
		self,
		_transition_source_scene,
		destination_scene,
		token
	))
	if not overlay_started:
		transition_overlay_failed(token, "FALHA AO INICIAR TRANSIÇÃO")
		_transition_overlay.call("cancel_transition")
		_transition_overlay = null

func _rollback_managed_vertical_crossing(requested_player: Player, message: String) -> void:
	_transition_in_progress = false
	_door_request_pending = false
	if requested_player != null and is_instance_valid(requested_player) \
		and requested_player == player and not requested_player.is_dead:
		var rollback_spawn := _get_player_spawn_position()
		var entry_dir: Vector2i = _managed_room_descriptor.get("entry_dir", Vector2i.ZERO)
		if _managed_transition_direction == Vector2i(0, 1) and entry_dir != Vector2i(0, -1):
			var portal_x := float(_managed_room_descriptor.get("exit_offset", 576.0))
			var safe_x := portal_x + 176.0 if portal_x < 576.0 else portal_x - 176.0
			rollback_spawn = to_global(Vector2(safe_x, 560.0))
		requested_player.reset_to_spawn(rollback_spawn)
		requested_player.velocity = Vector2.ZERO
	if exit_door != null and is_instance_valid(exit_door):
		exit_door.call("report_transition_failure", message)
func _exit_crossing_validation_error(requested_player: Player) -> String:
	if _transition_in_progress or _upgrade_flow_state != UpgradeFlowState.EXIT_RELEASED:
		return "SAÍDA INDISPONÍVEL"
	if _guard_active or not _local_reward_resolved or not combat_room.room_is_cleared:
		return "SAÍDA INDISPONÍVEL"
	if requested_player == null or not is_instance_valid(requested_player) \
		or requested_player != player or requested_player.is_dead:
		return "JOGADOR INDISPONÍVEL"
	if not _is_current_room_source():
		return "SALA INDISPONÍVEL"
	if exit_door == null or not is_instance_valid(exit_door) \
		or not bool(exit_door.call("has_latched_crossing", requested_player)) \
		or not bool(exit_door.call("is_player_inside_exit_opening", requested_player)) \
		or not bool(exit_door.call("is_gate_open")):
		return "ATRAVESSE A SAÍDA"
	return ""

func _is_current_room_source() -> bool:
	if not _run_controller_managed:
		return is_inside_tree() and get_tree().current_scene == self
	var ancestor := get_parent()
	while ancestor != null:
		if ancestor.has_method("is_active_room_instance"):
			return bool(ancestor.call("is_active_room_instance", self))
		ancestor = ancestor.get_parent()
	return false

func _lock_player_for_transition(requested_player: Player) -> void:
	_transition_original_disable_mode = requested_player.disable_mode
	_transition_original_process_mode = requested_player.process_mode
	requested_player.disable_mode = CollisionObject2D.DISABLE_MODE_KEEP_ACTIVE
	requested_player.process_mode = Node.PROCESS_MODE_DISABLED
	requested_player.velocity = Vector2.ZERO
	_transition_player_locked = true

func _restore_player_after_transition_failure() -> void:
	if not _transition_player_locked:
		return
	if is_instance_valid(_transition_player):
		_transition_player.process_mode = _transition_original_process_mode
		_transition_player.disable_mode = _transition_original_disable_mode
		_transition_player.velocity = Vector2.ZERO
	_transition_player_locked = false

func is_standalone_transition_valid(token: int) -> bool:
	return (
		token == _transition_token
		and _transition_in_progress
		and not _run_controller_managed
		and not _death_pending
		and _transition_source_scene == self
		and _is_current_room_source()
		and _exit_crossing_validation_error_after_lock(_transition_player).is_empty()
	)

func _exit_crossing_validation_error_after_lock(requested_player: Player) -> String:
	if _upgrade_flow_state != UpgradeFlowState.EXIT_RELEASED or _guard_active \
		or not _local_reward_resolved or not combat_room.room_is_cleared:
		return "SAÍDA INDISPONÍVEL"
	if requested_player == null or not is_instance_valid(requested_player) \
		or requested_player != player or requested_player.is_dead:
		return "JOGADOR INDISPONÍVEL"
	if exit_door == null or not is_instance_valid(exit_door) \
		or not bool(exit_door.call("has_latched_crossing", requested_player)) \
		or not bool(exit_door.call("is_player_inside_exit_opening", requested_player)) \
		or not bool(exit_door.call("is_gate_open")):
		return "ATRAVESSE A SAÍDA"
	return ""

func commit_standalone_room_swap(token: int, destination_scene: PackedScene) -> int:
	if not is_standalone_transition_valid(token) or destination_scene == null:
		return ERR_INVALID_DATA
	if not RoomTransition.prepare_run_snapshot(
		destination_scene,
		_transition_player.current_health,
		_transition_player.maximum_health,
		run_build
	):
		return ERR_INVALID_DATA
	_standalone_swap_committed = true
	var result := get_tree().change_scene_to_packed(destination_scene)
	if result != OK:
		_standalone_swap_committed = false
		RoomTransition.clear_pending_snapshot()
		return result
	return OK

func transition_overlay_failed(token: int, message: String) -> void:
	if token != _transition_token or _standalone_swap_committed:
		return
	RoomTransition.clear_pending_snapshot()
	_transition_in_progress = false
	_door_request_pending = false
	_restore_player_after_transition_failure()
	if exit_door != null and is_instance_valid(exit_door):
		exit_door.call("report_transition_failure", message)

func transition_overlay_source_still_active_after_timeout(token: int, message: String) -> bool:
	if token != _transition_token or not _standalone_swap_committed \
		or not _transition_in_progress or _run_controller_managed or _death_pending:
		return false
	if _transition_source_scene != self or not is_inside_tree() \
		or not _is_current_room_source() or get_tree().current_scene != self:
		return false
	# A scene swap accepted by Godot did not leave this source scene before the
	# timeout fade completed. Only this verified path may roll it back.
	_standalone_swap_committed = false
	transition_overlay_failed(token, message)
	return true

func transition_overlay_finished(token: int) -> void:
	if token == _transition_token:
		_transition_overlay = null

func _cancel_standalone_transition() -> void:
	if _run_controller_managed:
		return
	if _door_request_pending or _transition_in_progress or is_instance_valid(_transition_overlay):
		_transition_token += 1
	if is_instance_valid(_transition_overlay) and _transition_overlay.has_method("cancel_transition"):
		_transition_overlay.call("cancel_transition")
	_transition_overlay = null
	if not _standalone_swap_committed:
		RoomTransition.clear_pending_snapshot()
	_restore_player_after_transition_failure()
	_door_request_pending = false
	_transition_in_progress = false

func _report_managed_transition_failure(message: String) -> void:
	var ancestor := get_parent()
	while ancestor != null:
		if ancestor.has_method("fail_managed_room_transition"):
			ancestor.call("fail_managed_room_transition", self, message)
			return
		ancestor = ancestor.get_parent()

func _update_build_status() -> void:
	var label := get_node_or_null(build_status_label_path) as Label
	if label == null:
		return
	if run_build == null or run_build.total_count() == 0:
		label.text = "BUILD: VAZIA"
		return

	var upgrade_id := run_build.get_upgrade_ids()[0]
	var display_name := ""
	for definition in _upgrade_definitions:
		if definition.upgrade_id == upgrade_id:
			display_name = definition.title
			break
	label.text = "BUILD: %s" % display_name.to_upper()

func _get_player_spawn_position() -> Vector2:
	var spawn_marker := get_node_or_null(player_spawn_marker_path) as Marker2D
	if spawn_marker != null:
		return spawn_marker.global_position
	return FALLBACK_PLAYER_SPAWN

func _current_scene_path() -> String:
	if not scene_file_path.is_empty():
		return scene_file_path
	var current_scene := get_tree().current_scene
	if current_scene != null:
		return current_scene.scene_file_path
	return ""

func _load_current_packed_scene() -> PackedScene:
	var current_path := _current_scene_path()
	if current_path.is_empty():
		return null
	return ResourceLoader.load(current_path, "PackedScene") as PackedScene
