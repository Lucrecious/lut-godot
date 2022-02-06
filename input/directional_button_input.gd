class_name DirectionalButtonInput
extends IDirectionalInput

export(String) var left := ''
export(String) var right := ''
export(String) var up := ''
export(String) var down := ''
export(bool) var _handle_input := true

onready var direction_actions := [left, right, up, down]

func _ready() -> void:
	if _handle_input:
		return
	
	set_process_unhandled_input(false)

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
