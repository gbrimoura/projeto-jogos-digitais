class_name HudRoomProgressPanel
extends Control

@onready var _floor_text: Control = $FloorText
@onready var _room_text: Control = $RoomText

func set_progress(floor_index: int, floor_total: int, room_index: int, room_total: int, is_boss: bool) -> void:
	show()
	_floor_text.call("set_text", "ANDAR %02d/%02d" % [floor_index, floor_total])
	if is_boss:
		_room_text.call("set_text", "CHEFE")
	else:
		_room_text.call("set_text", "SALA %d/%d" % [room_index, room_total])