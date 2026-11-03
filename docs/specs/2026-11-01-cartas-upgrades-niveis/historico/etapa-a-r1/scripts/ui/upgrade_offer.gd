class_name UpgradeOffer
extends CanvasLayer

signal upgrade_selected(upgrade_id: StringName)

const UpgradeCatalogScript = preload("res://scripts/progression/upgrade_catalog.gd")

@onready var _card_buttons: Array[Button] = [
	$Center/Panel/Content/Cards/ImpactCard as Button,
	$Center/Panel/Content/Cards/MotorCard as Button,
	$Center/Panel/Content/Cards/ChargeCard as Button,
]
@onready var _card_titles: Array[Label] = [
	$Center/Panel/Content/Cards/ImpactCard/CardContent/CardLayout/Title as Label,
	$Center/Panel/Content/Cards/MotorCard/CardContent/CardLayout/Title as Label,
	$Center/Panel/Content/Cards/ChargeCard/CardContent/CardLayout/Title as Label,
]
@onready var _card_descriptions: Array[Label] = [
	$Center/Panel/Content/Cards/ImpactCard/CardContent/CardLayout/Description as Label,
	$Center/Panel/Content/Cards/MotorCard/CardContent/CardLayout/Description as Label,
	$Center/Panel/Content/Cards/ChargeCard/CardContent/CardLayout/Description as Label,
]
@onready var _card_effect_summaries: Array[Label] = [
	$Center/Panel/Content/Cards/ImpactCard/CardContent/CardLayout/EffectSummary as Label,
	$Center/Panel/Content/Cards/MotorCard/CardContent/CardLayout/EffectSummary as Label,
	$Center/Panel/Content/Cards/ChargeCard/CardContent/CardLayout/EffectSummary as Label,
]
@onready var _card_icons: Array[TextureRect] = [
	$Center/Panel/Content/Cards/ImpactCard/CardContent/CardLayout/Icon as TextureRect,
	$Center/Panel/Content/Cards/MotorCard/CardContent/CardLayout/Icon as TextureRect,
	$Center/Panel/Content/Cards/ChargeCard/CardContent/CardLayout/Icon as TextureRect,
]

var _offered_ids: Array[StringName] = []

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	set_process_unhandled_key_input(false)
	for index in range(_card_buttons.size()):
		_card_buttons[index].pressed.connect(_on_card_pressed.bind(index))
	hide()

func present_options(
	options: Array,
	ranks_by_id: Dictionary = {},
	base_maximum_health: int = 5
) -> bool:
	if options.is_empty() or options.size() > _card_buttons.size():
		return false

	var definitions: Array[UpgradeDefinitionResource] = []
	var preview_ranks: Dictionary = ranks_by_id.duplicate(true)
	for option: Variant in options:
		var definition: UpgradeDefinitionResource
		if option is UpgradeDefinitionResource:
			definition = option as UpgradeDefinitionResource
		elif typeof(option) == TYPE_DICTIONARY:
			var row: Dictionary = option
			definition = row.get("definition") as UpgradeDefinitionResource
			if definition != null and row.has("rank_before"):
				preview_ranks[definition.upgrade_id] = int(row.get("rank_before", 0))
		else:
			return false
		if definition == null:
			return false
		definitions.append(definition)

	var next_ids: Array[StringName] = []
	for index in range(definitions.size()):
		var definition := definitions[index]
		if definition == null or String(definition.upgrade_id).is_empty() or next_ids.has(definition.upgrade_id):
			return false
		next_ids.append(definition.upgrade_id)
		_card_titles[index].text = definition.title
		_card_descriptions[index].text = definition.description
		var current_rank := int(preview_ranks.get(definition.upgrade_id, preview_ranks.get(String(definition.upgrade_id), 0)))
		var preview := UpgradeCatalogScript.card_preview(
			definition.upgrade_id,
			current_rank,
			base_maximum_health
		)
		if preview.is_empty():
			return false
		_card_effect_summaries[index].text = "%s %s" % [
			String(preview.get("rank_label", "")),
			String(preview.get("effect_summary", "")),
		]
		_card_icons[index].texture = definition.icon
		_card_icons[index].visible = definition.icon != null
		_card_buttons[index].disabled = false
		_card_buttons[index].show()
		_card_buttons[index].focus_mode = Control.FOCUS_ALL
	for index in range(definitions.size(), _card_buttons.size()):
		_card_buttons[index].disabled = true
		_card_buttons[index].hide()

	_offered_ids = next_ids
	set_process_unhandled_key_input(true)
	show()
	_card_buttons[0].grab_focus()
	return true

func close_offer() -> void:
	set_process_unhandled_key_input(false)
	hide()

func _unhandled_key_input(event: InputEvent) -> void:
	# E never dismisses or queues an interaction behind the paused offer.
	if event.is_action_pressed("interact"):
		get_viewport().set_input_as_handled()

func _on_card_pressed(index: int) -> void:
	if index < 0 or index >= _offered_ids.size():
		return
	upgrade_selected.emit(_offered_ids[index])
