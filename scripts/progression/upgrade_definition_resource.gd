class_name UpgradeDefinitionResource
extends Resource

## Dados imutáveis durante a execução. Efeitos são configurados no recurso e
## lidos para derivar cópias das configurações-base.

@export var upgrade_id: StringName
@export var reward_kind: StringName = &"core"
@export var title: String = ""
@export var icon: Texture2D
@export_multiline var description: String = ""
## Texto de apresentação do efeito, separado da descrição e sem efeito nos cálculos.
@export var effect_summary: String = ""
@export var effect_topics: PackedStringArray = PackedStringArray()

## Serialized compatibility fields from the first three upgrades.
@export_range(0, 100, 1) var projectile_damage_override: int = 0
@export_range(0.0, 2.0, 0.01) var dash_cooldown_override: float = 0.0
@export_range(0, 100, 1) var charged_damage_bonus: int = 0

@export_category("Progressão provisória")
@export_range(1, 220, 1) var rank_cap: int = 1
@export_range(0, 100, 1) var projectile_damage_per_rank: int = 0
@export var dash_cooldown_by_rank: PackedFloat32Array = PackedFloat32Array()
@export var reactive_charge_enabled: bool = false
@export_range(0, 100, 1) var charged_damage_bonus_per_rank: int = 0
@export_range(0, 100, 1) var environmental_bounce_damage_per_rank: int = 0
@export_range(0, 8, 1) var environmental_bounce_damage_count_cap: int = 0
@export_range(0, 3, 1) var max_bounces_per_rank: int = 0
@export_range(0.0, 2.0, 0.01) var lifetime_per_rank: float = 0.0
@export_range(0.0, 1.0, 0.01) var dash_cooldown_refund_per_rank: float = 0.0
@export_range(0, 1, 1) var maximum_health_per_rank: int = 0
@export_range(0.0, 1.0, 0.001) var projectile_speed_multiplier_per_rank: float = 0.0
@export_range(0.0, 1.0, 0.001) var dash_cooldown_reduction_per_rank: float = 0.0
@export_range(0, 1, 1) var health_recovered_per_rank: int = 0
