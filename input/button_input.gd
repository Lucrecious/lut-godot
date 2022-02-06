class_name ButtonInput
extends IButtonInput

export(bool) var _handle_input := true
export(PoolStringArray) var actions := PoolStringArray()

func _ready() -> void:
	if _handle_input:
		return
	
	set_process_unhandled_input(false)

func get_actions() -> PoolStringArray:
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
