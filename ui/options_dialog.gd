extends AcceptDialog

func _input(event: InputEvent) -> void:
	if event.is_action_pressed('ui_cancel'):
		popup_centered()
