class_name UserDirectionalInput
extends IDirectionalInput

export(String) var left := ''
export(String) var right := ''
export(String) var up := ''
export(String) var down := ''

onready var direction_actions := [left, right, up, down]

var _direction := Vector2.ZERO
func get_direction() -> Vector2:
	return _direction

func _unhandled_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	
	for action in direction_actions:
		if not event.is_action(action):
			continue
		
		var value := Input.get_vector(left, right, up, down)
		if value.is_equal_approx(_direction):
			return
		
		_direction = value
		get_tree().set_input_as_handled()
		emit_signal('direction_changed')
		return
