extends RefCounted

const LEFT := Vector2i(-1, 0)
const RIGHT := Vector2i(1, 0)
const UP := Vector2i(0, -1)
const DOWN := Vector2i(0, 1)
const PORTAL_WIDTH := 256.0
const FLOOR_SLOT_TOP := 560.0
const FLOOR_SLOT_BOTTOM := 648.0

var _room: Node2D
var _world: StaticBody2D
var _floor: SolidPlatform
var _floor_shape: CollisionShape2D
var _exit_gate: CollisionShape2D
var _floor_segments: Array[CollisionShape2D] = []
var _floor_exit: bool = false
var _exit_dir := RIGHT
var _exit_offset: float = 496.0
var _is_open: bool = false

func configure(room: Node2D, descriptor: Dictionary) -> Dictionary:
	_room = room
	_world = room.get_node_or_null("WorldCollision") as StaticBody2D
	_floor = room.get_node_or_null("Floor") as SolidPlatform
	if _world == null or _floor == null:
		return {"valid": false, "error": "limites gerenciados precisam de WorldCollision e Floor"}
	_floor_shape = _floor.get_node_or_null("CollisionShape2D") as CollisionShape2D
	if _floor_shape == null or not _floor_shape.shape is RectangleShape2D:
		return {"valid": false, "error": "Floor precisa manter seu CollisionShape2D retangular único"}
	_exit_dir = descriptor.get("exit_dir", RIGHT)
	_exit_offset = float(descriptor.get("exit_offset", 496.0))
	_floor_exit = _exit_dir == DOWN
	_is_open = false

	var gate_name := &"ExitGate"
	if _exit_dir == RIGHT:
		_exit_gate = _world.get_node_or_null("ExitGate") as CollisionShape2D
		if _exit_gate == null:
			return {"valid": false, "error": "ExitGate lateral direita ausente"}
	elif _exit_dir == LEFT:
		var left_wall := _world.get_node_or_null("LeftWall") as CollisionShape2D
		if left_wall == null:
			return {"valid": false, "error": "LeftWall ausente para abertura lateral"}
		left_wall.disabled = true
		_add_shape("ManagedLeftUpper", Vector2(32.0, 216.0), Vector2(64.0, 432.0))
		_add_shape("ManagedLeftLower", Vector2(32.0, 604.0), Vector2(64.0, 88.0))
		_exit_gate = _add_shape("ManagedExitGate", Vector2(32.0, 496.0), Vector2(64.0, 128.0))
		_add_shape("ManagedLeftOuterGuard", Vector2(-4.0, 324.0), Vector2(8.0, 648.0))
		gate_name = &"ManagedExitGate"
	elif _exit_dir == UP:
		for node_name in [&"Ceiling", &"CeilingBand"]:
			var full_band := _world.get_node_or_null(NodePath(String(node_name))) as CollisionShape2D
			if full_band == null:
				return {"valid": false, "error": "limite superior ausente: %s" % String(node_name)}
			full_band.disabled = true
		var left_edge := _exit_offset - PORTAL_WIDTH * 0.5
		var right_edge := _exit_offset + PORTAL_WIDTH * 0.5
		if left_edge > 0.0:
			_add_shape("ManagedCeilingUpperLeft", Vector2(left_edge * 0.5, -16.0), Vector2(left_edge, 32.0))
			_add_shape("ManagedCeilingBandLeft", Vector2(left_edge * 0.5, 32.0), Vector2(left_edge, 64.0))
		if right_edge < 1152.0:
			var right_width := 1152.0 - right_edge
			_add_shape("ManagedCeilingUpperRight", Vector2(right_edge + right_width * 0.5, -16.0), Vector2(right_width, 32.0))
			_add_shape("ManagedCeilingBandRight", Vector2(right_edge + right_width * 0.5, 32.0), Vector2(right_width, 64.0))
		_exit_gate = _add_shape("ManagedExitGate", Vector2(_exit_offset, 16.0), Vector2(PORTAL_WIDTH, 96.0))
		_add_shape("ManagedTopOuterGuard", Vector2(576.0, -52.0), Vector2(1152.0, 8.0))
		gate_name = &"ManagedExitGate"
	elif _exit_dir == DOWN:
		var left_edge := _exit_offset - PORTAL_WIDTH * 0.5
		var right_edge := _exit_offset + PORTAL_WIDTH * 0.5
		var left_shape := _add_shape("ManagedFloorLeft", Vector2(left_edge * 0.5, 604.0), Vector2(left_edge, 88.0), true)
		var right_width := 1152.0 - right_edge
		var right_shape := _add_shape("ManagedFloorRight", Vector2(right_edge + right_width * 0.5, 604.0), Vector2(right_width, 88.0), true)
		_floor_segments = [left_shape, right_shape]
		_exit_gate = _add_shape("ManagedExitGate", Vector2(_exit_offset, 604.0), Vector2(PORTAL_WIDTH, 88.0))
		_add_shape("ManagedBottomCatch", Vector2(_exit_offset, 664.0), Vector2(PORTAL_WIDTH, 8.0))
		gate_name = &"ManagedExitGate"
	else:
		return {"valid": false, "error": "direção de saída gerenciada inválida: %s" % str(_exit_dir)}

	_set_visual_open(false)
	var exit_door := room.get_node_or_null("ExitDoor")
	if exit_door == null or not exit_door.has_method("configure_managed_orientation"):
		return {"valid": false, "error": "ExitDoor não suporta orientação gerenciada"}
	exit_door.set("gate_path", NodePath("../WorldCollision/" + String(gate_name)))
	exit_door.call("configure_managed_orientation", _exit_dir, _exit_offset, true)
	var entrance_door := room.get_node_or_null("EntranceDoor")
	if entrance_door != null and entrance_door.has_method("configure_managed_orientation"):
		entrance_door.call("configure_managed_orientation", descriptor.get("entry_dir", LEFT), float(descriptor.get("entry_offset", 496.0)), false)
	return {"valid": true, "gate": _exit_gate}

