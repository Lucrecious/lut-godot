class_name Gravity
extends Node2D

export(float) var up_gravity := 1.0
export(float) var down_gravity := 1.0
export(float) var terminal_velocity := 30.0

var current := 0.0 setget ,_current_get

onready var _velocity := Components.velocity(get_parent())

var _filters := {}

func _ready() -> void:
	enable()

func add_filter(filter_name: String, object: Object, filter: String) -> void:
	_filters[filter_name] = funcref(object, filter)

func remove_filter(filter_name: String) -> void:
	_filters.erase(filter_name)

func disable() -> void:
	set_physics_process(false)

func enable() -> void:
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	var g := _current_get() * delta
	
	if _velocity.y < terminal_velocity:
		_velocity.y += g
	else:
		if _velocity.y < terminal_velocity:
			_velocity.y -= g / 6.5
			_velocity.y = max(terminal_velocity, _velocity.y) + .01

func _current_get() -> float:
	if _velocity.y > 0: return _filter(down_gravity)
	return _filter(up_gravity)

func _filter(value: float) -> float:
	for key in _filters:
		var f := _filters[key] as FuncRef
		value = f.call_func(value)
	return value

