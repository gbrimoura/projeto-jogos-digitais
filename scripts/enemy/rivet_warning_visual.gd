extends Node2D

const COLOR_NAVY := Color("#192031")
const COLOR_SLOT := Color("#373F4D")
const COLOR_AMBER := Color("#F5A84F")
const COLOR_RED := Color("#F0524E")

const DASH_LENGTH: float = 8.0
const DASH_GAP: float = 5.0
const CORE_WIDTH: float = 3.0
const IMMINENCE_START: float = 0.70
const CHARGE_THRESHOLDS := [0.20, 0.48, 0.72]
const METER_SEGMENT_SIZE := Vector2(4.0, 4.0)
const METER_GAP: float = 2.0
const METER_OFFSET := Vector2(0.0, 16.0)

var _warning_line: Line2D
var _warning_mark: Node2D
var _warning_stem: Polygon2D
var _warning_dot: Polygon2D
var _progress: float = 0.0

func configure(warning_line: Line2D, warning_mark: Node2D) -> void:
    _warning_line = warning_line
    _warning_mark = warning_mark
    _warning_stem = warning_mark.get_node_or_null("WarningStem") as Polygon2D
    _warning_dot = warning_mark.get_node_or_null("WarningDot") as Polygon2D
    _set_marker_color(COLOR_AMBER)
    queue_redraw()

func set_progress(progress: float, force_redraw: bool = false) -> void:
    var next_progress := clampf(progress, 0.0, 1.0)
    if is_equal_approx(_progress, next_progress) and not force_redraw:
        return
    _progress = next_progress
    _set_marker_color(_get_phase_color())
    queue_redraw()

func _draw() -> void:
    if not is_instance_valid(_warning_line):
        return
    _draw_segmented_trajectory()
    _draw_charge_meter()

func _draw_segmented_trajectory() -> void:
    var points := _warning_line.points
    if points.size() < 2:
        return
    var color := _get_phase_color()
    for point_index in range(points.size() - 1):
        var segment_start := points[point_index]
        var segment_delta := points[point_index + 1] - segment_start
        var segment_length := segment_delta.length()
        if segment_length <= 0.01:
            continue
        var direction := segment_delta / segment_length
        var distance := 0.0
        while distance < segment_length:
            var dash_end := minf(distance + DASH_LENGTH, segment_length)
            draw_line(
                segment_start + direction * distance,
                segment_start + direction * dash_end,
                color,
                CORE_WIDTH,
                false
            )
            distance += DASH_LENGTH + DASH_GAP

func _draw_charge_meter() -> void:
    if not is_instance_valid(_warning_mark):
        return
    var mark_origin := to_local(_warning_mark.to_global(Vector2.ZERO))
    var segment_count := CHARGE_THRESHOLDS.size()
    var total_width := float(segment_count) * METER_SEGMENT_SIZE.x + float(segment_count - 1) * METER_GAP
    var meter_origin := mark_origin + METER_OFFSET - Vector2(total_width * 0.5, 0.0)
    for index in range(segment_count):
        var segment_position := meter_origin + Vector2(float(index) * (METER_SEGMENT_SIZE.x + METER_GAP), 0.0)
        var segment_rect := Rect2(segment_position, METER_SEGMENT_SIZE)
        draw_rect(segment_rect, COLOR_NAVY)
        var inset_rect := segment_rect.grow(-1.0)
        var is_charged := _progress >= float(CHARGE_THRESHOLDS[index])
        draw_rect(inset_rect, _get_phase_color() if is_charged else COLOR_SLOT)

func _get_phase_color() -> Color:
    var imminence := clampf((_progress - IMMINENCE_START) / (1.0 - IMMINENCE_START), 0.0, 1.0)
    imminence = imminence * imminence * (3.0 - 2.0 * imminence)
    return COLOR_AMBER.lerp(COLOR_RED, imminence)

func _set_marker_color(color: Color) -> void:
    if is_instance_valid(_warning_stem):
        _warning_stem.color = color
    if is_instance_valid(_warning_dot):
        _warning_dot.color = color