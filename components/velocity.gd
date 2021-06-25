class_name Component_Velocity
extends Node2D

signal floor_hit()
signal floor_left()
signal wall_hit()
signal wall_left()
signal x_direction_changed()
signal y_direction_changed()

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

onready var _body := get_parent() as KinematicBody2D

func move_pixels(vec: Vector2) -> Vector2:
	return _body.move_and_slide(vec / get_physics_process_delta_time(), Vector2.UP, true)

func _physics_process(delta: float) -> void:
	var previous_is_on_wall := _body.is_on_wall()
	var previous_is_on_floor := _body.is_on_floor()
	
	value = _body.move_and_slide(value * Metric.Pixels, Vector2.UP, true) / Metric.Pixels
	
	var current_is_on_wall := _body.is_on_wall()
	var current_is_on_floor := _body.is_on_floor()
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
