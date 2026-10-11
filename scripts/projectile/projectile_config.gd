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

@export_range(0, 3, 1)
var max_bounces: int = 3

@export_range(1, 100, 1)
var damage: int = 1

## Preparação tipada para a fase C; a etapa A não executa a carga.
@export var reactive_charge_enabled: bool = false
@export_range(0, 100, 1)
var charged_damage_bonus: int = 0

## World (layer 1) plus Damageable (layer 4).
@export_flags_2d_physics
var collision_mask: int = 9

@export_range(0.0, 4.0, 0.1)
var collision_skin: float = 1.0

@export_range(0.01, 0.5, 0.01)
var collision_safe_margin: float = 0.08

@export_range(1, 4, 1)
var max_collisions_per_tick: int = 2
