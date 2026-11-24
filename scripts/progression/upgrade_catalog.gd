class_name UpgradeCatalog
extends RefCounted

## Single source for run upgrade definitions, caps, derived effects and card copy.
## This file intentionally does not preload or reference RunBuild.

const MAX_RUN_ACQUISITIONS: int = 220
const UPGRADE_RARITY_WEIGHTS: Array[int] = [12, 9, 6, 3, 1]
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
	preload("res://resources/upgrades/ajuste_velocidade_bola.tres"),
	preload("res://resources/upgrades/ajuste_recarga_dash.tres"),
	preload("res://resources/upgrades/reparo_campo.tres"),
	preload("res://resources/upgrades/bola_incandescente.tres"),
	preload("res://resources/upgrades/bola_magnetica.tres"),
	preload("res://resources/upgrades/forja_magnetica.tres"),
	preload("res://resources/upgrades/bola_fragmentaria.tres"),
	preload("res://resources/upgrades/brasa_persistente.tres"),
	preload("res://resources/upgrades/fornalha.tres"),
	preload("res://resources/upgrades/leque_estilhacos.tres"),
	preload("res://resources/upgrades/nucleo_estilhacos.tres"),
	preload("res://resources/upgrades/chuva_de_brasas.tres"),
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


static func prerequisites_met(upgrade_id: StringName, ranks: Dictionary) -> bool:
	var definition := definition_for(upgrade_id)
	if definition == null:
		return false
	for required_id in definition.required_upgrades:
		if _rank_for(ranks, StringName(required_id)) <= 0:
			return false
	return true


static func total_rank_count(ranks_by_id: Dictionary) -> int:
	var total: int = 0
	for upgrade_id in known_upgrade_ids():
		total += maxi(int(ranks_by_id.get(upgrade_id, ranks_by_id.get(String(upgrade_id), 0))), 0)
	return total


static func build_offer(
	ranks_by_id: Dictionary,
	room_seed: int,
	room_ordinal: int,
	base_maximum_health: int = 5,
	favor_families: bool = true
) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if total_rank_count(ranks_by_id) >= MAX_RUN_ACQUISITIONS:
		return result

	var fusion: UpgradeDefinitionResource
	var new_candidates: Array[UpgradeDefinitionResource] = []
	var evolution_candidates: Array[UpgradeDefinitionResource] = []
	var post_build_candidates: Array[UpgradeDefinitionResource] = []
	var family_openers: Array[UpgradeDefinitionResource] = []
	var family_continuations: Array[UpgradeDefinitionResource] = []
	for definition in _definitions:
		if definition == null:
			continue
		var rank := _rank_for(ranks_by_id, definition.upgrade_id)
		if not can_acquire(definition.upgrade_id, rank, base_maximum_health):
			continue
		if not prerequisites_met(definition.upgrade_id, ranks_by_id):
			continue
		if definition.upgrade_id == &"forja_magnetica":
			fusion = definition
			continue
		if definition.reward_kind == &"core":
			if favor_families and rank == 0 and not definition.family.is_empty():
				if not definition.required_upgrades.is_empty():
					family_continuations.append(definition)
				elif room_ordinal == 1:
					family_openers.append(definition)
			if rank == 0:
				new_candidates.append(definition)
			else:
				evolution_candidates.append(definition)
		elif definition.reward_kind == &"attribute" or definition.reward_kind == &"recovery":
			post_build_candidates.append(definition)

	var rng := RandomNumberGenerator.new()
	rng.seed = _offer_seed(room_seed, room_ordinal)
	var selected_definitions: Array[UpgradeDefinitionResource] = []
	if fusion != null:
		selected_definitions.append(fusion)
	if not family_continuations.is_empty():
		selected_definitions.append(_take_random(family_continuations, rng))
	elif not family_openers.is_empty():
		selected_definitions.append(_take_random(family_openers, rng))
	if fusion != null or not new_candidates.is_empty() or not evolution_candidates.is_empty():
		if not new_candidates.is_empty() and not evolution_candidates.is_empty():
			for pool in [new_candidates, evolution_candidates]:
				if selected_definitions.size() >= 3:
					break
				var candidates: Array[UpgradeDefinitionResource] = []
				var pool_is_represented := false
				for candidate: UpgradeDefinitionResource in pool:
					if selected_definitions.has(candidate):
						pool_is_represented = true
					else:
						candidates.append(candidate)
				if not pool_is_represented and not candidates.is_empty():
					selected_definitions.append(_take_random(candidates, rng))

		var remaining: Array[UpgradeDefinitionResource] = []
		for definition in new_candidates:
			if not selected_definitions.has(definition):
				remaining.append(definition)
		for definition in evolution_candidates:
			if not selected_definitions.has(definition):
				remaining.append(definition)
		while selected_definitions.size() < 3 and not remaining.is_empty():
			selected_definitions.append(_take_random(remaining, rng))
	if new_candidates.is_empty() and evolution_candidates.is_empty():
		for definition in post_build_candidates:
			if selected_definitions.size() >= 3:
				break
			selected_definitions.append(definition)

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
	var rank_max := max_rank_for(upgrade_id, base_maximum_health)
	var reaches_maximum := next_rank >= rank_max
	var rank_status := "NOVO" if current_rank == 0 else "EVOLUIR"
	if definition.reward_kind == &"attribute":
		rank_status = "AJUSTE" if current_rank == 0 else "AJUSTAR"
	elif definition.reward_kind == &"recovery":
		rank_status = "MANUTENÇÃO"
	if reaches_maximum and definition.reward_kind != &"recovery":
		rank_status += " - MÁXIMO"
	return {
		"upgrade_id": definition.upgrade_id,
		"definition": definition,
		"title": definition.title,
		"description": definition.description,
		"reward_kind": definition.reward_kind,
		"rarity": definition.rarity,
		"rank_before": current_rank,
		"rank_after": next_rank,
		"rank_max": rank_max,
		"rank_status": rank_status,
		"rank_is_maximum": reaches_maximum and definition.reward_kind != &"recovery",
		"rank_label": rank_status,
		"effect_summary": effect_summary(upgrade_id, current_rank, next_rank, base_maximum_health),
		"topics": card_topics(upgrade_id, current_rank, next_rank, base_maximum_health),
		"icon": definition.icon,
	}

