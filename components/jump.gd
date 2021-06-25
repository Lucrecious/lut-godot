class_name Component_Jump
extends Node2D

export(int, 0, 2000) var coyote_time_msec := 200
export(int, 0, 5) var jump_count := 1

export(float) var _height := 10.0

var _enabled := false

onready var _body := get_parent() as KinematicBody2D
onready var _controller := NodE.get_sibling(self, Component_Controller) as Component_Controller
onready var _velocity := NodE.get_sibling(self, Component_Velocity) as Component_Velocity
onready var _gravity := NodE.get_sibling(self, Component_Gravity) as Component_Gravity

var _jumps_available := 1
var _time_left_floor_msec := -100

func _ready() -> void:
	assert(_body, 'must be child of kinematic body 2d')
	assert(_controller, 'must sibling with a controller component')
	assert(_velocity, 'must be siblings with a velocity component')
	assert(_gravity, 'must be siblings with a gravity component') 
	
	_controller.connect('action_just_pressed', self, '_jump_pressed')
	_controller.connect('action_just_released', self, '_jump_released')
	
	_velocity.connect('floor_left', self, 'reset_coyote_time')
	_velocity.connect('floor_hit', self, '_reset_jumps')
	
	enable()

func reset_coyote_time() -> void:
	_time_left_floor_msec = OS.get_ticks_msec()

func _reset_jumps() -> void:
	_jumps_available = jump_count

func _can_jump() -> bool:
	if _jumps_available > 1: return true
	if _jumps_available == 1 and (OS.get_ticks_msec() - _time_left_floor_msec) <  coyote_time_msec: return true
	if _body.is_on_floor(): return true
	return false

func disable() -> void:
	_enabled = false

func enable() -> void:
	_enabled = true

func _jump_pressed(action: String) -> void:
	if not _enabled: return
	
	if not _can_jump(): return
	if action != 'jump': return
	
	_jumps_available -= 1
	
	impulse()

func _jump_released(action: String) -> void:
	if not _enabled: return
	
	if _body.is_on_floor(): return
	if _velocity.value.y >= 0: return
	if action != 'jump': return
	
	_velocity.value.y /= 2.5

func impulse(use_custom_height := false, custom_height := 0.0) -> void:
	var h := (custom_height if use_custom_height else _height)
	var g := _gravity.up_gravity
	var v0 := _velocity.value.y
	
	var initial_velocity := sqrt(v0*v0 + 2*g*h)
	_velocity.value.y = -initial_velocity
	
	
	
	
	
	
	
