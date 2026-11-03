class_name UpgradeCatalog
extends RefCounted

## Single source for run upgrade definitions, caps, derived effects and card copy.
## This file intentionally does not preload or reference RunBuild.

const MAX_RUN_ACQUISITIONS: int = 220
const BASE_PROJECTILE_CONFIG: ProjectileConfig = preload("res://resources/projectile_config.tres")
const BASE_MOVEMENT_CONFIG: MovementConfig = preload("res://resources/player_movement_config.tres")

static var _definitions: Array[UpgradeDefinitionResource] = [
	preload("res://resources/upgrades/impacto_reforcado.tres"),
	preload("res://resources/upgrades/motor_acelerado.tres"),
	preload("res://resources/upgrades/carga_reativa.tres"),
	preload("res://resources/upgrades/ricochete_pressao.tres"),
	preload("res://resources/upgrades/mola_retorno.tres"),
	preload("res://resources/upgrades/dinamo_defesa.tres"),
	preload("res://resources/upgrades/chassi_reforcado.tres"),
]


static func definitions() -> Array[UpgradeDefinitionResource]:
	var result: Array[UpgradeDefinitionResource] = []
	for definition in _definitions:
		result.append(definition)
	return result


static func known_upgrade_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	for definition in _definitions:
		if definition != null and not String(definition.upgrade_id).is_empty():
			result.append(definition.upgrade_id)
	return result


static func is_known_upgrade_id(upgrade_id: Variant) -> bool:
	return definition_for(upgrade_id) != null


static func definition_for(upgrade_id: Variant) -> UpgradeDefinitionResource:
	if typeof(upgrade_id) != TYPE_STRING and typeof(upgrade_id) != TYPE_STRING_NAME:
		return null
	var requested_id := StringName(upgrade_id)
	for definition in _definitions:
		if definition != null and definition.upgrade_id == requested_id:
			return definition
	return null


static func max_rank_for(upgrade_id: Variant, base_maximum_health: int = 5) -> int:
	var definition := definition_for(upgrade_id)
	if definition == null:
		return 0
	var cap: int = clampi(definition.rank_cap, 0, MAX_RUN_ACQUISITIONS)
	if definition.maximum_health_per_rank > 0:
		return clampi(100 - maxi(base_maximum_health, 1), 0, cap)
	return cap


static func can_acquire(upgrade_id: Variant, current_rank: int, base_maximum_health: int = 5) -> bool:
	return is_known_upgrade_id(upgrade_id) and current_rank >= 0 \
		and current_rank < max_rank_for(upgrade_id, base_maximum_health)


static func total_rank_count(ranks_by_id: Dictionary) -> int:
	var total: int = 0
	for upgrade_id in known_upgrade_ids():
		total += maxi(int(ranks_by_id.get(upgrade_id, ranks_by_id.get(String(upgrade_id), 0))), 0)
	return total


static func build_offer(
	ranks_by_id: Dictionary,
	room_seed: int,
	room_ordinal: int,
	base_maximum_health: int = 5
) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if total_rank_count(ranks_by_id) >= MAX_RUN_ACQUISITIONS:
		return result

	var new_candidates: Array[UpgradeDefinitionResource] = []
	var evolution_candidates: Array[UpgradeDefinitionResource] = []
	for definition in _definitions:
		if definition == null:
			continue
		var rank := _rank_for(ranks_by_id, definition.upgrade_id)
		if not can_acquire(definition.upgrade_id, rank, base_maximum_health):
			continue
		if rank == 0:
			new_candidates.append(definition)
		else:
			evolution_candidates.append(definition)

	var rng := RandomNumberGenerator.new()
	rng.seed = _offer_seed(room_seed, room_ordinal)
	var selected_definitions: Array[UpgradeDefinitionResource] = []
	if not new_candidates.is_empty() and not evolution_candidates.is_empty():
		selected_definitions.append(_take_random(new_candidates, rng))
		selected_definitions.append(_take_random(evolution_candidates, rng))

	var remaining: Array[UpgradeDefinitionResource] = []
	for definition in new_candidates:
		if not selected_definitions.has(definition):
			remaining.append(definition)
	for definition in evolution_candidates:
		if not selected_definitions.has(definition):
			remaining.append(definition)
	while selected_definitions.size() < 3 and not remaining.is_empty():
		selected_definitions.append(_take_random(remaining, rng))

	for definition in selected_definitions:
		var current_rank := _rank_for(ranks_by_id, definition.upgrade_id)
		var card := card_preview(definition.upgrade_id, current_rank, base_maximum_health)
		card["definition"] = definition
		result.append(card)
	return result


