class_name Prompt_WaitForKey
extends WindowDialog


var _last_scancode_pressed: int

func last_scancode_pressed() -> int:
	return _last_scancode_pressed

func reset() -> void:
	_last_scancode_pressed = 0

func _input(event: InputEvent) -> void:
	if not event is InputEventKey:
		return
	
	_last_scancode_pressed = event.scancode
	
	hide()
