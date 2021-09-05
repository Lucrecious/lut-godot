class_name Input_User
extends Input_Abstract

func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	
	emit_signal('unhandled_input', event)
