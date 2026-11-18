class_name ShopOffer
extends CanvasLayer

signal closed

const UpgradeCatalogScript = preload("res://scripts/progression/upgrade_catalog.gd")
const UpgradeCardScene: PackedScene = preload("res://scenes/ui/upgrade_card.tscn")
const ShopItemCardScene: PackedScene = preload("res://scenes/shop/shop_item_card.tscn")
const ShopItemCatalogScript = preload("res://scripts/progression/shop_item_catalog.gd")
const STAGE_SIZE: Vector2 = Vector2(576.0, 324.0)

@onready var _stage: Control = $Stage
@onready var _close_button: Button = $Stage/CloseShop
@onready var _refresh_button: Button = $Stage/RefreshShop
@onready var _portrait: TextureRect = $Stage/VendorPortrait
@onready var _greeting: HudBitmapText = $Stage/VendorGreeting
@onready var _heading: HudBitmapText = $Stage/Heading
@onready var _hint: HudBitmapText = $Stage/Hint
@onready var _cards_row: HBoxContainer = $Stage/Cards
@onready var _price_labels: Array[HudBitmapText] = [
	$Stage/Prices/Price0 as HudBitmapText,
	$Stage/Prices/Price1 as HudBitmapText,
	$Stage/Prices/Price2 as HudBitmapText,
]

var _controller: Node
var _room: Node
var _player: Node
var _font_bundle: Dictionary = {}
var _rows: Array[Dictionary] = []
var _cards: Array[UpgradeCard] = []
var _open: bool = false
var _has_greeted: bool = false
var _refresh_price: int = -1

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED
	layer = 40
	_close_button.pressed.connect(_on_close_pressed)
	_refresh_button.pressed.connect(_on_refresh_pressed)
	set_process_unhandled_key_input(false)
	_font_bundle = UpgradeCard.load_card_font_bundle()
	if bool(_font_bundle.get("valid", false)):
		_heading.configure_font(_font_bundle)
		_hint.configure_font(_font_bundle)
		_greeting.configure_font(_font_bundle)
	for price_label in _price_labels:
		if bool(_font_bundle.get("valid", false)):
			price_label.configure_font(_font_bundle)
		price_label.center_text = true
		price_label.max_lines = 1
	var viewport := get_viewport()
	if viewport != null and not viewport.size_changed.is_connected(_layout_stage):
		viewport.size_changed.connect(_layout_stage)
	_layout_stage()
	hide()

func present(controller: Node, room: Node, player: Node, state: Dictionary) -> bool:
	var raw_offers: Variant = state.get("offers", [])
	if (
		typeof(raw_offers) != TYPE_ARRAY or raw_offers.size() > 3
		or not bool(_font_bundle.get("valid", false))
	):
		return false
	var next_rows: Array[Dictionary] = []
	var next_ids: Array[StringName] = []
	for raw_offer: Variant in raw_offers:
		if typeof(raw_offer) != TYPE_DICTIONARY:
			return false
		var offer: Dictionary = raw_offer
		var row_variant: Variant = offer.get("row", {})
		if typeof(row_variant) != TYPE_DICTIONARY:
			return false
		var row: Dictionary = row_variant
		var kind: StringName = StringName(offer.get("kind", &"upgrade"))
		var offer_id: StringName = StringName(offer.get("offer_id", offer.get("upgrade_id", &"")))
		if (
			offer_id.is_empty() or next_ids.has(offer_id)
			or typeof(offer.get("price")) != TYPE_INT or int(offer.get("price", -1)) < 0
		):
			return false
		if kind == &"item":
			var item_id: StringName = StringName(offer.get("item_id", &""))
			if (
				item_id != offer_id or not ShopItemCatalogScript.is_known_item_id(item_id)
				or StringName(row.get("item_id", &"")) != item_id
			):
				return false
		elif kind == &"upgrade":
			var definition: UpgradeDefinitionResource = row.get("definition") as UpgradeDefinitionResource
			if definition == null or definition.upgrade_id != offer_id:
				return false
		else:
			return false
		next_rows.append(offer.duplicate(true))
		next_ids.append(offer_id)
	# Configure in a hidden staging node so failed refreshes preserve the current cards.
	var staging := Control.new()
	staging.hide()
	_stage.add_child(staging)
	var next_cards: Array[UpgradeCard] = []
	for offer: Dictionary in next_rows:
		var row: Dictionary = offer["row"]
		var kind := StringName(offer["kind"])
		var scene := ShopItemCardScene if kind == &"item" else UpgradeCardScene
		var card := scene.instantiate() as UpgradeCard
		if card == null:
			staging.queue_free()
			return false
		staging.add_child(card)
		var configured := bool(card.call("configure_item", row, _font_bundle)) if kind == &"item" else card.configure(row, _font_bundle)
		if not configured:
			staging.queue_free()
			return false
		next_cards.append(card)
	_controller = controller
	_room = room
	_player = player
	_rows = next_rows
	_clear_cards()
	for index in next_cards.size():
		var card: UpgradeCard = next_cards[index]
		var offer: Dictionary = _rows[index]
		card.reparent(_cards_row, false)
		card.pressed.connect(_on_card_pressed.bind(index))
		card.disabled = bool(offer.get("purchased", false))
		_cards.append(card)
		var price_label: HudBitmapText = _price_labels[index]
		price_label.font_color = Color("#62c6a5") if card.disabled else Color("#d2a75c")
		price_label.set_text("COMPRADO" if card.disabled else "PREÇO %d" % int(offer.get("price", 0)))
		price_label.show()
	for index in range(_rows.size(), _price_labels.size()):
		_price_labels[index].hide()
	staging.queue_free()
	_refresh_price = int(state.get("refresh_price", -1))
	_refresh_button.disabled = _refresh_price < 0
	_refresh_button.text = "RENOVAR  %d SUCATAS" % _refresh_price if _refresh_price >= 0 else "LIMITE ATINGIDO"
	_set_balance(int(state.get("scrap", 0)))
	_hint.set_text("ESTOQUE ESGOTADO" if _rows.is_empty() else "ESCOLHA UMA PEÇA")
	_set_vendor_line("OLÁ DE NOVO. TEM PEÇAS NO BALCÃO." if _has_greeted else "BEM-VINDO. DÁ UMA OLHADA NAS PEÇAS.", 1)
	_has_greeted = true
	_open = true
	set_process_unhandled_key_input(true)
	show()
	_layout_stage()
	_close_button.grab_focus()
	for card in _cards:
		if not card.disabled:
			card.grab_focus()
			break
	return true
