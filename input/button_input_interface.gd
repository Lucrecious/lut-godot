class_name IButtonInput
extends Node

#warning-ignore:unused_signal
signal action_just_pressed(action)

#warning-ignore:unused_signal
signal action_just_released(action)

func get_actions() -> PoolStringArray:
	assert(false, 'must be implemented in derived')
	return PoolStringArray([])
