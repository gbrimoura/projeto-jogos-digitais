class_name BounceResolver
extends RefCounted

## Regras puras de reflexão e deslizamento para a bola e para o preview.

static func reflect_velocity(
	incoming_velocity: Vector2,
	collision_normal: Vector2,
	target_speed: float
) -> Vector2:
	var normal := collision_normal.normalized()
	if normal.is_zero_approx():
		return incoming_velocity
	if not should_bounce(incoming_velocity, normal):
		return incoming_velocity

	var reflected := incoming_velocity.bounce(normal)
	if target_speed <= 0.0 or reflected.is_zero_approx():
		return reflected
	return reflected.normalized() * target_speed

static func slide_velocity(
	incoming_velocity: Vector2,
	collision_normal: Vector2,
	target_speed: float
) -> Vector2:
	var normal := collision_normal.normalized()
	if normal.is_zero_approx():
		return incoming_velocity
	var slid := incoming_velocity.slide(normal)
	if target_speed <= 0.0 or slid.is_zero_approx():
		return slid
	return slid.normalized() * target_speed

static func should_bounce(incoming_velocity: Vector2, collision_normal: Vector2) -> bool:
	var normal := collision_normal.normalized()
	if normal.is_zero_approx() or incoming_velocity.is_zero_approx():
		return false
	return incoming_velocity.normalized().dot(normal) < -0.05
