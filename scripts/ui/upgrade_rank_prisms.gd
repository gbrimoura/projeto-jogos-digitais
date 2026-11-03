extends Control

enum PrismState { EMPTY, OWNED, OFFERED }

const THREE_RANK_SLOTS: int = 3
const FIVE_RANK_SLOTS: int = 5
const TEN_RANK_SLOTS: int = 10
const PRISM_WIDTH: int = 8
const PRISM_HEIGHT: int = 10
const PRISM_GAP: int = 3

const EMPTY_OUTLINE: Color = Color("59636B")
const EMPTY_HIGHLIGHT: Color = Color("879198")
const EMPTY_SHADOW: Color = Color("142C40")
const NAVY: Color = Color("0C1B29")
const OWNED_OUTLINE: Color = Color("203E50")
const OWNED_FILL: Color = Color("52BAC7")
const OWNED_HIGHLIGHT: Color = Color("B6BEC3")
const OWNED_SHADOW: Color = Color("142C40")
const OFFERED_OUTLINE: Color = Color("70432C")
const OFFERED_FILL: Color = Color("D2A75C")
const OFFERED_HIGHLIGHT: Color = Color("E8D8B5")
const OFFERED_SHADOW: Color = Color("925A36")

var _slot_count: int = 0
var _owned_slots: int = 0
var _offered_slot: int = -1

func configure_rank(rank_before: int, rank_after: int, rank_max: int, reward_kind: StringName) -> bool:
	if reward_kind == &"recovery":
		_hide_prisms()
		return true
	if rank_before < 0 or rank_after <= rank_before or rank_max < rank_after or rank_max <= 0:
		return false
	_slot_count = _slots_for_maximum(rank_max)
	if _slot_count == 0:
		_hide_prisms()
		return true
	_owned_slots = clampi(rank_before, 0, _slot_count)
	_offered_slot = _owned_slots if _owned_slots < _slot_count else -1
	visible = true
	queue_redraw()
	return true

func _slots_for_maximum(rank_max: int) -> int:
	if rank_max == THREE_RANK_SLOTS:
		return THREE_RANK_SLOTS
	if rank_max == FIVE_RANK_SLOTS:
		return FIVE_RANK_SLOTS
	if rank_max == TEN_RANK_SLOTS:
		return TEN_RANK_SLOTS
	return 0

func _hide_prisms() -> void:
	_slot_count = 0
	_owned_slots = 0
	_offered_slot = -1
	visible = false
	queue_redraw()

func _draw() -> void:
	if _slot_count <= 0:
		return
	var total_width: int = _slot_count * PRISM_WIDTH + (_slot_count - 1) * PRISM_GAP
	var start_x: int = floori((size.x - float(total_width)) * 0.5)
	var start_y: int = floori((size.y - float(PRISM_HEIGHT)) * 0.5)
	for slot in range(_slot_count):
		var state: PrismState = PrismState.EMPTY
		if slot < _owned_slots:
			state = PrismState.OWNED
		elif slot == _offered_slot:
			state = PrismState.OFFERED
		_draw_prism(start_x + slot * (PRISM_WIDTH + PRISM_GAP), start_y, state)

func _draw_prism(x: int, y: int, state: PrismState) -> void:
	var outline := EMPTY_OUTLINE
	var fill := NAVY
	var highlight := EMPTY_HIGHLIGHT
	var shadow := EMPTY_SHADOW
	if state == PrismState.OWNED:
		outline = OWNED_OUTLINE
		fill = OWNED_FILL
		highlight = OWNED_HIGHLIGHT
		shadow = OWNED_SHADOW
	elif state == PrismState.OFFERED:
		outline = OFFERED_OUTLINE
		fill = OFFERED_FILL
		highlight = OFFERED_HIGHLIGHT
		shadow = OFFERED_SHADOW

	_pixel_rect(x + 2, y, 4, 1, outline)
	_pixel_rect(x + 1, y + 1, 6, 1, outline)
	_pixel_rect(x, y + 2, 1, 6, outline)
	_pixel_rect(x + 7, y + 2, 1, 6, outline)
	_pixel_rect(x + 1, y + 8, 6, 1, outline)
	_pixel_rect(x + 2, y + 9, 4, 1, outline)

	_pixel_rect(x + 2, y + 1, 4, 1, fill)
	_pixel_rect(x + 1, y + 2, 6, 6, fill)
	_pixel_rect(x + 2, y + 8, 4, 1, fill)
	_pixel_rect(x + 2, y + 1, 4, 1, highlight)
	_pixel_rect(x + 5, y + 2, 2, 3, highlight)
	_pixel_rect(x + 1, y + 2, 2, 3, shadow)
	_pixel_rect(x + 3, y + 2, 2, 5, fill)
	_pixel_rect(x + 1, y + 5, 2, 3, fill)
	_pixel_rect(x + 5, y + 5, 2, 3, fill)
	_pixel_rect(x + 2, y + 7, 4, 1, shadow)

func _pixel_rect(x: int, y: int, width: int, height: int, color: Color) -> void:
	draw_rect(Rect2(Vector2(x, y), Vector2(width, height)), color, true, -1.0, false)