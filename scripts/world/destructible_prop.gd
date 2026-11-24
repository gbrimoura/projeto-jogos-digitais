class_name DestructibleProp
extends StaticBody2D

const CELL_SIZE: int = 48
const ScrapPickupScene: PackedScene = preload("res://scenes/pickups/scrap_pickup.tscn")

@export_range(1, 8, 1) var durability: int = 2
@export_range(0.0, 1.0, 0.01) var break_pause: float = 0.12

@onready var _sprite: Sprite2D = $Sprite2D
@onready var _collision: CollisionShape2D = $CollisionShape2D

var _is_canister: bool = false
var _health: int = 2
var _scrap_amount: int = 1
var _destroying: bool = false
var _shake_tween: Tween


func configure_prop(is_canister: bool, scrap_amount: int) -> void:
	_is_canister = is_canister
	_scrap_amount = maxi(scrap_amount, 0)
	if is_node_ready():
		_update_sprite()


func _ready() -> void:
	add_to_group("damageable")
	_health = maxi(durability, 1)
	_update_sprite()


func take_damage(amount: int, _source: Node = null) -> bool:
	if _destroying or amount <= 0 or _health <= 0:
		return false

	_health = maxi(_health - amount, 0)
	if _health == 0:
		_break_open()
	else:
		_update_sprite()
		_shake()
	return true


func _update_sprite() -> void:
	if _sprite == null:
		return
	var cell: int = 3 if _is_canister else 0
	if _health <= 0:
		cell += 2
	elif _health < maxi(durability, 1):
		cell += 1
	_sprite.region_rect = Rect2(cell * CELL_SIZE, 0, CELL_SIZE, CELL_SIZE)


func _shake() -> void:
	if _shake_tween != null and _shake_tween.is_running():
		_shake_tween.kill()
	_sprite.position.x = 0.0
	_sprite.modulate = Color(1.65, 1.48, 1.22)
	_shake_tween = create_tween()
	_shake_tween.tween_property(_sprite, "position:x", 3.0, 0.035)
	_shake_tween.parallel().tween_property(_sprite, "modulate", Color.WHITE, 0.11)
	_shake_tween.tween_property(_sprite, "position:x", -3.0, 0.04)
	_shake_tween.tween_property(_sprite, "position:x", 0.0, 0.035)


func _break_open() -> void:
	_destroying = true
	if _shake_tween != null and _shake_tween.is_running():
		_shake_tween.kill()
	_sprite.position.x = 0.0
	_sprite.modulate = Color.WHITE
	remove_from_group("damageable")
	if _collision != null:
		_collision.set_deferred("disabled", true)
	_update_sprite()
	call_deferred("_finish_break_after_pause")


func _finish_break_after_pause() -> void:
	if break_pause > 0.0:
		await get_tree().create_timer(break_pause).timeout
	if not is_inside_tree():
		return
	if _scrap_amount > 0:
		var pickup := ScrapPickupScene.instantiate() as ScrapPickup
		pickup.amount = _scrap_amount
		pickup.position = position + Vector2(0.0, 8.0)
		get_parent().add_child(pickup)
	queue_free()