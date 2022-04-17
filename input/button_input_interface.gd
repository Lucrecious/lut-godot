class_name IButtonInput
extends Node

signal action_just_pressed(action)
signal action_just_released(action)

func get_actions() -> PoolStringArray:
	assert(false, 'must be implemented in derived')
	return PoolStringArray([])
