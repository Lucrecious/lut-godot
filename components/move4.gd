class_name Component_Move4
extends Node2D

onready var _controller := Components.controller(get_parent())
onready var _velocity := Components.velocity(get_parent())

export(float) var speed := 10.0

func _ready() -> void:
	enable()

var _enabled := false
func enable() -> void:
	if _enabled:
		return
	
	_enabled = true
	_controller.connect('direction_changed', self, '_on_direction_changed')
	_on_direction_changed(_controller.direction)

func disable() -> void:
	if not _enabled:
		return
	
	_controller.disconnect('direction_changed', self, '_on_direction_changed')
	_enabled = false
	_velocity.value = Vector2.ZERO

func _on_direction_changed(direction: Vector2) -> void:
	_velocity.value = direction.normalized() * speed
