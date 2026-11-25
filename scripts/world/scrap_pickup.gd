class_name ScrapPickup
extends Area2D

const DROP_DURATION: float = 0.32
const DROP_ARC_HEIGHT: float = 24.0

@export_range(1, 20, 1) var amount: int = 1
@export_range(0.03, 0.5, 0.01) var frame_duration: float = 0.12
@export_range(0.0, 8.0, 0.5) var bob_height: float = 2.0

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D

var _elapsed: float = 0.0
var _initial_y: float = 0.0
var _collected: bool = false
var _enemy_drop: bool = false
var _drop_offset: Vector2 = Vector2.ZERO


func configure_enemy_drop(origin_in_room: Vector2) -> void:
	_enemy_drop = true
	_drop_offset = origin_in_room - position
	monitoring = false


func _ready() -> void:
	add_to_group("run_pickup")
	_initial_y = position.y
	_sprite.position = _drop_offset
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if _collected:
		return
	_elapsed += delta
	var frame: int = int(floor(_elapsed / maxf(frame_duration, 0.03))) % 4
	_sprite.region_rect = Rect2(float(frame * 16), 0.0, 16.0, 16.0)
	if _enemy_drop and _elapsed < DROP_DURATION:
		var progress := _elapsed / DROP_DURATION
		_sprite.position = _drop_offset.lerp(Vector2.ZERO, progress) \
			- Vector2(0.0, 4.0 * DROP_ARC_HEIGHT * progress * (1.0 - progress))
		return
	if not monitoring:
		_sprite.position = Vector2.ZERO
		monitoring = true
	var bob_time := _elapsed - (DROP_DURATION if _enemy_drop else 0.0)
	position.y = _initial_y + sin(bob_time * 4.0) * bob_height


func _on_body_entered(body: Node2D) -> void:
	var player := body as Player
	if _collected or player == null or player.is_dead or player.get_parent() != get_parent():
		return
	for controller: Node in get_tree().get_nodes_in_group("run_controller"):
		if not controller.has_method("is_active_room_instance") \
			or not bool(controller.call("is_active_room_instance", get_parent())):
			continue
		if bool(controller.call("register_temporary_scrap", amount, not _enemy_drop)):
			_collect()
			return


func _collect() -> void:
	_collected = true
	set_deferred("monitoring", false)
	if _collision != null:
		_collision.set_deferred("disabled", true)
	var tween: Tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ZERO, 0.12)
	tween.finished.connect(queue_free)