class_name Component_ConstantVelocity
extends Node2D

onready var _velocity := Components.velocity(get_parent())

export(float) var speed := 0.0 setget _speed_set
export(Vector2) var direction := Vector2.ZERO setget _direction_set

var _cached_velocity := Vector2.ZERO
var _dirty_velocity := true

func _ready() -> void:
	enable()

var _enabled := false
func enable() -> void:
	if _enabled:
		return
	
	_enabled = true
	set_physics_process(true)

func disable() -> void:
	if not _enabled:
		return
	
	set_physics_process(false)
	_enabled = false

func _speed_set(value_: float) -> void:
	speed = value_
	_dirty_velocity = true

func _direction_set(value_: Vector2) -> void:
	direction = value_
	_dirty_velocity = true

func _update_cached_velocity() -> void:
	if not _dirty_velocity:
		return
	
	_dirty_velocity = false
	_cached_velocity = Vector2.ZERO
	if speed == 0 or direction.is_equal_approx(Vector2.ZERO):
		return
	
	_cached_velocity = direction.normalized() * speed

func _physics_process(delta: float) -> void:
	_update_cached_velocity()
	_velocity.value = _cached_velocity






