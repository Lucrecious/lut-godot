class_name Component_Controller
extends Node

signal direction_changed(direction)
signal direction_h_changed()
signal direction_v_changed()
signal action_just_pressed(action)
signal action_just_released(action)
signal jump_pressed()

var direction := Vector2.ZERO setget, _direction_get

onready var _input := NodE.get_child(self, Input_Abstract) as Input_Abstract

func _ready() -> void:
	assert(_input, 'input must be a child')
	
	_input.connect('unhandled_input', self, '_on_unhandled_input')

func is_attack_pressed() -> bool:
	return _input.is_action_pressed('attack')

func _on_unhandled_input(event: InputEvent) -> void:
	if event.is_echo(): return
	
	if _is_direction_event(event):
		var previous_direction := direction
		_update_direction()
		if previous_direction != direction:
			emit_signal('direction_changed', direction)
		
		if previous_direction.x != direction.x:
			emit_signal('direction_h_changed')
		
		if previous_direction.y != direction.y:
			emit_signal('direction_v_changed')
		return
	
	var action_name := _get_action_name(event)
	if action_name.empty(): return
	
	if event.is_pressed():
		emit_signal('action_just_pressed', action_name)
		if action_name == 'jump':
			emit_signal('jump_pressed')
	else:
		emit_signal('action_just_released', action_name)

func _is_direction_event(event: InputEvent) -> bool:
	if event.is_action('left_move'): return true
	if event.is_action('right_move'): return true
	if event.is_action('up_move'): return true
	if event.is_action('down_move'): return true
	
	return false

func _update_direction() -> void:
	var left := int(_input.is_action_pressed('left_move'))
	var right := int(_input.is_action_pressed('right_move'))
	var up := int(_input.is_action_pressed('up_move'))
	var down := int(_input.is_action_pressed('down_move'))
	
	direction = Vector2(right - left, down - up)
	if direction == Vector2.ZERO: return
	direction = direction.normalized()

func _get_action_name(event: InputEvent) -> String:
	if event.is_action('jump'): return 'jump'
	if event.is_action('dodge'): return 'dodge'
	if event.is_action('attack'): return 'attack'
	return ''

func _direction_get() -> Vector2:
	return direction