static func card_topics(
	upgrade_id: Variant,
	current_rank: int,
	next_rank: int,
	base_maximum_health: int = 5
) -> PackedStringArray:
	var definition := definition_for(upgrade_id)
	if definition == null:
		return PackedStringArray()
	var rank_gain: int = maxi(next_rank - current_rank, 0)
	match definition.upgrade_id:
		&"impacto_reforcado":
			var current_damage_bonus: int = maxi(current_rank, 0) * definition.projectile_damage_per_rank
			var next_damage_bonus: int = maxi(next_rank, 0) * definition.projectile_damage_per_rank
			var damage_topic: String
			if current_rank == 0:
				damage_topic = "Dano inicial: +%d" % (next_damage_bonus - current_damage_bonus)
			else:
				damage_topic = "Dano inicial: +%d > +%d" % [current_damage_bonus, next_damage_bonus]
			return PackedStringArray([
				damage_topic,
				"Primeiro dano aceito",
				"Antes da 1a parede",
			])
		&"motor_acelerado":
			var current_cooldown := dash_cooldown_for_rank(current_rank)
			var next_cooldown := dash_cooldown_for_rank(next_rank)
			var current_speed_bonus := roundi((dash_shot_speed_multiplier_for_rank(current_rank) - 1.0) * 100.0)
			var next_speed_bonus := roundi((dash_shot_speed_multiplier_for_rank(next_rank) - 1.0) * 100.0)
			var dash_shot_topic: String
			if current_rank == 0:
				dash_shot_topic = "Dash tiro: +%d%%" % (next_speed_bonus - current_speed_bonus)
			else:
				dash_shot_topic = "Dash tiro: %d%% > %d%%" % [current_speed_bonus, next_speed_bonus]
			return PackedStringArray([
				"Recarga: %ss > %ss" % [_format_decimal(current_cooldown), _format_decimal(next_cooldown)],
				dash_shot_topic,
				"Só no disparo em dash",
			])
		&"carga_reativa":
			var charge_enabled: int = 1 if definition.reactive_charge_enabled else 0
			var current_charge: int = maxi(current_rank, 0) * definition.charged_damage_bonus_per_rank * charge_enabled
			var next_charge: int = maxi(next_rank, 0) * definition.charged_damage_bonus_per_rank * charge_enabled
			var charge_topic: String
			if current_rank == 0:
				charge_topic = "Dano extra: +%d" % (next_charge - current_charge)
			else:
				charge_topic = "Dano extra: +%d > +%d" % [current_charge, next_charge]
			return PackedStringArray([charge_topic, "No próximo acerto", "Soma a Impacto/Pressão"])
		&"ricochete_pressao":
			var current_wall_bonus: int = maxi(current_rank, 0) * definition.environmental_bounce_damage_per_rank
			var next_wall_bonus: int = maxi(next_rank, 0) * definition.environmental_bounce_damage_per_rank
			var pressure_topic: String
			if current_rank == 0:
				pressure_topic = "Parede: +%d dano" % (next_wall_bonus - current_wall_bonus)
			else:
				pressure_topic = "Parede: +%d > +%d" % [current_wall_bonus, next_wall_bonus]
			return PackedStringArray([
				pressure_topic,
				"Até %d paredes por bola" % definition.environmental_bounce_damage_count_cap,
				"Tiro de ricochete",
			])
		&"mola_retorno":
			var current_bounces: int = BASE_PROJECTILE_CONFIG.max_bounces + projectile_bounce_bonus(current_rank)
			var next_bounces: int = BASE_PROJECTILE_CONFIG.max_bounces + projectile_bounce_bonus(next_rank)
			var current_lifetime: float = BASE_PROJECTILE_CONFIG.lifetime + projectile_lifetime_bonus(current_rank)
			var next_lifetime: float = BASE_PROJECTILE_CONFIG.lifetime + projectile_lifetime_bonus(next_rank)
			if current_rank == 0:
				var bounce_gain: int = rank_gain * definition.max_bounces_per_rank
				var bounce_label: String = "rebote" if bounce_gain == 1 else "rebotes"
				var duration_gain: float = rank_gain * definition.lifetime_per_rank
				return PackedStringArray([
					"+%d %s da bola" % [bounce_gain, bounce_label],
					"+%ss de duração" % _format_decimal(duration_gain),
					"Mais ricochetes",
				])
			return PackedStringArray([
				"Rebotes: %d > %d" % [current_bounces, next_bounces],
				"Duração: %ss > %ss" % [_format_decimal(current_lifetime), _format_decimal(next_lifetime)],
				"Mais ricochetes",
			])
		&"dinamo_defesa":
			var current_refund: float = dash_refund_seconds(current_rank)
			var next_refund: float = dash_refund_seconds(next_rank)
			var refund_topic: String
			if current_rank == 0:
				refund_topic = "Dash: -%ss" % _format_decimal(next_refund - current_refund)
			else:
				refund_topic = "Redução: %ss > %ss" % [
					_format_decimal(current_refund),
					_format_decimal(next_refund),
				]
			return PackedStringArray([refund_topic, "Aparada bem-sucedida", "Uma vez por rebatida"])
		&"chassi_reforcado":
			var base_health: int = maxi(base_maximum_health, 1)
			var current_health: int = mini(base_health + maxi(current_rank, 0) * definition.maximum_health_per_rank, 100)
			var next_health: int = mini(base_health + maxi(next_rank, 0) * definition.maximum_health_per_rank, 100)
			var health_gain: int = maxi(next_health - current_health, 0)
			var recovered: int = acquisition_heal(upgrade_id, current_rank, next_rank)
			var health_topic: String
			if current_rank == 0:
				health_topic = "Vida máxima: +%d" % health_gain
			else:
				health_topic = "Vida máxima: %d > %d" % [current_health, next_health]
			return PackedStringArray([
				health_topic,
				"Cura na escolha: +%d vida" % recovered,
			])
		&"ajuste_velocidade_bola":
			var current_multiplier := projectile_speed_multiplier_for_rank(current_rank)
			var next_multiplier := projectile_speed_multiplier_for_rank(next_rank)
			var gain_percent := roundi((next_multiplier - current_multiplier) * 100.0)
			var current_percent := roundi((current_multiplier - 1.0) * 100.0)
			var next_percent := roundi((next_multiplier - 1.0) * 100.0)
			return PackedStringArray([
				"Bola: +" + str(gain_percent) + "% base",
				"Total: " + str(current_percent) + "% > " + str(next_percent) + "%",
			])
		&"ajuste_recarga_dash":
			var motor_rank := max_rank_for(&"motor_acelerado")
			var current_cooldown := dash_cooldown_with_adjustment(motor_rank, current_rank)
			var next_cooldown := dash_cooldown_with_adjustment(motor_rank, next_rank)
			return PackedStringArray([
				"Recarga: %ss > %ss" % [_format_decimal(current_cooldown), _format_decimal(next_cooldown)],
				"Dash: -%ss" % _format_decimal(definition.dash_cooldown_reduction_per_rank),
			])
		&"reparo_campo":
			return PackedStringArray(["Cura: até 1 de vida", "Aplicada nesta escolha"])
		&"bola_incandescente":
			if current_rank > 0:
				return PackedStringArray(["Após rebater a bola", "Rastro dura +0,25s"])
		&"bola_magnetica":
			if current_rank > 0:
				return PackedStringArray(["Curva mais fechada", "Após bater na parede"])
	return definition.effect_topics.duplicate()


