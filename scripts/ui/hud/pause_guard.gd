extends Node

var _content: CanvasItem
var _content_was_visible: bool = true
var _pause_handled: bool = false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_PAUSABLE
	var bridge: Node = get_parent()
	if bridge != null:
		_content = bridge.get_node_or_null("HudRoot/Content") as CanvasItem

func _notification(what: int) -> void:
	if what == NOTIFICATION_PAUSED and is_instance_valid(_content):
		_content_was_visible = _content.visible
		_content.visible = false
		_pause_handled = true
	elif what == NOTIFICATION_UNPAUSED and _pause_handled:
		if is_instance_valid(_content):
			_content.visible = _content_was_visible
		_pause_handled = false