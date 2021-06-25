class_name Input_User
extends Input_Abstract

func is_action_pressed(action: String) -> bool:
	return Input.is_action_pressed(action)

func _unhandled_input(event: InputEvent) -> void:
	emit_signal('unhandled_input', event)