static func effect_summary(
	upgrade_id: Variant,
	current_rank: int,
	next_rank: int,
	base_maximum_health: int = 5
) -> String:
	var topics := card_topics(upgrade_id, current_rank, next_rank, base_maximum_health)
	if topics.is_empty():
		var definition := definition_for(upgrade_id)
		return definition.effect_summary if definition != null else ""
	return " / ".join(topics)

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


static func projectile_speed_multiplier_for_rank(rank: int) -> float:
	var definition := definition_for(&"ajuste_velocidade_bola")
	if definition == null:
		return 1.0
	var clamped_rank := clampi(rank, 0, max_rank_for(&"ajuste_velocidade_bola"))
	return 1.0 + float(clamped_rank) * definition.projectile_speed_multiplier_per_rank


static func dash_cooldown_with_adjustment(motor_rank: int, adjustment_rank: int) -> float:
	var motor_cooldown := dash_cooldown_for_rank(motor_rank)
	var definition := definition_for(&"ajuste_recarga_dash")
	if definition == null:
		return motor_cooldown
	var clamped_rank := clampi(adjustment_rank, 0, max_rank_for(&"ajuste_recarga_dash"))
	var reduction := float(clamped_rank) * definition.dash_cooldown_reduction_per_rank
	var minimum_cooldown := minf(motor_cooldown, 0.31)
	return maxf(motor_cooldown - reduction, minimum_cooldown)

