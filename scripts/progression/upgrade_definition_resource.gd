class_name UpgradeDefinitionResource
extends Resource

## Dados imutáveis durante a execução. Efeitos são configurados no recurso e
## lidos para derivar cópias das configurações-base.

@export var upgrade_id: StringName
@export var title: String = ""
@export var icon: Texture2D
@export_multiline var description: String = ""
## Texto de apresentação do efeito, separado da descrição e sem efeito nos cálculos.
@export var effect_summary: String = ""

@export_category("Efeitos provisórios")
@export_range(0, 100, 1) var projectile_damage_override: int = 0
@export_range(-1.0, 3.0, 0.01) var dash_cooldown_override: float = -1.0
@export var reactive_charge_enabled: bool = false
@export_range(0, 100, 1) var charged_damage_bonus: int = 0