static func card_preview(
	upgrade_id: Variant,
	current_rank: int,
	base_maximum_health: int = 5
) -> Dictionary:
	var definition := definition_for(upgrade_id)
	if definition == null or not can_acquire(upgrade_id, current_rank, base_maximum_health):
		return {}
	var next_rank: int = current_rank + 1
	var rank_label := "NOVO" if current_rank == 0 else "NV.%d > %d" % [current_rank, next_rank]
	return {
		"upgrade_id": definition.upgrade_id,
		"definition": definition,
		"title": definition.title,
		"description": definition.description,
		"rank_before": current_rank,
		"rank_after": next_rank,
		"rank_label": rank_label,
		"effect_summary": effect_summary(upgrade_id, current_rank, next_rank, base_maximum_health),
		"topics": definition.effect_topics.duplicate(),
		"icon": definition.icon,
	}


static func effect_summary(
	upgrade_id: Variant,
	current_rank: int,
	next_rank: int,
	base_maximum_health: int = 5
) -> String:
	var definition := definition_for(upgrade_id)
	if definition == null:
		return ""
	match definition.upgrade_id:
		&"impacto_reforcado":
			var base_damage: int = maxi(BASE_PROJECTILE_CONFIG.damage, 1)
			return "%d > %d dano" % [base_damage + current_rank * definition.projectile_damage_per_rank, base_damage + next_rank * definition.projectile_damage_per_rank]
		&"motor_acelerado":
			var current_cooldown := dash_cooldown_for_rank(current_rank)
			var next_cooldown := dash_cooldown_for_rank(next_rank)
			return "%s > %s s" % [_format_decimal(current_cooldown), _format_decimal(next_cooldown)]
		&"carga_reativa":
			return "+%d > +%d dano" % [current_rank * definition.charged_damage_bonus_per_rank, next_rank * definition.charged_damage_bonus_per_rank]
		&"ricochete_pressao":
			return "+%d > +%d/parede" % [current_rank * definition.environmental_bounce_damage_per_rank, next_rank * definition.environmental_bounce_damage_per_rank]
		&"mola_retorno":
			var current_bounces: int = BASE_PROJECTILE_CONFIG.max_bounces + current_rank * definition.max_bounces_per_rank
			var next_bounces: int = BASE_PROJECTILE_CONFIG.max_bounces + next_rank * definition.max_bounces_per_rank
			var current_lifetime: float = BASE_PROJECTILE_CONFIG.lifetime + current_rank * definition.lifetime_per_rank
			var next_lifetime: float = BASE_PROJECTILE_CONFIG.lifetime + next_rank * definition.lifetime_per_rank
			return "%d > %d ric.; %s > %s s" % [current_bounces, next_bounces, _format_decimal(current_lifetime), _format_decimal(next_lifetime)]
		&"dinamo_defesa":
			return "%s > %s s por parry" % [
				_format_decimal(current_rank * definition.dash_cooldown_refund_per_rank),
				_format_decimal(next_rank * definition.dash_cooldown_refund_per_rank),
			]
		&"chassi_reforcado":
			var base_health: int = maxi(base_maximum_health, 1)
			var current_health: int = mini(base_health + current_rank * definition.maximum_health_per_rank, 100)
			var next_health: int = mini(base_health + next_rank * definition.maximum_health_per_rank, 100)
			return "%d > %d HP max; cura +%d" % [current_health, next_health, definition.health_recovered_per_rank]
	return definition.effect_summary