func set_exit_open(value: bool) -> void:
	_is_open = value
	if _exit_gate != null and is_instance_valid(_exit_gate):
		_exit_gate.set_deferred("disabled", value)
	if _floor_exit:
		if value:
			_floor_shape.set_deferred("disabled", true)
			for segment in _floor_segments:
				if is_instance_valid(segment):
					segment.set_deferred("disabled", false)
		else:
			for segment in _floor_segments:
				if is_instance_valid(segment):
					segment.set_deferred("disabled", true)
			_floor_shape.set_deferred("disabled", false)
	_set_visual_open(value)

func validate_contract() -> Dictionary:
	if _room == null or _world == null or _floor == null or _floor_shape == null:
		return {"valid": false, "error": "topologia gerenciada não foi configurada"}
	if _is_open or _exit_gate == null or _exit_gate.disabled:
		return {"valid": false, "error": "gate de saída precisa permanecer fechado até a resolução do combate"}
	if not _expect_shape("LeftWall", Vector2(32.0, 324.0), Vector2(64.0, 648.0), _exit_dir == LEFT):
		return {"valid": false, "error": "parede esquerda não corresponde à saída descrita"}
	if not _expect_shape("RightWallUpper", Vector2(1120.0, 216.0), Vector2(64.0, 432.0), false) \
		or not _expect_shape("RightWallLower", Vector2(1120.0, 604.0), Vector2(64.0, 88.0), false):
		return {"valid": false, "error": "parede direita precisa continuar fechada fora do slot de saída"}
	if not _expect_shape("RightOuterGuard", Vector2(1156.0, 324.0), Vector2(8.0, 648.0), false):
		return {"valid": false, "error": "guarda externa direita ausente ou incompatível"}
	if _exit_dir == LEFT:
		if not _expect_shape("ManagedLeftUpper", Vector2(32.0, 216.0), Vector2(64.0, 432.0), false) \
			or not _expect_shape("ManagedLeftLower", Vector2(32.0, 604.0), Vector2(64.0, 88.0), false) \
			or not _expect_shape("ManagedLeftOuterGuard", Vector2(-4.0, 324.0), Vector2(8.0, 648.0), false):
			return {"valid": false, "error": "parede esquerda recortada ou guarda externa incompleta"}
	var ceiling := _world.get_node_or_null("Ceiling") as CollisionShape2D
	var ceiling_band := _world.get_node_or_null("CeilingBand") as CollisionShape2D
	if ceiling == null or ceiling_band == null:
		return {"valid": false, "error": "os dois colliders do teto precisam existir"}
	if _exit_dir == UP:
		if not ceiling.disabled or not ceiling_band.disabled:
			return {"valid": false, "error": "teto completo precisa ser substituído pelos segmentos laterais"}
		var ceiling_left_edge := _exit_offset - PORTAL_WIDTH * 0.5
		var ceiling_right_edge := _exit_offset + PORTAL_WIDTH * 0.5
		if not _expect_shape("ManagedCeilingUpperLeft", Vector2(ceiling_left_edge * 0.5, -16.0), Vector2(ceiling_left_edge, 32.0), false) \
			or not _expect_shape("ManagedCeilingBandLeft", Vector2(ceiling_left_edge * 0.5, 32.0), Vector2(ceiling_left_edge, 64.0), false):
			return {"valid": false, "error": "segmentos esquerdos do teto ausentes ou abertos"}
		var ceiling_right_width := 1152.0 - ceiling_right_edge
		if not _expect_shape("ManagedCeilingUpperRight", Vector2(ceiling_right_edge + ceiling_right_width * 0.5, -16.0), Vector2(ceiling_right_width, 32.0), false) \
			or not _expect_shape("ManagedCeilingBandRight", Vector2(ceiling_right_edge + ceiling_right_width * 0.5, 32.0), Vector2(ceiling_right_width, 64.0), false) \
			or not _expect_shape("ManagedTopOuterGuard", Vector2(576.0, -52.0), Vector2(1152.0, 8.0), false):
			return {"valid": false, "error": "segmentos direitos ou guarda superior ausentes"}
	else:
		if ceiling.disabled or ceiling_band.disabled:
			return {"valid": false, "error": "teto precisa permanecer fechado sem saída superior"}
	if _exit_dir == DOWN:
		var floor_left_edge := _exit_offset - PORTAL_WIDTH * 0.5
		var floor_right_edge := _exit_offset + PORTAL_WIDTH * 0.5
		var floor_right_width := 1152.0 - floor_right_edge
		if _floor_shape.disabled \
			or not _expect_shape("ManagedFloorLeft", Vector2(floor_left_edge * 0.5, 604.0), Vector2(floor_left_edge, 88.0), true) \
			or not _expect_shape("ManagedFloorRight", Vector2(floor_right_edge + floor_right_width * 0.5, 604.0), Vector2(floor_right_width, 88.0), true) \
			or not _expect_shape("ManagedBottomCatch", Vector2(_exit_offset, 664.0), Vector2(PORTAL_WIDTH, 8.0), false):
			return {"valid": false, "error": "piso contínuo de combate ou proteção do hatch inferior está inválido"}
	elif _floor_shape.disabled or _world.get_node_or_null("ManagedFloorLeft") != null \
		or _world.get_node_or_null("ManagedFloorRight") != null:
		return {"valid": false, "error": "piso gerenciado deve permanecer contínuo durante o combate"}
	return {"valid": true}
