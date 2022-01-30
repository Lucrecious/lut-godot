class_name Component_Dash
extends Node2D


export(float, 0.5, 100.0) var _distance := 3.0
export(float, 0.0, 100.0) var _dash_time_sec := .3
export(float, 0.0, 5.0) var _pick_dir_sec := .3
export(float, 0.0, 100.0) var _cooldown := 0.5

onready var _controller := NodE.get_sibling(self, Controller) as Controller
onready var _disabler := NodE.get_sibling(self, ComponentDisabler) as ComponentDisabler
onready var _velocity := NodE.get_sibling(self, Velocity) as Velocity

var _pick_dir_timer: Timer
var _dash_timer: Timer
var _previous_dash_time_msec := int(-_cooldown * 1000)
var is_dashing := false setget __null_set

func _ready() -> void:
	assert(_controller, 'must have controller')
	
	set_physics_process(false)
	
	_controller.connect('action_just_pressed', self, '_on_action_just_pressed')
	
	_dash_timer = Timer.new()
	_dash_timer.autostart = false
	_dash_timer.one_shot = true
	_dash_timer.wait_time = _dash_time_sec
	_dash_timer.connect('timeout', self, '_dash_finished', [false])
	add_child(_dash_timer)
	
	_pick_dir_timer = Timer.new()
	_pick_dir_timer.autostart = false
	_pick_dir_timer.one_shot = true
	_pick_dir_timer.wait_time = _pick_dir_sec
	_pick_dir_timer.connect('timeout', self, '_shoot_dash')
	add_child(_pick_dir_timer)

var _dash_velocity := Vector2.ZERO
func _on_action_just_pressed(action: String) -> void:
	if (OS.get_ticks_msec() - _previous_dash_time_msec) < _cooldown * 1000: return
	if is_dashing: return
	if action != 'dodge': return
	if _velocity.value == Vector2.ZERO and _controller.direction == Vector2.ZERO: return
	
	_dash()

func _dash() -> void:
	is_dashing = true
	_previous_dash_time_msec = OS.get_ticks_msec()
	_disabler.disable_below(self)
	
	_pick_dir_timer.start()
	
	_dash_velocity = _velocity.value / 4.0
	set_physics_process(true)

func _shoot_dash() -> void:
	var dir := _controller.get_direction(0)
	
	if dir != Vector2.ZERO:
		_dash_velocity = dir.normalized() * (_distance / _dash_time_sec)
	else:
		_dash_velocity = _dash_velocity.normalized() * (_distance / _dash_time_sec)
	_dash_timer.start()


func _dash_finished(keep_velocity: bool) -> void:
	if not is_dashing: return
	
	set_physics_process(false)
	_disabler.enable_below(self)
	
	if not keep_velocity:
		if _velocity.y > 0:
			_velocity.x /= 3.0
		else:
			_velocity.value /= 3.0
	
	is_dashing = false

func _physics_process(delta: float) -> void:
	_velocity.value = _dash_velocity

func __null_set(__): return






