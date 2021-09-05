class_name Input_Virtual
extends Input_Abstract

var _pressed := {}

func release_all() -> void:
	for action in _pressed:
		release(action)

func flash_press(action: String, offset_sec := 0.0) -> void:
	if offset_sec > 0.0:
		yield(get_tree().create_timer(offset_sec), 'timeout')
	
	press(action)
	yield(get_tree(), 'idle_frame')
	yield(get_tree(), 'idle_frame')
	release(action)

func flash_direction_x(direction: int) -> void:
	if direction > 0:
		release('left_move')
		flash_press('right_move')
	elif direction < 0:
		release('right_move')
		flash_press('left_move')

func press_sec(action: String, offset_sec: float, held_sec: float) -> void:
	if offset_sec > 0:
		yield(get_tree().create_timer(offset_sec), 'timeout')
	
	press(action)
	
	yield(get_tree().create_timer(held_sec), 'timeout')
	
	release(action)

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








