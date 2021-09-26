class_name Component_Move4
extends Node2D

onready var _controller := Components.controller(get_parent())
onready var _velocity := Components.velocity(get_parent())

export(float) var speed := 10.0

func _ready() -> void:
	_controller.connect('direction_changed', self, '_on_direction_changed')

func _on_direction_changed(direction: Vector2) -> void:
	_velocity.value = direction.normalized() * speed
