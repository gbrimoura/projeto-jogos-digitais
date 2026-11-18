class_name BallLauncher
extends Node

signal launch_accepted(spawn_position: Vector2, direction: Vector2)

const UpgradeCatalogScript = preload("res://scripts/progression/upgrade_catalog.gd")
const ShopItemCatalogScript = preload("res://scripts/progression/shop_item_catalog.gd")

## Dispara uma única bola por vez sem assumir responsabilidade pela locomoção.

@export var projectile_scene: PackedScene
@export var projectile_config: ProjectileConfig

var _player: Node2D
var _aim_controller: AimController
var _racket_controller: RacketController
var _shot_origin: Node2D
var _projectile_parent: Node
var _active_ball: RicochetBall
var _base_projectile_config: ProjectileConfig
var _run_build: RunBuild
var _run_damage_multiplier: float = 1.0
var _run_speed_multiplier: float = 1.0
var _run_radius_multiplier: float = 1.0
var _catraca_scrap_registered: bool = false
var _spawn_shape: CircleShape2D
var _spawn_query: PhysicsShapeQueryParameters2D

func get_flight_speed_ratio() -> float:
	return _active_ball.get_flight_speed_ratio() if is_instance_valid(_active_ball) else 0.0

func configure(
	player: Node2D,
	aim_controller: AimController,
	shot_origin: Node2D,
	projectile_parent: Node
) -> void:
	_player = player
	_aim_controller = aim_controller
	_racket_controller = player.get_node_or_null("RacketController") as RacketController if player != null else null
	_shot_origin = shot_origin
	_projectile_parent = projectile_parent
	if _projectile_parent == null and _player != null:
		_projectile_parent = _player.get_parent()
	_base_projectile_config = projectile_config.duplicate(true) as ProjectileConfig if projectile_config != null else null

func apply_run_build(build: RunBuild) -> void:
	_run_build = build

func set_run_reward_multipliers(damage: float, speed: float, radius: float) -> void:
	_run_damage_multiplier = maxf(damage, 0.01)
	_run_speed_multiplier = maxf(speed, 0.01)
	_run_radius_multiplier = maxf(radius, 0.01)

func try_launch(triggered: bool) -> bool:
	if not triggered or not is_launch_available():
		return false

	var direction := _aim_controller.aim_direction.normalized()
	if direction.is_zero_approx():
		direction = Vector2.RIGHT
	var spawn_position := get_spawn_position_for_direction(direction)
	if not spawn_position.is_finite():
		return false

	var launch_config := get_projectile_config_snapshot()
	if launch_config == null:
		return false
	var ball := projectile_scene.instantiate() as RicochetBall
	if ball == null:
		return false
	var rolamento_bonus_available := _run_build != null and _run_build.has_rolamento_livre_damage_pending()
	if rolamento_bonus_available:
		launch_config.damage += ShopItemCatalogScript.ROLLING_NEXT_SHOT_DAMAGE_BONUS
		if _run_build.item_level_for(&"catraca_sucata") > 0:
			launch_config.damage += 1

	ball.collision_mask = launch_config.collision_mask
	_projectile_parent.add_child(ball)
	_active_ball = ball
	ball.finished.connect(_on_ball_finished.bind(ball))
	ball.fragment_scene = projectile_scene
	ball.set_return_target(_shot_origin)
	ball.global_position = spawn_position
	ball.launch(direction, launch_config)
	if rolamento_bonus_available:
		_run_build.consume_rolamento_livre_damage_pending()
	launch_accepted.emit(spawn_position, direction)
	return true

func is_launch_available() -> bool:
	if _racket_controller == null or _racket_controller.is_swing_active():
		return false
	if _aim_controller == null or _shot_origin == null:
		return false
	if projectile_scene == null or _base_projectile_config == null or _projectile_parent == null:
		return false
	if _active_ball == null:
		return true
	if is_instance_valid(_active_ball):
		return false
	_active_ball = null
	return true

func reset() -> void:
	var ball_to_cleanup := _active_ball
	if ball_to_cleanup == null or not is_instance_valid(ball_to_cleanup):
		_active_ball = null
		return
	ball_to_cleanup.request_stop_sweep()
	call_deferred("_cleanup_ball_after_flush", ball_to_cleanup)

