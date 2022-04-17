class_name PlatformerRun
extends Node2D

signal velocity_calculated()

export(float) var speed := 10.0
export(Resource) var _floor_velocity_calculation: Resource = null
export(Resource) var _air_velocity_calculation: Resource = null

onready var _body := get_parent() as KinematicBody2D
onready var _controller := NodE.get_sibling(self, Controller) as Controller
onready var _velocity := NodE.get_sibling(self, Velocity) as Velocity

var _direction := 0

func _ready() -> void:
	assert(_controller, 'controller component must be a sibling')
	assert(_velocity, 'velocity component must be a sibling')
	
	_controller.connect('direction_changed', self, '_update_direction')
	
	enable()

func disable() -> void:
	set_physics_process(false)

func enable() -> void:
	set_physics_process(true)

func _update_direction(direction: Vector2):
	_direction = sign(direction.x)

func _physics_process(delta: float) -> void:
	_velocity.value.x = _calculate_velocity(_direction, _velocity.value.x)
	emit_signal('velocity_calculated')

func _calculate_velocity(direction: int, current_velocity: float) -> float:
	var current_speed := abs(current_velocity)
	var current_direction := sign(current_velocity)
	
	if _body.is_on_floor():
		if not _floor_velocity_calculation or not _floor_velocity_calculation.has_method('do'):
			return _direction * speed
		
		return _floor_velocity_calculation.do(current_velocity, speed, _controller.direction.x, get_physics_process_delta_time())
	else:
		if not _air_velocity_calculation or not _air_velocity_calculation.has_method('do'):
			return _direction * speed
		
		return _air_velocity_calculation.do(current_velocity, speed, _controller.direction.x, get_physics_process_delta_time())
