class_name MovementConfig
extends Resource

## Parametros de prototipo ficam em um Resource para permitir tuning sem
## misturar valores de balanceamento com o fluxo de input ou a cena do jogador.

@export_category("Horizontal")
@export_range(0.0, 1000.0, 1.0)
var move_speed: float = 260.0
@export_range(0.0, 5000.0, 1.0)
var acceleration: float = 1600.0
@export_range(0.0, 5000.0, 1.0)
var deceleration: float = 2200.0

@export_category("Vertical")
@export_range(0.0, 4000.0, 1.0)
var gravity: float = 1600.0
@export_range(0.0, 1500.0, 1.0)
var jump_velocity: float = 640.0
@export_range(0.0, 3000.0, 1.0)
var max_fall_speed: float = 900.0
@export_range(0.0, 0.5, 0.01)
var coyote_time: float = 0.12
@export_range(0.0, 0.5, 0.01)
var jump_buffer_time: float = 0.12
@export_range(0.0, 1.0, 0.01)
var jump_cut_multiplier: float = 0.5

@export_category("Dash")
@export var dash_enabled: bool = false
@export_range(0.0, 3000.0, 1.0)
var dash_speed: float = 720.0
@export_range(0.01, 1.0, 0.01)
var dash_duration: float = 0.14
@export_range(0.0, 3.0, 0.01)
var dash_cooldown: float = 0.55
@export_range(0, 3, 1)
var max_air_dashes: int = 1
