extends RefCounted

## Transferência única de vida para a cena de destino configurada pelo controlador.
## Não é um autoload: permanece vazia em inícios normais e em recargas por derrota.

static var _pending_health_transfer: Dictionary = {}

static func prepare_health_transfer(
	destination_scene_path: String,
	current_health: int,
	maximum_health: int
) -> void:
	_pending_health_transfer = {
		"destination_scene_path": destination_scene_path,
		"current_health": current_health,
		"maximum_health": maximum_health,
	}

static func apply_pending_health_transfer(
	destination_scene_path: String,
	target_health: PlayerHealth
) -> bool:
	if _pending_health_transfer.is_empty():
		return false
	var payload := _pending_health_transfer.duplicate()
	_pending_health_transfer.clear()
	if str(payload.get("destination_scene_path", "")) != destination_scene_path:
		return false

	var saved_current_health := int(payload.get("current_health", 0))
	var saved_maximum_health := int(payload.get("maximum_health", 0))
	if target_health == null or not is_instance_valid(target_health):
		return false
	return target_health.restore_health_for_room_transition(
		saved_current_health,
		saved_maximum_health
	)

static func clear_pending_health_transfer(destination_scene_path: String) -> void:
	if str(_pending_health_transfer.get("destination_scene_path", "")) == destination_scene_path:
		_pending_health_transfer.clear()
