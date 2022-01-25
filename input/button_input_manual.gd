class_name ManualButtonInput
extends IButtonInput

var _pressed := {}

func actions() -> PoolStringArray:
	return PoolStringArray()

func press(action: String) -> void:
	if action in _pressed:
		return
	
	_pressed[action] = true
	emit_signal('action_just_pressed', action)

func release(action: String) -> void:
	if not action in _pressed:
		return
	
	_pressed.erase(action)
	emit_signal('action_just_released', action)
