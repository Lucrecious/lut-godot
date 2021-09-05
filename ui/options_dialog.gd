extends AcceptDialog

func _input(event: InputEvent) -> void:
	if event.is_echo():
		return
	
	if event is InputEventKey and event.scancode == KEY_P and event.is_pressed():
		popup_centered()
		grab_focus()

func _gui_input(event: InputEvent) -> void:
	accept_event()

