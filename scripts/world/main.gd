extends Node2D

const PLAYER_SPAWN := Vector2(160.0, 560.0)

@onready var player: Player = $Player

func _physics_process(_delta: float) -> void:
	if player.global_position.y > 760.0:
		player.reset_to_spawn(PLAYER_SPAWN)
