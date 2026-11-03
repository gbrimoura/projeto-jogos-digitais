class_name EnemyLevelConfigResource
extends Resource

@export_range(1.0, 5.0, 0.01) var health_multiplier_per_level: float = 0.12
@export_range(0, 10, 1) var damage_increase_every_levels: int = 10
@export_range(0, 10, 1) var maximum_damage_bonus: int = 2
@export_range(0.0, 0.1, 0.001) var cooldown_multiplier_reduction_per_level: float = 0.015
@export_range(0.1, 1.0, 0.01) var minimum_cooldown_multiplier: float = 0.65

func health_for_level(base_health: int, level: int) -> int:
	var scale: float = 1.0 + maxf(level - 1, 0) * maxf(health_multiplier_per_level, 0.0)
	return maxi(ceili(float(maxi(base_health, 1)) * scale), 1)

func damage_for_level(base_damage: int, level: int) -> int:
	var steps := maxi(damage_increase_every_levels, 1)
	var bonus := mini(maxi(floori(float(maxi(level - 1, 0)) / float(steps)), 0), maxi(maximum_damage_bonus, 0))
	return maxi(base_damage, 0) + bonus

func cooldown_multiplier_for_level(level: int) -> float:
	return maxf(minimum_cooldown_multiplier, 1.0 - maxf(float(level - 1), 0.0) * maxf(cooldown_multiplier_reduction_per_level, 0.0))
