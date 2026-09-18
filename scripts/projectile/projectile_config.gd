class_name ProjectileConfig
extends Resource

@export_range(100.0, 2000.0, 10.0)
var speed: float = 760.0

@export_range(0.1, 10.0, 0.1)
var lifetime: float = 2.2

@export_range(2.0, 16.0, 0.5)
var collision_radius: float = 8.0

@export_range(0.0, 80.0, 0.5)
var spawn_offset: float = 48.0
