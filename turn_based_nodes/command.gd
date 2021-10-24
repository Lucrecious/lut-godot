class_name TurnBased_Command
extends Node


export(bool) var go_to_next := true

func execute() -> void:
	if not has_method('_execute'):
		return
	
	call('_execute')
