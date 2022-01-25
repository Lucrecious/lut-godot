class_name IButtonInput
extends Node

signal action_just_pressed(action)
signal action_just_released(action)

func actions() -> PoolStringArray:
	assert(false, 'interface must be implemented')
	return PoolStringArray()
