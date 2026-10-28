extends Node2D

var _radius: float = 140.0
@export_range(1.0, 2.0, 0.01) var shockwave_visual_scale: float = 1.25
var _phase: StringName = &"hidden"
var _opacity: float = 0.0
var _shockwave_progress: float = 0.0

@onready var _shockwave: AnimatedSprite2D = $Shockwave

func set_area_state(radius: float, center_offset: Vector2, phase: StringName, opacity: float) -> void:
	_radius = maxf(radius, 0.0)
	position = center_offset
	_phase = phase
	_opacity = clampf(opacity, 0.0, 1.0)
	visible = _phase != &"hidden" and _opacity > 0.001
	queue_redraw()
	_sync_shockwave()

func set_shockwave_progress(progress: float) -> void:
	_shockwave_progress = clampf(progress, 0.0, 1.0)
	_sync_shockwave()

func _sync_shockwave() -> void:
	if not is_instance_valid(_shockwave):
		return
	_shockwave.scale = Vector2.ONE * (_radius / 70.0) * shockwave_visual_scale
	_shockwave.pause()
	var show_recovery_tail := _phase == &"recovery" and _shockwave_progress > 0.0 and _shockwave_progress < 1.0
	if _phase != &"active" and _phase != &"impact" and not show_recovery_tail:
		if _phase != &"recovery":
			_shockwave_progress = 0.0
		_shockwave.visible = false
		if _shockwave.sprite_frames != null and _shockwave.sprite_frames.has_animation(&"impact"):
			if _shockwave.animation != &"impact":
				_shockwave.animation = &"impact"
			if _shockwave.sprite_frames.get_frame_count(&"impact") > 0:
				_shockwave.frame = 0
		return
	_shockwave.visible = true
	_select_shockwave_frame()

func _select_shockwave_frame() -> void:
	if _shockwave.sprite_frames == null or not _shockwave.sprite_frames.has_animation(&"impact"):
		return
	var frames := _shockwave.sprite_frames.get_frame_count(&"impact")
	if frames <= 0:
		return
	if _shockwave.animation != &"impact":
		_shockwave.animation = &"impact"
	var total_weight := 0.0
	for frame_index in frames:
		total_weight += _shockwave.sprite_frames.get_frame_duration(&"impact", frame_index)
	var elapsed := _shockwave_progress * total_weight
	var cumulative := 0.0
	var selected_frame := frames - 1
	for frame_index in frames:
		cumulative += _shockwave.sprite_frames.get_frame_duration(&"impact", frame_index)
		if elapsed < cumulative:
			selected_frame = frame_index
			break
	_shockwave.pause()
	_shockwave.frame = selected_frame

func _draw() -> void:
	if not visible or _radius <= 0.0:
		return

	var fill_alpha := 0.045
	var outline_alpha := 0.88
	var outline_width := 2.0
	var color := Color(1.0, 0.27, 0.055)
	match _phase:
		&"windup":
			color = Color(1.0, 0.32, 0.055)
			fill_alpha = 0.055
			outline_alpha = 0.82
		&"active":
			color = Color(1.0, 0.16, 0.035)
			fill_alpha = 0.09
			outline_alpha = 1.0
			outline_width = 3.0
		&"impact":
			color = Color(1.0, 0.76, 0.24)
			fill_alpha = 0.13
			outline_alpha = 1.0
			outline_width = 4.0
		&"recovery":
			color = Color(1.0, 0.27, 0.055)
			fill_alpha = 0.035
			outline_alpha = 0.55

	draw_circle(Vector2.ZERO, _radius, Color(color.r, color.g, color.b, fill_alpha * _opacity))
	draw_arc(
		Vector2.ZERO,
		_radius,
		0.0,
		TAU,
		96,
		Color(color.r, color.g, color.b, outline_alpha * _opacity),
		outline_width,
		true
	)
