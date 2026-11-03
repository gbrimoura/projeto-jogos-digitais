class_name HudDashPanel
extends Control

const ICON_READY: Texture2D = preload("res://assets/ui/hud_caldeira_v1/export/dash-icon-ready-16.png")
const ICON_DISABLED: Texture2D = preload("res://assets/ui/hud_caldeira_v1/export/dash-icon-disabled-16.png")
const CLOCK_STATES: Array[Texture2D] = [
	preload("res://assets/ui/hud_caldeira_v1/export/clock-step-00.png"),
	preload("res://assets/ui/hud_caldeira_v1/export/clock-step-01.png"),
	preload("res://assets/ui/hud_caldeira_v1/export/clock-step-02.png"),
	preload("res://assets/ui/hud_caldeira_v1/export/clock-step-03.png"),
	preload("res://assets/ui/hud_caldeira_v1/export/clock-step-04.png"),
	preload("res://assets/ui/hud_caldeira_v1/export/clock-step-05.png"),
	preload("res://assets/ui/hud_caldeira_v1/export/clock-step-06.png"),
	preload("res://assets/ui/hud_caldeira_v1/export/clock-step-07.png"),
	preload("res://assets/ui/hud_caldeira_v1/export/clock-step-08.png"),
	preload("res://assets/ui/hud_caldeira_v1/export/clock-step-09.png"),
	preload("res://assets/ui/hud_caldeira_v1/export/clock-step-10.png"),
	preload("res://assets/ui/hud_caldeira_v1/export/clock-step-11.png"),
	preload("res://assets/ui/hud_caldeira_v1/export/clock-step-12.png"),
	preload("res://assets/ui/hud_caldeira_v1/export/clock-step-13.png"),
	preload("res://assets/ui/hud_caldeira_v1/export/clock-step-14.png"),
	preload("res://assets/ui/hud_caldeira_v1/export/clock-step-15.png"),
	preload("res://assets/ui/hud_caldeira_v1/export/clock-step-16.png"),
]

@onready var _icon: TextureRect = $Icon
@onready var _clock: TextureRect = $Clock
@onready var _time_text: Control = $TimeText
@onready var _status_text: Control = $StatusText

func set_dash(state: StringName, remaining: float, duration: float) -> void:
	show()
	var normalized_remaining: float = 0.0
	if state == &"COOLDOWN" and duration > 0.0:
		normalized_remaining = clampf(remaining / duration, 0.0, 1.0)
	var clock_index: int = clampi(int(floor(normalized_remaining * 16.0 + 0.5)), 0, CLOCK_STATES.size() - 1)
	_clock.texture = CLOCK_STATES[clock_index]
	if state == &"READY":
		_icon.texture = ICON_READY
		_time_text.call("set_text", "DASH")
		_status_text.call("set_text", "PRONTO")
	elif state == &"COOLDOWN":
		_icon.texture = ICON_DISABLED
		var rounded_tenths: int = maxi(int(ceil(maxf(remaining - 0.000001, 0.0) * 10.0)), 1)
		var seconds_text: String = ("%.1f" % (float(rounded_tenths) / 10.0)).replace(".", ",")
		_time_text.call("set_text", "DASH %ss" % seconds_text)
		_status_text.call("set_text", "RECARREGANDO")
	elif state == &"ACTIVE":
		_icon.texture = ICON_DISABLED
		_time_text.call("set_text", "DASH")
		_status_text.call("set_text", "EM DASH")
	else:
		_icon.texture = ICON_DISABLED
		_time_text.call("set_text", "DASH")
		_status_text.call("set_text", "INDISPONÍVEL")