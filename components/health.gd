class_name Health
extends Node

signal changed()
signal max_points_changed()
signal zeroed()
signal damaged(amount)
signal increased(amount)

export(bool) var below_zero := false
export(int) var current := 1 setget current_set

export(bool) var use_current_for_max := true
export(int) var max_points := 1 setget _max_points_set

func _ready() -> void:
	if not use_current_for_max:
		return
	
	_max_points_set(current)

func heal(value: int) -> void:
	current_set(current + value)

func damage(value: int) -> void:
	current_set(current - value)

func current_set(value: int) -> void:
	if not below_zero:
		value = int(max(0, value))
	
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

func _max_points_set(value: int) -> void:
	if max_points == value:
		return
	
	max_points = value
	emit_signal('max_points_changed')

func __null_set(_value: int): return








