class_name ManualDirectionalInput
extends IDirectionalInput

var _direction := Vector2.ZERO
func get_direction() -> Vector2:
	return _direction

func set_direction(direction: Vector2) -> void:
	if not direction.is_equal_approx(Vector2.ZERO) and not direction.is_normalized():
		direction = direction.normalized()
	
	if _direction.is_equal_approx(direction):
		return
	
	_direction = direction
	emit_signal('direction_changed')
