class_name Velocity
extends Node2D

signal floor_hit()
signal floor_left()
signal wall_hit()
signal wall_left()
signal x_direction_changed()
signal y_direction_changed()

export(Vector2) var up_direction := Vector2.UP

# At 0: All of the initial up movement is used
# At 1: All of the returned movement after collision is used
# At 0 < i < 1: A ratio of each
export(float, 0.0, 1.0) var up_movement_damping := 1.0

export(float) var units := 1.0
export(Vector2) var value := Vector2.ZERO

var x := 0.0 setget _value_x_set, _value_x_get
var y := 0.0 setget _value_y_set, _value_y_get

func _value_x_get() -> float: return value.x
func _value_x_set(x: float) -> void:
	if value.x == x: return
	value.x = x

func _value_y_get() -> float: return value.y
func _value_y_set(y: float) -> void:
	if value.y == y: return
	value.y = y

var _previous_value := Vector2.ZERO

onready var _body := get_parent()

var _physics_process_func: FuncRef
func _ready() -> void:
	if _body is KinematicBody2D:
		_physics_process_func = funcref(self, '_physics_process_kinematicbody2d')
	elif _body is Node2D:
		_physics_process_func = funcref(self, '_physics_process_node2d')
	else:
		set_physics_process(false)

func move_pixels(vec: Vector2) -> Vector2:
	if _body is KinematicBody2D:
		return _body.move_and_slide(vec / get_physics_process_delta_time(), up_direction)
	
	if _body is Node2D:
		_body.position += vec
		return vec
	
	return Vector2.ZERO

func _physics_process(delta: float) -> void:
	assert(_physics_process_func, 'must be set at this point or this should not be running')
	_physics_process_func.call_func()

func _physics_process_node2d() -> void:
	var body := _body as Node2D
	
	body.position += value * units * get_physics_process_delta_time()
	
	if sign(_previous_value.x) != sign(value.x):
		emit_signal('x_direction_changed')
	
	if sign(_previous_value.y) != sign(value.y):
		emit_signal('y_direction_changed')
	
	_previous_value = value

func _physics_process_kinematicbody2d() -> void:
	var body := _body as KinematicBody2D
	
	var previous_is_on_wall := body.is_on_wall()
	var previous_is_on_floor := body.is_on_floor()
	
	var before_impact_value := value
	var new_value := body.move_and_slide(value * units, up_direction, true) / units
	
	var new_y := new_value.y
	if value.y < 0:
		new_y = (up_movement_damping * new_value.y) + ((1.0 - up_movement_damping) * value.y)
	
	var current_is_on_wall := body.is_on_wall()
	var current_is_on_floor := body.is_on_floor()
	
	value = Vector2(new_value.x, new_y)
	
	if not previous_is_on_floor and current_is_on_floor:
		emit_signal('floor_hit')
	
	if previous_is_on_floor and not current_is_on_floor:
		emit_signal('floor_left')
	
	if not previous_is_on_wall and current_is_on_wall:
		emit_signal('wall_hit')
	
	if previous_is_on_wall and not current_is_on_wall:
		emit_signal('wall_left') 
	
	if sign(_previous_value.x) != sign(value.x):
		emit_signal('x_direction_changed')
	
	if sign(_previous_value.y) != sign(value.y):
		emit_signal('y_direction_changed')
	
	_previous_value = value

func _to_string() -> String:
	return '%s: %s' % ['Velocity', value]
