class_name UpgradeOffer
extends CanvasLayer

signal upgrade_selected(upgrade_id: StringName)

const UpgradeCatalogScript = preload("res://scripts/progression/upgrade_catalog.gd")
const UpgradeCardScene: PackedScene = preload("res://scenes/ui/upgrade_card.tscn")
const STAGE_SIZE: Vector2 = Vector2(576.0, 324.0)

@onready var _stage: Control = $Stage
@onready var _heading: HudBitmapText = $Stage/Heading
@onready var _hint: HudBitmapText = $Stage/Hint
@onready var _cards_row: HBoxContainer = $Stage/Cards

var _offered_ids: Array[StringName] = []
var _cards: Array[UpgradeCard] = []
var _font_bundle: Dictionary = {}
var _selection_emitted: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	set_process_unhandled_key_input(false)
	_font_bundle = UpgradeCard.load_card_font_bundle()
	if bool(_font_bundle.get("valid", false)):
		_heading.configure_font(_font_bundle)
		_hint.configure_font(_font_bundle)
	_heading.set_text("ESCOLHA UMA MELHORIA")
	_hint.set_text("UMA ESCOLHA POR SALA")
	var viewport: Viewport = get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_layout_stage):
		viewport.size_changed.connect(_layout_stage)
	_layout_stage()
	hide()

func present_options(
	options: Array,
	ranks_by_id: Dictionary = {},
	base_maximum_health: int = 5
) -> bool:
	if options.is_empty() or options.size() > 3 or not bool(_font_bundle.get("valid", false)):
		return false
	var next_cards: Array[Dictionary] = []
	var next_ids: Array[StringName] = []
	for option: Variant in options:
		var definition: UpgradeDefinitionResource
		var current_rank: int = 0
		if option is UpgradeDefinitionResource:
			definition = option as UpgradeDefinitionResource
			current_rank = int(ranks_by_id.get(definition.upgrade_id, ranks_by_id.get(String(definition.upgrade_id), 0)))
		elif typeof(option) == TYPE_DICTIONARY:
			var source_row: Dictionary = option
			definition = source_row.get("definition") as UpgradeDefinitionResource
			if definition != null:
				current_rank = int(source_row.get(
					"rank_before",
					ranks_by_id.get(definition.upgrade_id, ranks_by_id.get(String(definition.upgrade_id), 0))
				))
		else:
			return false
		if definition == null or next_ids.has(definition.upgrade_id):
			return false
		var row: Dictionary = UpgradeCatalogScript.card_preview(
			definition.upgrade_id,
			current_rank,
			base_maximum_health
		)
		if row.is_empty():
			return false
		row["definition"] = definition
		row["icon"] = definition.icon
		next_cards.append(row)
		next_ids.append(definition.upgrade_id)

	_clear_cards()
	for index in range(next_cards.size()):
		var card: UpgradeCard = UpgradeCardScene.instantiate() as UpgradeCard
		if card == null:
			_clear_cards()
			return false
		_cards_row.add_child(card)
		if not card.configure(next_cards[index], _font_bundle):
			_cards_row.remove_child(card)
			card.queue_free()
			_clear_cards()
			return false
		card.pressed.connect(_on_card_pressed.bind(index))
		_cards.append(card)

	_offered_ids = next_ids
	_selection_emitted = false
	set_process_unhandled_key_input(true)
	show()
	_layout_stage()
	_cards[0].grab_focus()
	return true

func close_offer() -> void:
	set_process_unhandled_key_input(false)
	for card in _cards:
		if is_instance_valid(card):
			card.disabled = true
	hide()

func _unhandled_key_input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") or event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()

func _on_card_pressed(index: int) -> void:
	if _selection_emitted or index < 0 or index >= _offered_ids.size():
		return
	_selection_emitted = true
	for card in _cards:
		card.disabled = true
	upgrade_selected.emit(_offered_ids[index])

func _clear_cards() -> void:
	_offered_ids.clear()
	_cards.clear()
	for child: Node in _cards_row.get_children():
		_cards_row.remove_child(child)
		child.queue_free()

func _layout_stage() -> void:
	if _stage == null or get_viewport() == null:
		return
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var integer_scale: int = maxi(floori(minf(
		viewport_size.x / STAGE_SIZE.x,
		viewport_size.y / STAGE_SIZE.y
	)), 1)
	var scaled_size: Vector2 = STAGE_SIZE * float(integer_scale)
	_stage.scale = Vector2.ONE * float(integer_scale)
	_stage.position = ((viewport_size - scaled_size) * 0.5).floor()
