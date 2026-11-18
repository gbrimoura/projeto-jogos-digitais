extends RefCounted

## Prototipo ajustavel em codigo; pesos e valores nao sao balanceamento final.
enum Rarity { COMUM, INCOMUM, RARO, EPICO, LENDARIO }

const ROLLING_RETURN_SPEED_BONUS_PER_LEVEL: float = 0.25
const ROLLING_NEXT_SHOT_DAMAGE_BONUS: int = 1
const GUARD_PARRY_SPEED_BONUS_PER_LEVEL: float = 0.05
const GUARD_PARRY_SPEED_MAX_BONUS: float = 0.25
const TURBINE_BOUNCE_SPEED_BONUS_PER_LEVEL: float = 0.08
const TURBINE_BOUNCE_SPEED_MAX_BONUS: float = 0.40

const ITEM_IDS: Array[StringName] = [
	&"bolsa_magnetica", &"mola_salto", &"punho_guarda", &"kit_remendo", &"fusivel_aegis",
	&"catraca_sucata", &"rolamento_livre", &"turbina_centrifuga", &"bobina_ritmo", &"fusivel_emergencia",
	&"camara_termica", &"nucleo_indutor",
]
const RARITY_LABELS: Array[String] = ["COMUM", "INCOMUM", "RARO", "EPICO", "LENDARIO"]
const RARITY_COLORS: Array[Color] = [
	Color("#B6BEC3"), Color("#62C6A5"), Color("#52BAC7"), Color("#BD83D4"), Color("#D2A75C")
]

static func known_item_ids() -> Array[StringName]:
	return ITEM_IDS.duplicate()

static func is_known_item_id(item_id: Variant) -> bool:
	return (typeof(item_id) == TYPE_STRING or typeof(item_id) == TYPE_STRING_NAME) and ITEM_IDS.has(StringName(item_id))

static func max_level_for(item_id: StringName) -> int:
	match item_id:
		&"bolsa_magnetica": return 3
		&"mola_salto": return 1
		&"punho_guarda": return 2
		&"kit_remendo": return 3
		&"fusivel_aegis": return 1
		&"catraca_sucata": return 1
		&"rolamento_livre": return 2
		&"turbina_centrifuga": return 2
		&"bobina_ritmo": return 1
		&"fusivel_emergencia", &"camara_termica", &"nucleo_indutor": return 1
	return 0

static func guard_parry_speed_bonus_per_success(level: int) -> float:
	return float(clampi(level, 0, max_level_for(&"punho_guarda"))) * GUARD_PARRY_SPEED_BONUS_PER_LEVEL

static func rarity_for(item_id: StringName) -> int:
	match item_id:
		&"bolsa_magnetica": return Rarity.COMUM
		&"mola_salto": return Rarity.INCOMUM
		&"punho_guarda": return Rarity.RARO
		&"kit_remendo": return Rarity.EPICO
		&"fusivel_aegis": return Rarity.LENDARIO
		&"catraca_sucata": return Rarity.COMUM
		&"rolamento_livre": return Rarity.INCOMUM
		&"turbina_centrifuga": return Rarity.RARO
		&"bobina_ritmo": return Rarity.EPICO
		&"fusivel_emergencia": return Rarity.LENDARIO
		&"camara_termica", &"nucleo_indutor": return Rarity.INCOMUM
	return -1

static func rarity_label(rarity: int) -> String:
	return RARITY_LABELS[rarity] if rarity >= 0 and rarity < RARITY_LABELS.size() else ""

static func rarity_color(rarity: int) -> Color:
	return RARITY_COLORS[rarity] if rarity >= 0 and rarity < RARITY_COLORS.size() else Color.WHITE

static func display_name(item_id: StringName) -> String:
	match item_id:
		&"bolsa_magnetica": return "BOLSA MAGNETICA"
		&"mola_salto": return "MOLA DE SALTO"
		&"punho_guarda": return "PUNHO DE GUARDA"
		&"kit_remendo": return "KIT DE REMENDO"
		&"fusivel_aegis": return "FUSIVEL AEGIS"
		&"catraca_sucata": return "CATRACA SUCATA"
		&"rolamento_livre": return "ROLAMENTO LIVRE"
		&"turbina_centrifuga": return "TURBINA CENTRIFUGA"
		&"bobina_ritmo": return "BOBINA RITMO"
		&"fusivel_emergencia": return "FUSIVEL EMERGENCIA"
		&"camara_termica": return "CÂMARA TÉRMICA"
		&"nucleo_indutor": return "NÚCLEO INDUTOR"
	return ""

static func description(item_id: StringName) -> String:
	match item_id:
		&"bolsa_magnetica": return "Cada coleta rende sucata extra"
		&"mola_salto": return "Guarda um dash extra para o ar"
		&"punho_guarda": return "Arco maior e bola rápida na aparada"
		&"kit_remendo": return "Cura ao vencer combate"
		&"fusivel_aegis": return "Bloqueia o primeiro dano"
		&"catraca_sucata": return "Retorno rende sucata"
		&"rolamento_livre": return "Retorno dá força ao tiro"
		&"turbina_centrifuga": return "Ricochetes aceleram"
		&"bobina_ritmo": return "Aparada aérea dá dash"
		&"fusivel_emergencia": return "Dano adianta o dash"
		&"camara_termica": return "Acende o rastro da bola"
		&"nucleo_indutor": return "Curva a bola após rebote"
	return ""

static func family_for(item_id: StringName) -> String:
	match item_id:
		&"camara_termica", &"nucleo_indutor": return "ELEMENTAL"
		&"punho_guarda", &"turbina_centrifuga": return "IMPULSO"
		&"catraca_sucata", &"rolamento_livre": return "RETORNO"
		&"mola_salto", &"bobina_ritmo": return "AÉREO"
		&"kit_remendo", &"fusivel_aegis", &"fusivel_emergencia": return "DEFESA"
		&"bolsa_magnetica": return "COLETA"
	return ""

