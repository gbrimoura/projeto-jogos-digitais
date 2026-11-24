class_name HudBallGaugePanel
extends Control

const HUB := Vector2(42.0, 32.0)
const START_ANGLE: float = PI * 0.82
const END_ANGLE: float = PI * 2.18
const REFERENCE_SPEED: float = 760.0
const FULL_SCALE_RATIO: float = 5.0
const TICK_COUNT: int = 15
const FACE_DARK := Color("#0C1B29")
const TRACK_COLOR := Color("#203E50")
const BRASS := Color("#B78342")
const IVORY := Color("#F4ECD8")
const TEAL := Color("#52BAC7")
const AMBER := Color("#F3B75E")
const REDLINE := Color("#E9795E")

@export var enabled: bool = false:
	set(value):
		enabled = value
		visible = enabled

@onready var _reading: HudBitmapText = $Reading

var _speed: float = 0.0
var _needle_ratio: float = 0.0
var _impact_pulse: float = 0.0

func _ready() -> void:
	visible = enabled
	set_process(_speed > 0.0)
	_update_reading()

func set_enabled(value: bool) -> void:
	enabled = value

func set_ball_speed(value: float) -> void:
	var speed := maxf(value, 0.0)
	if is_equal_approx(speed, _speed):
		return
	if speed > _speed and _speed > 0.0:
		_impact_pulse = 1.0
	_speed = speed
	if not is_node_ready():
		return
	_update_reading()
	set_process(true)

func _update_reading() -> void:
	_reading.set_text(str(roundi(_speed)))
	_reading.font_color = REDLINE if _dial_progress(_speed / REFERENCE_SPEED) >= 0.80 else IVORY

func _process(delta: float) -> void:
	var target_ratio := _dial_progress(_speed / REFERENCE_SPEED)
	_needle_ratio = lerpf(_needle_ratio, target_ratio, 1.0 - exp(-24.0 * delta))
	_impact_pulse = move_toward(_impact_pulse, 0.0, delta * 5.0)
	if absf(_needle_ratio - target_ratio) < 0.002 and _impact_pulse <= 0.0:
		_needle_ratio = target_ratio
		set_process(false)
	queue_redraw()

# Give ordinary shots more dial travel while reserving the red zone for item stacks.
func _dial_progress(speed: float) -> float:
	if speed <= 1.0:
		return speed * 0.30
	if speed <= 1.6:
		return remap(speed, 1.0, 1.6, 0.30, 0.72)
	return remap(minf(speed, FULL_SCALE_RATIO), 1.6, FULL_SCALE_RATIO, 0.72, 1.0)

func _draw() -> void:
	var dial_ratio := clampf(_needle_ratio, 0.0, 1.0)
	draw_arc(HUB, 26.0, START_ANGLE, END_ANGLE, 28, BRASS, 2.0, false)
	draw_arc(HUB, 20.0, START_ANGLE, END_ANGLE, 26, TRACK_COLOR, 6.0, false)

	for index in TICK_COUNT:
		var mark := float(index) / float(TICK_COUNT - 1)
		var direction := Vector2.from_angle(lerpf(START_ANGLE, END_ANGLE, mark))
		var major := index % 3 == 0 or index == TICK_COUNT - 1
		var tick_color := TEAL if mark < 0.49 else (AMBER if mark < 0.80 else REDLINE)
		if mark > dial_ratio:
			tick_color = tick_color.darkened(0.64)
		else:
			tick_color = tick_color.lerp(IVORY, _impact_pulse * 0.42)
		draw_line(
			(HUB + direction * (17.0 if major else 19.0)).round(),
			(HUB + direction * 23.0).round(),
			tick_color, 2.0, false
		)

	var heading := Vector2.from_angle(lerpf(START_ANGLE, END_ANGLE, dial_ratio))
	var tip := (HUB + heading * 20.0).round()
	var shoulder := HUB + heading * 6.0
	var side := heading.orthogonal() * 2.0
	draw_colored_polygon(PackedVector2Array([tip, (shoulder + side).round(), (HUB - heading * 5.0).round(), (shoulder - side).round()]), AMBER.lerp(IVORY, _impact_pulse))
	draw_circle(HUB, 5.0, FACE_DARK)
	draw_circle(HUB, 3.0, BRASS.lerp(IVORY, _impact_pulse))
	draw_rect(Rect2(HUB + Vector2(-1.0, -2.0), Vector2(2.0, 1.0)), IVORY)