func request_stop_active_sweep() -> void:
	if _active_ball != null and is_instance_valid(_active_ball):
		_active_ball.request_stop_sweep()

## Call only after the current physics callback/flush has returned.
func cleanup_active_ball_after_flush() -> void:
	_cleanup_ball_after_flush(_active_ball)

func _cleanup_ball_after_flush(ball_to_cleanup: RicochetBall) -> void:
	if ball_to_cleanup == null or not is_instance_valid(ball_to_cleanup):
		if _active_ball == ball_to_cleanup:
			_active_ball = null
		return
	ball_to_cleanup.cancel()
	if _active_ball == ball_to_cleanup:
		_active_ball = null

func _on_ball_finished(reason: String, ball: RicochetBall) -> void:
	if reason == "returned":
		_register_catraca_scrap()
		if _run_build != null:
			_run_build.mark_rolamento_livre_damage_pending()
	if ball == _active_ball:
		_active_ball = null

func _register_catraca_scrap() -> void:
	if _catraca_scrap_registered or _run_build == null or _run_build.item_level_for(&"catraca_sucata") <= 0:
		return
	if not is_instance_valid(_player):
		return
	var scene_tree := _player.get_tree()
	if scene_tree == null:
		return
	for controller: Node in scene_tree.get_nodes_in_group("run_controller"):
		if not is_instance_valid(controller) or not controller.has_method("register_temporary_scrap"):
			continue
		var accepted: Variant = controller.call("register_temporary_scrap", 1, false)
		if typeof(accepted) == TYPE_BOOL and bool(accepted):
			_catraca_scrap_registered = true
			return

func get_spawn_position_for_direction(direction: Vector2) -> Vector2:
	var config := get_projectile_config_snapshot()
	if _shot_origin == null or config == null:
		return Vector2.INF

	var launch_direction := direction.normalized()
	if launch_direction.is_zero_approx():
		launch_direction = Vector2.RIGHT

	_ensure_spawn_query(config)
	var space_state := _shot_origin.get_world_2d().direct_space_state
	var origin := _shot_origin.global_position
	if not _is_spawn_position_clear(space_state, origin):
		return Vector2.INF

	var requested_distance := maxf(config.spawn_offset, 0.0)
	if requested_distance <= 0.0:
		return origin

	var motion := launch_direction * requested_distance
	_spawn_query.transform = Transform2D(0.0, origin)
	_spawn_query.motion = motion
	var fractions := space_state.cast_motion(_spawn_query)
	if fractions.size() < 2:
		return Vector2.INF

	var safe_fraction := clampf(fractions[0], 0.0, 1.0)
	var spawn_distance := requested_distance * safe_fraction
	if safe_fraction < 1.0:
		spawn_distance = maxf(spawn_distance - maxf(config.collision_skin, 0.0), 0.0)

	var candidate := origin + launch_direction * spawn_distance
	if not _is_spawn_position_clear(space_state, candidate):
		var low := 0.0
		var high := spawn_distance
		for _attempt in range(8):
			var midpoint := (low + high) * 0.5
			if _is_spawn_position_clear(space_state, origin + launch_direction * midpoint):
				low = midpoint
			else:
				high = midpoint
		spawn_distance = low
		candidate = origin + launch_direction * spawn_distance

	if spawn_distance <= 0.01:
		return Vector2.INF
	return candidate

func _ensure_spawn_query(config: ProjectileConfig) -> void:
	if _spawn_shape == null:
		_spawn_shape = CircleShape2D.new()
	if _spawn_query == null:
		_spawn_query = PhysicsShapeQueryParameters2D.new()
		_spawn_query.shape = _spawn_shape
		_spawn_query.collide_with_bodies = true
		_spawn_query.collide_with_areas = false

	_spawn_shape.radius = config.collision_radius
	_spawn_query.collision_mask = config.collision_mask
	_spawn_query.margin = maxf(config.collision_safe_margin, 0.01)

func _is_spawn_position_clear(space_state: PhysicsDirectSpaceState2D, position: Vector2) -> bool:
	_spawn_query.transform = Transform2D(0.0, position)
	_spawn_query.motion = Vector2.ZERO
	return space_state.intersect_shape(_spawn_query, 1).is_empty()

