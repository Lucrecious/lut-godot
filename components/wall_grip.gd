class_name PlatformerWallGrip
extends Node2D

const LoseGripDelay_Msec := 200

signal gripped
signal released

const LEAVE_WALL_MSEC := 200

onready var _body := get_parent() as KinematicBody2D
onready var _controller := NodE.get_sibling(self, Controller) as Controller
onready var _velocity := NodE.get_sibling(self, Velocity) as Velocity
onready var _jump := NodE.get_sibling(self, PlatformerJump) as PlatformerJump
onready var _disabler := NodE.get_sibling(self, ComponentDisabler) as ComponentDisabler

var _enabled := false
var _is_gripping := false
var _grip_direction := 0

func _ready() -> void:
	set_physics_process(false)
	enable()

func enable() -> void:
	if _enabled:
		return
	
	_enabled = true
	
	_is_gripping = false
	_grip_direction = 0
	
	_velocity.connect('wall_hit', self, '_on_wall_hit')
	_velocity.connect('wall_left', self, '_on_wall_left')
	_velocity.connect('floor_left', self, '_on_floor_left')
	_velocity.connect('floor_hit', self, '_on_floor_hit')
	_controller.connect('direction1_changed', self, '_on_direction_changed')
	if _body.is_on_wall():
		_on_wall_hit()

func disable() -> void:
	if not _enabled:
		return
	
	_is_gripping = false
	_grip_direction = 0
	set_physics_process(false)
	_velocity.disconnect('wall_hit', self, '_on_wall_hit')
	_velocity.disconnect('wall_left', self, '_on_wall_left')
	_velocity.disconnect('floor_left', self, '_on_floor_left')
	_velocity.disconnect('floor_hit', self, '_on_floor_hit')
	_controller.disconnect('direction1_changed', self, '_on_direction_changed')
	
	_enabled = false

func is_gripping() -> bool:
	return _is_gripping

func get_grip_direction() -> int:
	if not _is_gripping:
		return 0
	return _grip_direction

func _get_wall_direction() -> int:
	if not _body.is_on_wall():
		return 0
	
	for i in _body.get_slide_count():
		var slide := _body.get_slide_collision(i)
		if abs(slide.normal.y) > abs(slide.normal.x):
			continue
		return int(sign(slide.normal.x))
	
	return 0

func _on_direction_changed(_value: Vector2) -> void:
	_grip_wall()

func _on_wall_hit() -> void:
	_grip_wall()
	
func _on_wall_left() -> void:
	var previous_is_gripping := _is_gripping
	disable()
	if not _is_gripping and previous_is_gripping:
		emit_signal('released')
	
	enable()

func _on_floor_left() -> void:
	_grip_wall()

func _on_floor_hit() -> void:
	var previous_is_gripping := _is_gripping
	disable()
	if not _is_gripping and previous_is_gripping:
		emit_signal('released')
	enable()

func _grip_wall() -> void:
	if _is_gripping:
		return
	
	if _body.is_on_floor():
		return
	
	if not _body.is_on_wall():
		return
	
	if _controller.get_direction(0).x == 0:
		return
	
	if _controller.get_direction(0).x != -_get_wall_direction():
		return
	
	_is_gripping = true
	_grip_direction = -_get_wall_direction()
	set_physics_process(true)
	var impulse := _jump.get_impulse(true, .5)
	if _velocity.value.y > -impulse:
		_velocity.value.y = -_jump.get_impulse(true, .5)
	
	emit_signal('gripped')

var _leave_wall_count_msec := 0
func _physics_process(delta: float) -> void:
	if _controller.get_direction(0).x != _grip_direction:
		_leave_wall_count_msec += floor(delta * 1000)
	else:
		_leave_wall_count_msec = 0
	
	if _leave_wall_count_msec > LEAVE_WALL_MSEC:
		return
	
	_velocity.value.x = _grip_direction
	_velocity.value.y = min(_velocity.value.y, 1.0)
		