static func projectile_damage(
	base_damage: int,
	impact_rank: int,
	charge_rank: int,
	charged: bool,
	pressure_rank: int,
	environmental_bounce_count: int
) -> int:
	var damage: int = maxi(base_damage, 0)
	var impact_definition := definition_for(&"impacto_reforcado")
	var charge_definition := definition_for(&"carga_reativa")
	var pressure_definition := definition_for(&"ricochete_pressao")
	if impact_definition != null:
		damage += maxi(impact_rank, 0) * impact_definition.projectile_damage_per_rank
	if charged and charge_definition != null and charge_definition.reactive_charge_enabled:
		damage += maxi(charge_rank, 0) * charge_definition.charged_damage_bonus_per_rank
	if pressure_definition != null:
		var counted_bounces: int = mini(maxi(environmental_bounce_count, 0), pressure_definition.environmental_bounce_damage_count_cap)
		damage += maxi(pressure_rank, 0) * counted_bounces * pressure_definition.environmental_bounce_damage_per_rank
	return maxi(damage, 0)


static func dash_cooldown_for_rank(rank: int) -> float:
	var base_cooldown := maxf(BASE_MOVEMENT_CONFIG.dash_cooldown, 0.0)
	var definition := definition_for(&"motor_acelerado")
	if definition == null or rank <= 0 or definition.dash_cooldown_by_rank.is_empty():
		return base_cooldown
	var index: int = mini(rank, definition.dash_cooldown_by_rank.size()) - 1
	return maxf(definition.dash_cooldown_by_rank[index], 0.0)


static func dash_refund_seconds(rank: int) -> float:
	var definition := definition_for(&"dinamo_defesa")
	return float(maxi(rank, 0)) * definition.dash_cooldown_refund_per_rank if definition != null else 0.0


static func projectile_bounce_bonus(rank: int) -> int:
	var definition := definition_for(&"mola_retorno")
	return maxi(rank, 0) * definition.max_bounces_per_rank if definition != null else 0


static func projectile_lifetime_bonus(rank: int) -> float:
	var definition := definition_for(&"mola_retorno")
	return float(maxi(rank, 0)) * definition.lifetime_per_rank if definition != null else 0.0


static func maximum_health(base_maximum_health: int, rank: int) -> int:
	var definition := definition_for(&"chassi_reforcado")
	if definition == null:
		return clampi(base_maximum_health, 1, 100)
	return clampi(base_maximum_health + maxi(rank, 0) * definition.maximum_health_per_rank, 1, 100)


static func acquisition_heal(upgrade_id: Variant, previous_rank: int, next_rank: int) -> int:
	var definition := definition_for(upgrade_id)
	if definition == null or definition.maximum_health_per_rank <= 0:
		return 0
	return maxi(next_rank - previous_rank, 0) * definition.health_recovered_per_rank


static func _rank_for(ranks_by_id: Dictionary, upgrade_id: StringName) -> int:
	return maxi(int(ranks_by_id.get(upgrade_id, ranks_by_id.get(String(upgrade_id), 0))), 0)


static func _take_random(candidates: Array[UpgradeDefinitionResource], rng: RandomNumberGenerator) -> UpgradeDefinitionResource:
	var index: int = rng.randi_range(0, candidates.size() - 1)
	return candidates.pop_at(index)


static func _offer_seed(room_seed: int, room_ordinal: int) -> int:
	var seed_value: int = (room_seed * 1103515245 + room_ordinal * 12345 + 0x5F3759DF) & 0x7FFFFFFF
	return seed_value if seed_value != 0 else 1


static func _format_decimal(value: float) -> String:
	var formatted := "%.2f" % value
	while formatted.ends_with("0"):
		formatted = formatted.left(formatted.length() - 1)
	if formatted.ends_with("."):
		formatted = formatted.left(formatted.length() - 1)
	return formatted.replace(".", ",")
