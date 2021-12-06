class_name PlatformerWallGrip
extends Node2D

const LoseGripDelay_Msec := 200

signal wall_gripped
signal wall_released

export(float) var _slide_speed := 1.0
export(float) var _kick_off_speed := 20.0
export(float) var _kick_off_height := 10.0
export(float) var _run_up_height := 1.0

export(bool) var reset_air_jumps := true

onready var _body := get_parent() as KinematicBody2D
onready var _controller := NodE.get_sibling(self, Controller) as Controller
onready var _velocity := NodE.get_sibling(self, Velocity) as Velocity
onready var _jump := NodE.get_sibling(self, PlatformerJump) as PlatformerJump
onready var _disabler := NodE.get_sibling(self, ComponentDisabler) as ComponentDisabler

var _enabled := false
var _gripping_wall := false
var _gripped_wall_direction := 0

var _gripping_direction := 0
var _wall_direction := 0
var _is_on_floor := false

func _ready() -> void:
	assert(_body, 'parent must be kinematic body 2d')
	assert(_controller, 'must have a controller sibling')
	assert(_velocity, 'must have a velocity sibling')
	assert(_jump, 'must have a jump sibling')
	assert(_disabler, 'must have a disabler sibling')
	
	_controller.connect('direction_changed', self, '_update_pushing_direction')
	_velocity.connect('wall_hit', self, '_update_wall_direction')
	_velocity.connect('wall_left', self, '_update_wall_direction')
	_velocity.connect('floor_hit', self, '_update_is_on_floor')
	_velocity.connect('floor_left', self, '_update_is_on_floor')
	
	set_physics_process(false)
	
	enable()

func is_gripping_wall() -> bool:
	return _gripping_wall

func get_gripped_wall_direction() -> int:
	return _gripped_wall_direction

# Stuff to update the wall gripping status
func _update_pushing_direction(direction: Vector2) -> void:
	_gripping_direction = sign(direction.x)
	
	if not _enabled: return
	
	if not _can_grip_wall(): return
	_grip_wall()

func _update_wall_direction() -> void:
	_wall_direction = 0
	if _body.is_on_wall():
		for i in _body.get_slide_count():
			var collision := _body.get_slide_collision(i)
			var wall_direction := collision.normal.x
			if not is_equal_approx(abs(wall_direction), 1): continue
			_wall_direction = sign(wall_direction)
			break
	
	if not _enabled: return
	
	if not _can_grip_wall(): return
	_grip_wall()

func _update_is_on_floor() -> void:
	_is_on_floor = _body.is_on_floor()
	
	if not _enabled: return
	
	if not _can_grip_wall(): return
	_grip_wall()

func _can_grip_wall(include_gripping_direction := true) -> bool:
	if _is_on_floor: return false
	if is_equal_approx(_wall_direction, 0): return false
	
	if include_gripping_direction and is_equal_approx(_gripping_direction, 0): return false
	if include_gripping_direction and is_equal_approx(_wall_direction, _gripping_direction): return false
	
	return true

func _grip_wall() -> void:
	if _gripping_wall: return
	assert(not is_equal_approx(_wall_direction, 0))
	
	_gripping_wall = true
	_gripped_wall_direction = _wall_direction
	_disabler.disable_below(self)
	_disabler.enable(Gravity)
	
	if _velocity.y < 0 and abs(_jump.get_impulse(true, 1)) > abs(_velocity.y):
		_jump.impulse(true, _run_up_height)
	
	ObjEct.connect_once(_controller, 'action_just_pressed', self, '_kick_off_wall')
	
	set_physics_process(true)
	_physics_process(get_physics_process_delta_time())
	
	if reset_air_jumps:
		_jump.reset_air_jumps()
	
	emit_signal('wall_gripped')
	
	return

func _half_gravity(value: float) -> float:
	return value / 2.0

func _let_go_of_wall() -> void:
	if not _gripping_wall: return
	
	_gripping_wall = false
	set_physics_process(false)
	ObjEct.disconnect_once(_controller, 'action_just_pressed', self, '_kick_off_wall')
	
	if _enabled:
		_disabler.enable_below(self)
	
	emit_signal('wall_released')

var _tick_grip_last_had_msec := -1
func _physics_process(delta: float) -> void:
	assert(_gripping_wall, 'physics process should only be running when gripping the wall is true')
	_stick_to_wall()
	
	if is_equal_approx(_gripping_direction, -_gripped_wall_direction):
		_tick_grip_last_had_msec = OS.get_ticks_msec()
	
	if (not _can_grip_wall(false)) or (OS.get_ticks_msec() - _tick_grip_last_had_msec > LoseGripDelay_Msec):
		_let_go_of_wall()
		return

func _kick_off_wall(action: String) -> void:
	if action != 'jump': return
	
	_jump.impulse(true, _kick_off_height)
	_velocity.value.x += _kick_off_speed * _gripped_wall_direction
	
	_let_go_of_wall()

func _stick_to_wall() -> void:
	assert(_gripping_wall)
	assert(not is_equal_approx(_gripped_wall_direction, 0))
	_velocity.value.x = -sign(_wall_direction)
	
	_velocity.value.y = min(_slide_speed, _velocity.value.y)

func disable() -> void:
	if not _enabled: return
	_enabled = false
	
	if not _gripping_wall: return
	
	_let_go_of_wall()

func enable() -> void:
	if _enabled: return
	_enabled = true
	
	_update_pushing_direction(_controller.direction)
	_update_wall_direction()





