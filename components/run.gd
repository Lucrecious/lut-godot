class_name PlatformerRun
extends Node2D

signal velocity_calculated()

export(float) var speed := 10.0
export(Resource) var _floor_parameters_untyped: Resource = null
export(Resource) var _air_parameters_untyped: Resource = null

onready var _body := get_parent() as KinematicBody2D
onready var _controller := NodE.get_sibling(self, Controller) as Controller
onready var _velocity := NodE.get_sibling(self, Velocity) as Velocity
onready var _floor_parameters := _floor_parameters_untyped as Parameters_Run
onready var _air_parameters := _air_parameters_untyped as Parameters_Run

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
		if not _floor_parameters:
			return _direction * speed
		
		if current_speed > speed:
			var friction := 0.0
			
			if not _direction:
				friction = _floor_parameters.friction
			elif _direction == current_direction:
				friction = _floor_parameters.parallel_friction
			elif _direction != current_direction:
				friction = _floor_parameters.unparallel_friction
			
			assert(friction)
			
			return current_velocity - current_direction * speed * friction * get_physics_process_delta_time()
		
		return lerp(current_velocity, _direction * speed, _floor_parameters.interpolation)
	else:
		if not _air_parameters:
			return _direction * speed
		
		if not _direction:
			return current_velocity - current_direction * speed * _air_parameters.friction * get_physics_process_delta_time()
		
		if current_speed > speed:
			var friction := 0.0
			if _direction == current_direction:
				friction = _air_parameters.parallel_friction
			else:
				friction = _air_parameters.unparallel_friction
			
			assert(friction)
			
			return current_velocity - current_direction * speed * friction * get_physics_process_delta_time()
		
		return lerp(current_velocity, speed * _direction, _air_parameters.interpolation)