func _is_player_dashing() -> bool:
	if not is_instance_valid(_player):
		return false
	var movement_controller := _player.get_node_or_null("MovementController") as MovementController
	return movement_controller != null and movement_controller.is_dashing

func get_projectile_config_snapshot() -> ProjectileConfig:
	if _base_projectile_config == null:
		return null
	var derived_config := _base_projectile_config.duplicate(true) as ProjectileConfig
	if _run_build != null:
		var return_bearing_level := _run_build.item_level_for(&"rolamento_livre")
		derived_config.return_speed_multiplier = 1.0 + ShopItemCatalogScript.ROLLING_RETURN_SPEED_BONUS_PER_LEVEL * float(return_bearing_level)
		var turbine_level := _run_build.item_level_for(&"turbina_centrifuga")
		derived_config.environmental_bounce_speed_bonus_per_bounce = ShopItemCatalogScript.TURBINE_BOUNCE_SPEED_BONUS_PER_LEVEL * float(turbine_level)
		derived_config.max_environmental_bounce_speed_multiplier = 1.0 + ShopItemCatalogScript.TURBINE_BOUNCE_SPEED_MAX_BONUS if turbine_level > 0 else 1.0
		var guard_level := _run_build.item_level_for(&"punho_guarda")
		if turbine_level > 0 and guard_level > 0:
			derived_config.max_environmental_bounce_speed_multiplier += 0.16
		derived_config.parry_speed_bonus_per_success = ShopItemCatalogScript.guard_parry_speed_bonus_per_success(guard_level)
		derived_config.max_parry_speed_multiplier = 1.0 + ShopItemCatalogScript.GUARD_PARRY_SPEED_MAX_BONUS if guard_level > 0 else 1.0
		derived_config.heat_rank = _run_build.count_for(&"bola_incandescente")
		derived_config.magnet_rank = _run_build.count_for(&"bola_magnetica")
		var has_thermal := _run_build.item_level_for(&"camara_termica") > 0
		var has_inductor := _run_build.item_level_for(&"nucleo_indutor") > 0
		derived_config.heat_rank = maxi(derived_config.heat_rank, int(has_thermal))
		derived_config.magnet_rank = maxi(derived_config.magnet_rank, int(has_inductor))
		derived_config.has_forge = _run_build.has_upgrade(&"forja_magnetica") or (has_thermal and has_inductor)
		derived_config.splits_on_wall = _run_build.has_upgrade(&"bola_fragmentaria")
		derived_config.impact_rank = _run_build.count_for(&"impacto_reforcado")
		derived_config.charge_rank = _run_build.count_for(&"carga_reativa")
		derived_config.pressure_rank = _run_build.count_for(&"ricochete_pressao")
		var charge_definition := UpgradeCatalogScript.definition_for(&"carga_reativa")
		derived_config.reactive_charge_enabled = derived_config.charge_rank > 0 \
			and charge_definition != null and charge_definition.reactive_charge_enabled
		derived_config.charged_damage_bonus = derived_config.charge_rank * (
			charge_definition.charged_damage_bonus_per_rank if charge_definition != null else 0
		)
		derived_config.max_bounces += UpgradeCatalogScript.projectile_bounce_bonus(
			_run_build.count_for(&"mola_retorno")
		)
		derived_config.lifetime += UpgradeCatalogScript.projectile_lifetime_bonus(
			_run_build.count_for(&"mola_retorno")
		)
	# Run rewards derive from the already-upgraded copy; the base Resource stays unchanged.
	derived_config.damage = maxi(roundi(float(derived_config.damage) * _run_damage_multiplier), 1)
	if _run_build != null:
		derived_config.speed *= UpgradeCatalogScript.projectile_speed_multiplier_for_rank(
			_run_build.count_for(&"ajuste_velocidade_bola")
		)
		if _is_player_dashing():
			derived_config.speed *= UpgradeCatalogScript.dash_shot_speed_multiplier_for_rank(
				_run_build.count_for(&"motor_acelerado")
			)
	derived_config.speed *= _run_speed_multiplier
	derived_config.collision_radius *= _run_radius_multiplier
	return derived_config