func _expect_shape(node_name: String, expected_position: Vector2, expected_size: Vector2, expected_disabled: bool) -> bool:
	var collision := _world.get_node_or_null(NodePath(node_name)) as CollisionShape2D
	if collision == null or collision.disabled != expected_disabled \
		or collision.position.distance_to(expected_position) > 0.01 \
		or absf(collision.rotation) > 0.001 \
		or not collision.scale.is_equal_approx(Vector2.ONE):
		return false
	var rectangle := collision.shape as RectangleShape2D
	return rectangle != null and rectangle.size.distance_to(expected_size) <= 0.01
func get_exit_gate() -> CollisionShape2D:
	return _exit_gate

func is_exit_open() -> bool:
	return _is_open

func _set_visual_open(value: bool) -> void:
	var ceiling := _room.get_node_or_null("WallVisuals/CeilingVisual")
	if ceiling != null:
		ceiling.set("opening_center_x", _exit_offset - 576.0)
		ceiling.set("opening_width", PORTAL_WIDTH)
		ceiling.set("opening_enabled", value and _exit_dir == UP)
	var floor_visual := _room.get_node_or_null("Floor/Visuals/FactorySurfaceVisual")
	if floor_visual != null:
		floor_visual.set("opening_center_x", _exit_offset - 576.0)
		floor_visual.set("opening_width", PORTAL_WIDTH)
		floor_visual.set("opening_enabled", value and _floor_exit)
	var left_visual := _room.get_node_or_null("WallVisuals/LeftWallVisual")
	var right_visual := _room.get_node_or_null("WallVisuals/RightWallVisual")
	if left_visual != null:
		left_visual.set("opening_top", 432.0 if value and _exit_dir == LEFT else -1.0)
		left_visual.set("opening_height", 128.0 if value and _exit_dir == LEFT else 0.0)
	if right_visual != null:
		right_visual.set("opening_top", 432.0 if value and _exit_dir == RIGHT else -1.0)
		right_visual.set("opening_height", 128.0 if value and _exit_dir == RIGHT else 0.0)

func _add_shape(node_name: String, position_value: Vector2, size_value: Vector2, initially_disabled: bool = false) -> CollisionShape2D:
	var collision := CollisionShape2D.new()
	collision.name = node_name
	collision.position = position_value
	var rectangle := RectangleShape2D.new()
	rectangle.resource_local_to_scene = true
	rectangle.size = size_value
	collision.shape = rectangle
	collision.disabled = initially_disabled
	_world.add_child(collision)
	return collision