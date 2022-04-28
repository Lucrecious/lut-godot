class_name PlatformerJump
extends Node2D

signal impulsed()

export(bool) var _input_disabled := false
export(int, 0, 2000) var coyote_time_msec := 200

export(float) var height := 10.0

var _enabled := false

onready var _body := get_parent() as KinematicBody2D
onready var _controller := NodE.get_sibling(self, Controller) as Controller
onready var _velocity := NodE.get_sibling(self, Velocity) as Velocity
onready var _gravity := NodE.get_sibling(self, Gravity) as Gravity

var _time_left_floor_msec := -100
var _jumped := false

func _ready() -> void:
	if not _input_disabled:
		assert(_controller, 'must sibling with a controller component')
	
	assert(_body, 'must be child of kinematic body 2d')
	assert(_velocity, 'must be siblings with a velocity component')
	assert(_gravity, 'must be siblings with a gravity component') 
	
	if not _input_disabled:
		_controller.connect('action_just_pressed', self, '_jump_pressed')
		_controller.connect('action_just_released', self, '_jump_released')
	
	_velocity.connect('floor_left', self, '_on_floor_left')
	_velocity.connect('floor_hit', self, '_on_floor_hit')
	
	enable()

func _on_floor_left() -> void:
	set_coyote_time()

func set_coyote_time() -> void:
	_time_left_floor_msec = OS.get_ticks_msec()

func _on_floor_hit() -> void:
	_jumped = false

func _can_jump() -> bool:
	if _body.is_on_floor():
		return true
	
	if _jumped:
		return false
	
	if (OS.get_ticks_msec() - _time_left_floor_msec) <  coyote_time_msec:
		return true
	
	return false

func disable() -> void:
	_enabled = false

func enable() -> void:
	_enabled = true

func _jump_pressed(action: String) -> void:
	if not _enabled:
		return
	
	if action != 'jump':
		return
	
	if not _can_jump():
		return
	
	_jumped = true
	impulse()

func _jump_released(action: String) -> void:
	if not _enabled:
		return
	
	if _body.is_on_floor():
		return
	
	if _velocity.value.y >= 0:
		return
	
	if action != 'jump':
		return
	
	_velocity.value.y /= 2.5

func get_impulse(use_custom_height := false, custom_height := 0.0) -> float:
	var h := (custom_height if use_custom_height else height)
	var g := _gravity.up_gravity
	var v0 := 0.0
	
	var impulse_velocity := sqrt(v0*v0 + 2*g*h)
	
	return impulse_velocity

func impulse(use_custom_height := false, custom_height := 0.0) -> void:
	var initial_velocity := get_impulse(use_custom_height, custom_height)
	
	_velocity.value.y = -initial_velocity
	
	emit_signal('impulsed')
	
	
	
	
	
	
