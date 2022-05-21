class_name Dodge
extends Node2D

const LONG_JUMP_POST_BUFFER_MSEC := 100

signal started()
signal ended()
signal long_jumped()

export(String) var action_name := ''
export(NodePath) var _priority_node_path := NodePath()
export(float) var dodge_velocity := 0.0
export(bool) var allow_long_jump := false
export(float) var long_jump_velocity := 10.0
export(bool) var allow_gravity := false

onready var _priority_node := get_node(_priority_node_path)
onready var _animation := Components.priority_animation_player(get_parent())
onready var _controller := Components.controller(get_parent())
onready var _disabler := Components.disabler(get_parent())
onready var _velocity := Components.velocity(get_parent())
onready var _gravity := NodE.get_sibling(self, Gravity) as Gravity
onready var _jump := NodE.get_sibling(self, PlatformerJump, false) as PlatformerJump

var _enabled := false
var _is_dodging := false
var _dodge_side := 0
var _assigned_dodge_side := 0
var _dodge_finished_msec := -LONG_JUMP_POST_BUFFER_MSEC

func _ready():
	if _jump:
		_jump.connect('impulsed', self, '_on_jump_impulsed')
	
	set_physics_process(false)
	enable()

func enable() -> void:
	if _enabled:
		return
	
	_is_dodging = false
	_enabled = true
	_controller.connect('%s_just_pressed' % action_name, self, '_on_dodge_just_pressed')
	_controller.connect('direction1_changed', self, '_on_direction1_changed')

func disable() -> void:
	if not _enabled:
		return
	
	set_physics_process(false)
	var was_dodging := _is_dodging
	_is_dodging = false
	_controller.disconnect('%s_just_pressed' % action_name, self, '_on_dodge_just_pressed')
	_controller.disconnect('direction1_changed', self, '_on_direction1_changed')
	_enabled = false
	
	if not was_dodging:
		return
	
	emit_signal('ended')

func is_dodging() -> bool:
	return _is_dodging

func enabled() -> bool:
	return _enabled

func _on_jump_impulsed() -> void:
	if not allow_long_jump:
		return
	
	if _assigned_dodge_side == 0:
		return
	
	if OS.get_ticks_msec() - _dodge_finished_msec > LONG_JUMP_POST_BUFFER_MSEC:
		return
	
	var input_direction := sign(_controller.get_direction(0).x)
	if input_direction != _assigned_dodge_side:
		return
	
	_velocity.x = input_direction * long_jump_velocity
	emit_signal('long_jumped')

func _on_direction1_changed(value: Vector2) -> void:
	if not _controller.is_pressed(action_name):
		return
	
	_dodge(value.x)

func _on_dodge_just_pressed() -> void:
	_dodge(sign(_controller.get_direction(0).x))

func _dodge(side: int) -> void:
	if _is_dodging:
		return
	
	if side == 0:
		return
		
	_is_dodging = true
	_dodge_side = side
	_assigned_dodge_side = side
	_velocity.value = Vector2.ZERO
	set_physics_process(true)
	_disabler.disable_below(self)
	
	if allow_gravity:
		_gravity.enable()
	
	_animation.callback_on_finished_by_node(_priority_node, self, '_finish_dodge')
	emit_signal('started')

func _physics_process(delta: float) -> void:
	_velocity.value.x = dodge_velocity * _dodge_side
	if not allow_gravity:
		_velocity.value.y = 0

func _finish_dodge() -> void:
	if not _enabled:
		return
	
	set_physics_process(false)
	_dodge_finished_msec = OS.get_ticks_msec()
	_dodge_side = 0
	_is_dodging = false
	_disabler.enable_below(self)
	emit_signal('ended')