static func dash_refund_seconds(rank: int) -> float:
	var definition := definition_for(&"dinamo_defesa")
	return float(maxi(rank, 0)) * definition.dash_cooldown_refund_per_rank if definition != null else 0.0


static func projectile_bounce_bonus(rank: int) -> int:
	var definition := definition_for(&"mola_retorno")
	return maxi(rank, 0) * definition.max_bounces_per_rank if definition != null else 0


static func projectile_lifetime_bonus(rank: int) -> float:
	var definition := definition_for(&"mola_retorno")
	return float(maxi(rank, 0)) * definition.lifetime_per_rank if definition != null else 0.0


static func dash_shot_speed_multiplier_for_rank(rank: int) -> float:
	var definition := definition_for(&"motor_acelerado")
	if definition == null:
		return 1.0
	var clamped_rank := clampi(rank, 0, max_rank_for(&"motor_acelerado"))
	return 1.0 + float(clamped_rank) * definition.dash_shot_speed_multiplier_per_rank

static func maximum_health(base_maximum_health: int, rank: int) -> int:
	var definition := definition_for(&"chassi_reforcado")
	if definition == null:
		return clampi(base_maximum_health, 1, 100)
	return clampi(base_maximum_health + maxi(rank, 0) * definition.maximum_health_per_rank, 1, 100)


static func acquisition_heal(upgrade_id: Variant, previous_rank: int, next_rank: int) -> int:
	var definition := definition_for(upgrade_id)
	if definition == null or definition.health_recovered_per_rank <= 0:
		return 0
	return maxi(next_rank - previous_rank, 0) * definition.health_recovered_per_rank

static func _rank_for(ranks_by_id: Dictionary, upgrade_id: StringName) -> int:
	return maxi(int(ranks_by_id.get(upgrade_id, ranks_by_id.get(String(upgrade_id), 0))), 0)


static func _take_random(candidates: Array[UpgradeDefinitionResource], rng: RandomNumberGenerator) -> UpgradeDefinitionResource:
	var total_weight := 0
	for candidate in candidates:
		total_weight += UPGRADE_RARITY_WEIGHTS[clampi(candidate.rarity, 0, 4)]
	var roll := rng.randi_range(1, total_weight)
	for index in candidates.size():
		roll -= UPGRADE_RARITY_WEIGHTS[clampi(candidates[index].rarity, 0, 4)]
		if roll <= 0:
			return candidates.pop_at(index)
	return candidates.pop_back()


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
