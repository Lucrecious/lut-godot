class_name Component_Health
extends Node

signal zeroed()
signal damaged(amount)
signal increased(amount)

export(bool) var below_zero := false
export(int) var current := 1

var _last_health_modifier: Object = null

func last_health_modifier() -> Object: return _last_health_modifier

func current_set(value: int, sender: Object) -> void:
	if not below_zero:
		value = max(0, value)
	
	if current == value: return
	var old := current
	current = value
	_last_health_modifier = sender
	
	if current < old:
		emit_signal('damaged', old - current)
	
	if current > old:
		emit_signal('increased', current - old)
	
	if current == 0:
		emit_signal('zeroed')

func __null_set(value: int): return








