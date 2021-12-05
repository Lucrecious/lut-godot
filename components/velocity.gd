class_name Velocity
extends Node2D

signal floor_hit()
signal floor_left()
signal wall_hit()
signal wall_left()
signal x_direction_changed()
signal y_direction_changed()

export(bool) var top_down_mode := false setget _top_down_mode_set
var _up_direction := Vector2.ZERO
func _top_down_mode_set(value: bool) -> void:
	top_down_mode = value
	if top_down_mode:
		_up_direction = Vector2.ZERO
	else:
		_up_direction = Vector2.UP

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
	_top_down_mode_set(top_down_mode)
	
	if _body is KinematicBody2D:
		_physics_process_func = funcref(self, '_physics_process_kinematicbody2d')
	elif _body is Node2D:
		_physics_process_func = funcref(self, '_physics_process_node2d')
	else:
		set_physics_process(false)

func move_pixels(vec: Vector2) -> Vector2:
	if _body is KinematicBody2D:
		return _body.move_and_slide(vec / get_physics_process_delta_time(), _up_direction, true)
	
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
	
	value = body.move_and_slide(value * units, _up_direction, true) / units
	
	var current_is_on_wall := body.is_on_wall()
	var current_is_on_floor := body.is_on_floor()
	var current_value := value
	
	if sign(_previous_value.x) != sign(current_value.x):
		emit_signal('x_direction_changed')
	
	if sign(_previous_value.y) != sign(current_value.y):
		emit_signal('y_direction_changed')
	
	_previous_value = current_value
	
	if not previous_is_on_floor and current_is_on_floor:
		emit_signal('floor_hit')
	
	if previous_is_on_floor and not current_is_on_floor:
		emit_signal('floor_left')
	
	if not previous_is_on_wall and current_is_on_wall:
		emit_signal('wall_hit')
	
	if previous_is_on_wall and not current_is_on_wall:
		emit_signal('wall_left')
