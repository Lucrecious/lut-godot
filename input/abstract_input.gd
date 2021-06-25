class_name Input_Abstract
extends Node

signal unhandled_input(event)

func is_action_pressed(action: String) -> bool:
	assert(false, 'must be implemented')
	return false
