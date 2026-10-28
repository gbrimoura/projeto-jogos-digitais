class_name TrancaLataDust
extends Node2D

const MAX_PARTICLES: int = 14
const GRID_SIZE: float = 2.0
const MAX_LIFETIME: float = 0.45

var _rng := RandomNumberGenerator.new()
var _particles: Array[Dictionary] = []

func _ready() -> void:
	_rng.randomize()
	set_process(false)

func burst(world_origin: Vector2) -> void:
	_particles.clear()
	global_position = Vector2(
		roundf(world_origin.x / GRID_SIZE) * GRID_SIZE,
		roundf(world_origin.y / GRID_SIZE) * GRID_SIZE
	)
	for index in range(MAX_PARTICLES):
		var side := -1.0 if index % 2 == 0 else 1.0
		var size := _rng.randi_range(2, 3) * int(GRID_SIZE)
		var color_index := _rng.randi_range(0, 2)
		var color := Color("#373f4d")
		match color_index:
			1:
				color = Color("#70432c")
			2:
				color = Color("#925a36")
		var outward_offset := float(_rng.randi_range(18, 24))
		var start_x := side * outward_offset - (float(size) if side < 0.0 else 0.0)
		var start_y := -float(size + _rng.randi_range(1, 4))
		_particles.append({
			"position": Vector2(
				start_x,
				start_y
			),
			"velocity": Vector2(
				side * _rng.randf_range(10.0, 28.0),
				-_rng.randf_range(18.0, 46.0)
			),
			"age": 0.0,
			"lifetime": _rng.randf_range(0.3, MAX_LIFETIME),
			"size": size,
			"color": color,
			"sway_phase": _rng.randf_range(0.0, TAU),
			"sway_speed": _rng.randf_range(5.0, 9.0),
			"sway_amount": _rng.randf_range(1.0, 3.0)
		})
	set_process(true)
	queue_redraw()

func clear() -> void:
	_particles.clear()
	set_process(false)
	queue_redraw()

func _process(delta: float) -> void:
	var step := maxf(delta, 0.0)
	for index in range(_particles.size() - 1, -1, -1):
		var particle: Dictionary = _particles[index]
		particle["age"] = float(particle["age"]) + step
		if float(particle["age"]) >= float(particle["lifetime"]):
			_particles.remove_at(index)
			continue
		var position: Vector2 = particle["position"]
		var velocity: Vector2 = particle["velocity"]
		particle["position"] = position + velocity * step
		_particles[index] = particle
	if _particles.is_empty():
		set_process(false)
	queue_redraw()

func _draw() -> void:
	for particle in _particles:
		var age := float(particle["age"])
		var lifetime := maxf(float(particle["lifetime"]), 0.0001)
		var progress := clampf(age / lifetime, 0.0, 1.0)
		var initial_size := int(particle["size"])
		var maximum_shrink_steps := int(float(initial_size) / GRID_SIZE) - 1
		var shrink_steps := mini(int(progress * 3.0), maximum_shrink_steps)
		var size := initial_size - shrink_steps * int(GRID_SIZE)
		var phase := float(particle["sway_phase"]) + age * float(particle["sway_speed"])
		var sway := sin(phase) * float(particle["sway_amount"])
		var particle_position: Vector2 = particle["position"]
		var draw_position := particle_position + Vector2(sway, 0.0)
		var snapped_x := roundf(draw_position.x / GRID_SIZE) * GRID_SIZE
		var snapped_y := roundf(draw_position.y / GRID_SIZE) * GRID_SIZE
		var color: Color = particle["color"]
		draw_rect(
			Rect2(Vector2(snapped_x, snapped_y), Vector2(size, size)),
			color,
			true
		)
