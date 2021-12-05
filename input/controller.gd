class_name Controller
extends Node

signal direction_changed(direction)
signal direction_h_changed()
signal direction_v_changed()
signal action_just_pressed(action)
signal action_just_released(action)

export(Resource) var binded_actions: Resource = null

var direction := Vector2.ZERO setget, _direction_get

onready var _input := NodE.get_child_with_error(self, Input_Abstract) as Input_Abstract

var _pressed := {}

func _ready() -> void:
	assert(binded_actions, 'must be set')
	_input.connect('unhandled_input', self, '_on_unhandled_input')

func use_custom_input(input: Input_Abstract) -> void:
	assert(not input.get_parent())
	assert(not input.is_inside_tree())
	
	for action in _pressed:
		var p := _pressed[action] as bool
		if not p: continue
		var event := InputEventAction.new()
		event.action = action
		event.pressed = false
		_on_unhandled_input(event)
	
	remove_child(_input)
	_input.disconnect('unhandled_input', self, '_on_unhandled_input')
	add_child(input)
	
	_input = input
	_input.connect('unhandled_input', self, '_on_unhandled_input')

func is_action_pressed(action: String) -> bool:
	return _pressed.get(action, false)

func _on_unhandled_input(event: InputEvent) -> void:
	if event.is_echo(): return
	var action_name := _get_action_name(event)
	
	if action_name.empty(): return
	
	if event.is_pressed():
		_pressed[action_name] = true
		emit_signal('action_just_pressed', action_name)
	else:
		_pressed.erase(action_name)
		emit_signal('action_just_released', action_name)
	
	if not _is_direction_event(event):
		return
	
	var previous_direction := direction
	_update_direction()
	if previous_direction != direction:
		emit_signal('direction_changed', direction)
	
	if previous_direction.x != direction.x:
		emit_signal('direction_h_changed')
	
	if previous_direction.y != direction.y:
		emit_signal('direction_v_changed')


func _is_direction_event(event: InputEvent) -> bool:
	if event is InputEventJoypadMotion:
		var direction_action := _get_matching_direction_action(event)
		for i in binded_actions.vectors.size():
			if not direction_action in binded_actions.get_leftrightupdown(i):
				continue
			return true
	else:
		for i in binded_actions.vectors.size():
			for action in binded_actions.get_leftrightupdown(i):
				if not event.is_action(action):
					continue
				return true
	return false

func _update_direction() -> void:
	var leftrightupdown := binded_actions.get_leftrightupdown(0) as PoolStringArray
	var left := int(_pressed.get(leftrightupdown[0], false))
	var right := int(_pressed.get(leftrightupdown[1], false))
	var up := int(_pressed.get(leftrightupdown[2], false))
	var down := int(_pressed.get(leftrightupdown[3], false))
	
	direction = Vector2(right - left, down - up)
	if direction == Vector2.ZERO: return
	direction = direction.normalized()

func _get_action_name(event: InputEvent) -> String:
	for action in binded_actions.single_actions:
		if not event.is_action(action):
			continue
		return action
	
	if event is InputEventJoypadMotion:
		return _get_matching_direction_action(event)
	
	for i in binded_actions.vectors.size():
		for action in binded_actions.get_leftrightupdown(i):
			if not event.is_action(action):
				continue
			return action
	
	return ''

func _get_matching_direction_action(event: InputEventJoypadMotion) -> String:
	if not event:
		return ''
	
	for action in InputMap.get_actions():
		for event_ in InputMap.get_action_list(action):
			var joy_motion = event_ as InputEventJoypadMotion
			if not joy_motion:
				continue
			
			if joy_motion.device != event.device:
				continue
			
			if joy_motion.axis != event.axis:
				continue
			
			if sign(joy_motion.axis_value) != sign(event.axis_value):
				continue
			
			return action
	
	return ''


func _direction_get() -> Vector2:
	return direction
