extends Node2D

export(float) var height := 1.0
export(float) var jump_lock_distance_x := 1.0
export(float) var speed_x := 1.0

onready var _wall_grip := NodE.get_sibling(self, PlatformerWallGrip) as PlatformerWallGrip
onready var _controller := Components.controller(get_parent())
onready var _velocity := Components.velocity(get_parent())
onready var _disabler := Components.disabler(get_parent())
onready var _jump := NodE.get_sibling(self, PlatformerJump) as PlatformerJump
onready var _gravity := NodE.get_sibling(self, Gravity) as Gravity
onready var _turner := NodE.get_sibling(self, PlatformerTurner) as PlatformerTurner

var _enabled := false
var _jump_direction := 0
var _wall_jump_msec_passed := 0

func _ready() -> void:
	set_physics_process(false)
	enable()

func enable() -> void:
	if _enabled:
		return
	
	_enabled = true
	_controller.connect('jump_just_pressed', self, '_on_jump_just_pressed')

func disable() -> void:
	if not _enabled:
		return
	
	set_physics_process(false)
	_turner.enable()
	_controller.disconnect('jump_just_pressed', self, '_on_jump_just_pressed')
	_enabled = false

func _on_jump_just_pressed() -> void:
	if not _wall_grip.is_gripping():
		return
	
	_jump_direction = -_wall_grip.get_grip_direction()
	_wall_jump_msec_passed = 0
	
	_disabler.disable_below(self)
	_gravity.enable()
	
	set_physics_process(true)
	_velocity.value.x = _jump_direction * speed_x
	_jump.impulse(true, height)
	_turner.direction = _jump_direction
	_turner.disable()
	

func _physics_process(delta: float) -> void:
	var lock_msec := floor(1000 * jump_lock_distance_x / speed_x)
	if _wall_jump_msec_passed > lock_msec:
		set_physics_process(false)
		_disabler.enable_below(self)
		_turner.enable()
		_turner.update_direction_by_controller()
		return
	
	_wall_jump_msec_passed += floor(delta * 1000)
	_velocity.value.x = _jump_direction * speed_x
	
