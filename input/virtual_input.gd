class_name Input_Virtual
extends Input_Abstract

var _pressed := {}

func is_action_pressed(action: String) -> bool:
	return _pressed.get(action, false)

func press(action: String) -> void:
	var is_pressed := _pressed.get(action, false) as bool
	if is_pressed: return
	
	_pressed[action] = true
	var input_event := InputEventAction.new()
	input_event.action = action
	input_event.pressed = true
	emit_signal('unhandled_input', input_event)

func release(action: String) -> void:
	var is_pressed := _pressed.get(action, false) as bool
	if not is_pressed: return
	
	_pressed[action] = false
	var input_event := InputEventAction.new()
	input_event.action = action
	input_event.pressed = false
	emit_signal('unhandled_input', input_event)








