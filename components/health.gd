class_name Health
extends Node

signal zeroed()
signal damaged(amount)
signal increased(amount)
signal changed()

export(bool) var below_zero := false
export(int) var current := 1 setget current_set

func damage(value: int) -> void:
	current_set(current - value)

func current_set(value: int) -> void:
	if not below_zero:
		value = max(0, value)
	
	if current == value: return
	var old := current
	current = value
	
	if current < old:
		emit_signal('damaged', old - current)
	
	if current > old:
		emit_signal('increased', current - old)
	
	if current == 0:
		emit_signal('zeroed')
	
	emit_signal('changed')

func __null_set(value: int): return