static func topics(item_id: StringName) -> PackedStringArray:
	match item_id:
		&"bolsa_magnetica": return PackedStringArray(["Coleta: +1 sucata", "Nao amplia Catraca", "Limite: 3 niveis"])
		&"mola_salto": return PackedStringArray(["Dash aereo: +1", "Ajuda a aparar no ar", "Bobina: 2 usos/sala"])
		&"punho_guarda": return PackedStringArray(["Arco: +8 graus/nível", "Aparada: +5%/nível", "Turbina: teto +56%"])
		&"kit_remendo": return PackedStringArray(["Apos combate: cura", "Cura: +1 HP/nivel", "Limite: 3 niveis"])
		&"fusivel_aegis": return PackedStringArray(["Anula o primeiro dano", "Aegis evita Emergencia", "Limite: 1 nivel"])
		&"catraca_sucata": return PackedStringArray(["Retorno: +1 sucata", "Uma vez por sala", "Rolamento: +2 dano"])
		&"rolamento_livre": return PackedStringArray(["Retorno: +25%/nivel", "Proximo tiro: +1 dano", "Catraca: tiro +2 dano"])
		&"turbina_centrifuga": return PackedStringArray(["Parede: +8%/nível", "Teto: +40% por tiro", "Punho: teto +56%"])
		&"bobina_ritmo": return PackedStringArray(["Aparada aerea: +1 dash", "Uma vez por sala", "Com Mola: 2 usos/sala"])
		&"fusivel_emergencia": return PackedStringArray(["Dano aceito: -0,5s", "Uma vez por sala", "Aegis nao conta"])
		&"camara_termica": return PackedStringArray(["Rastro causa 1 dano", "Com Núcleo: Forja"])
		&"nucleo_indutor": return PackedStringArray(["Atrai após ricochete", "Com Câmara: Forja"])
	return PackedStringArray()

static func synergy_partner(item_id: StringName) -> StringName:
	match item_id:
		&"camara_termica": return &"nucleo_indutor"
		&"nucleo_indutor": return &"camara_termica"
		&"punho_guarda": return &"turbina_centrifuga"
		&"turbina_centrifuga": return &"punho_guarda"
		&"catraca_sucata": return &"rolamento_livre"
		&"rolamento_livre": return &"catraca_sucata"
		&"mola_salto": return &"bobina_ritmo"
		&"bobina_ritmo": return &"mola_salto"
	return &""

static func rarity_weight(rarity: int, floor_index: int) -> int:
	if rarity < 0 or rarity >= RARITY_LABELS.size():
		return 0
	if floor_index <= 1:
		return [54, 28, 12, 5, 1][rarity]
	if floor_index == 2:
		return [45, 29, 17, 7, 2][rarity]
	if floor_index == 3:
		return [38, 29, 20, 10, 3][rarity]
	return [30, 27, 22, 15, 6][rarity]

static func card_preview(item_id: StringName, current_level: int) -> Dictionary:
	if not is_known_item_id(item_id) or current_level < 0 or current_level >= max_level_for(item_id):
		return {}
	var rarity := rarity_for(item_id)
	return {
		"item_id": item_id, "title": display_name(item_id), "description": description(item_id),
		"topics": topics(item_id), "rank_before": current_level, "rank_after": current_level + 1,
		"rank_max": max_level_for(item_id), "rarity": rarity,
		"rarity_label": rarity_label(rarity), "rarity_color": rarity_color(rarity), "family": family_for(item_id),
	}

static func build_offer(item_levels_by_id: Dictionary, seed_value: int, floor_index: int) -> Dictionary:
	var eligible_by_rarity: Dictionary = {}
	for item_id in ITEM_IDS:
		var level: Variant = item_levels_by_id.get(item_id, item_levels_by_id.get(String(item_id), 0))
		if typeof(level) != TYPE_INT or int(level) < 0 or int(level) >= max_level_for(item_id):
			continue
		var rarity := rarity_for(item_id)
		if not eligible_by_rarity.has(rarity):
			eligible_by_rarity[rarity] = []
		eligible_by_rarity[rarity].append(item_id)
	if eligible_by_rarity.is_empty():
		return {}
	var rarities: Array = eligible_by_rarity.keys()
	rarities.sort()
	var total_weight := 0
	for rarity in rarities:
		total_weight += rarity_weight(int(rarity), floor_index)
	if total_weight <= 0:
		return {}
	var rng := RandomNumberGenerator.new()
	rng.seed = seed_value
	var roll := rng.randi_range(1, total_weight)
	var selected_rarity := -1
	for rarity in rarities:
		roll -= rarity_weight(int(rarity), floor_index)
		if roll <= 0:
			selected_rarity = int(rarity)
			break
	if selected_rarity < 0:
		return {}
	var candidates: Array = eligible_by_rarity[selected_rarity]
	var weighted_items: Array[StringName] = []
	for item_id: StringName in candidates:
		weighted_items.append(item_id)
		var partner := synergy_partner(item_id)
		if partner != &"" and int(item_levels_by_id.get(partner, item_levels_by_id.get(String(partner), 0))) > 0:
			weighted_items.append(item_id)
			weighted_items.append(item_id)
	var selected_item: StringName = weighted_items[rng.randi_range(0, weighted_items.size() - 1)]
	var current_level := int(item_levels_by_id.get(selected_item, item_levels_by_id.get(String(selected_item), 0)))
	return card_preview(selected_item, current_level)