func _on_refresh_pressed() -> void:
	if not _open or _refresh_price < 0 or not is_instance_valid(_controller):
		return
	if int(_controller.get("temporary_scrap")) < _refresh_price:
		_hint.set_text("SEM SUCATA PARA RENOVAR")
		return
	if bool(_controller.call("refresh_shop_stock", _room, _refresh_price, _present_refreshed_stock)):
		_hint.set_text("ESTOQUE RENOVADO")
		_set_vendor_line("CHEGARAM OUTRAS PEÇAS.", 2)
	else:
		_hint.set_text("SEM NOVO ESTOQUE. NADA COBRADO.")

func _present_refreshed_stock(state: Dictionary) -> bool:
	return present(_controller, _room, _player, state)

func _on_close_pressed() -> void:
	close_offer()

func close_offer(emit_closed: bool = true) -> void:
	if not _open and not visible:
		return
	_open = false
	set_process_unhandled_key_input(false)
	for card in _cards:
		if is_instance_valid(card):
			card.disabled = true
	hide()
	if emit_closed:
		closed.emit()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and (event as InputEventKey).echo:
		return
	if event.is_action_pressed(&"interact") or event.is_action_pressed(&"ui_cancel"):
		get_viewport().set_input_as_handled()
		close_offer()

func _on_card_pressed(index: int) -> void:
	if not _open or index < 0 or index >= _rows.size() or index >= _cards.size():
		return
	if not is_instance_valid(_controller) or not is_instance_valid(_room) or not is_instance_valid(_player):
		close_offer()
		return
	var offer: Dictionary = _rows[index]
	var offer_id: StringName = StringName(offer.get("offer_id", offer.get("upgrade_id", &"")))
	var price: int = int(offer.get("price", -1))
	var purchased: bool = bool(_controller.call("purchase_shop_offer", _room, index, offer_id, price))
	if purchased:
		_cards[index].disabled = true
		_price_labels[index].font_color = Color("#62c6a5")
		_price_labels[index].set_text("COMPRADO")
		var current_scrap: int = int(_controller.get("temporary_scrap"))
		var refreshed_variant: Variant = _controller.call("get_shop_offer_state", _room)
		if typeof(refreshed_variant) == TYPE_DICTIONARY:
			var refreshed: Dictionary = refreshed_variant
			current_scrap = int(refreshed.get("scrap", current_scrap))
		_set_balance(current_scrap)
		_hint.set_text("COMPRA REALIZADA")
		_set_vendor_line("VALEU PELA COMPRA. BOA SORTE NA SUBIDA.", 2)
		return
	var current_scrap: int = int(_controller.get("temporary_scrap"))
	if current_scrap < price:
		var missing := price - current_scrap
		_hint.set_text("FALTA 1 SUCATA" if missing == 1 else "FALTAM %d SUCATAS" % missing)
		_set_vendor_line("GUARDO A PEÇA ATÉ VOCÊ VOLTAR.", 4)
	else:
		_hint.set_text("OFERTA INDISPONÍVEL")
func _set_vendor_line(line: String, frame: int) -> void:
	_greeting.set_text(line)
	var atlas := _portrait.texture as AtlasTexture
	if atlas != null:
		atlas.region = Rect2(frame * 64, 0, 64, 64)

func _set_balance(value: int) -> void:
	_heading.set_text("LOJA DE SUCATA   /   SALDO %d" % maxi(value, 0))

func _clear_cards() -> void:
	_cards.clear()
	for child: Node in _cards_row.get_children():
		_cards_row.remove_child(child)
		child.queue_free()

func _layout_stage() -> void:
	if _stage == null or get_viewport() == null:
		return
	var viewport_size: Vector2 = get_viewport().get_visible_rect().size
	var integer_scale: int = maxi(floori(minf(viewport_size.x / STAGE_SIZE.x, viewport_size.y / STAGE_SIZE.y)), 1)
	var scaled_size: Vector2 = STAGE_SIZE * float(integer_scale)
	_stage.scale = Vector2.ONE * float(integer_scale)
	_stage.position = ((viewport_size - scaled_size) * 0.5).floor()

func _exit_tree() -> void:
	close_offer(false)