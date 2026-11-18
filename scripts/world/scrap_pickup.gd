class_name ScrapPickup
extends Area2D

@export_range(1, 20, 1) var amount: int = 1
@export_range(0.03, 0.5, 0.01) var frame_duration: float = 0.12
@export_range(0.0, 8.0, 0.5) var bob_height: float = 2.0

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D

var _elapsed: float = 0.0
var _initial_y: float = 0.0
var _collected: bool = false


func _ready() -> void:
	add_to_group("run_pickup")
	_initial_y = position.y
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if _collected:
		return
	_elapsed += delta
	var frame: int = int(floor(_elapsed / maxf(frame_duration, 0.03))) % 4
	_sprite.region_rect = Rect2(float(frame * 16), 0.0, 16.0, 16.0)
	position.y = _initial_y + sin(_elapsed * 4.0) * bob_height


func _on_body_entered(body: Node2D) -> void:
	if _collected or not body.is_in_group("player"):
		return
	for controller: Node in get_tree().get_nodes_in_group("run_controller"):
		if not controller.has_method("register_temporary_scrap"):
			continue
		if bool(controller.call("register_temporary_scrap", amount)):
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