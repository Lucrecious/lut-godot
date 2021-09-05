class_name Prompt_WaitForKey
extends WindowDialog

const deadzone := .5

var _last_valid_input_event: InputEvent

func last_valid_input_event() -> InputEvent:
	return _last_valid_input_event

func reset() -> void:
	_last_valid_input_event = null

func _input(event: InputEvent) -> void:
	if event is InputEventJoypadButton or event is InputEventKey or event is InputEventJoypadMotion:
		if event is InputEventJoypadMotion:
			if abs(event.axis_value) < deadzone:
				return
			else:
				_last_valid_input_event = event.duplicate()
				_last_valid_input_event.axis_value = sign(event.axis_value)
		else:
			_last_valid_input_event = event
	else:
		return
	
	hide()
