class_name UserButtonInput
extends IButtonInput

export(PoolStringArray) var actions := PoolStringArray()

func actions() -> PoolStringArray:
	return actions

func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	
	for a in actions:
		if event.is_action_pressed(a):
			get_tree().set_input_as_handled()
			emit_signal('action_just_pressed', a)
			return
		
		if event.is_action_released(a):
			get_tree().set_input_as_handled()
			emit_signal('action_just_released', a)
			return
