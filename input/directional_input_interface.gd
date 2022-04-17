class_name IDirectionalInput
extends Node

signal direction_changed()

func get_direction() -> Vector2:
	assert(false, 'must be implemented in derived class')
	return Vector2.ZERO
