class_name PlatformerTurner
extends Node2D

signal direction_changed()

var direction := 1 setget _direction_set, _direction_get
export(NodePath) var _root_sprite_path := NodePath()

onready var _controller := NodE.get_sibling(self, Controller) as Controller
onready var _velocity := NodE.get_sibling(self, Velocity) as Velocity
onready var _root_sprite := get_node_or_null(_root_sprite_path) as Node2D

func _ready() -> void:
	assert(_controller, 'must have a controller as a sibling')
	assert(_root_sprite, 'must have an assigned root sprite')
	assert(_velocity, 'must be a sibling')
	
	connect('direction_changed', self, '_update_sprite_flip')

onready var _enabled := true

func enable() -> void:
	_enabled = true

func disable() -> void:
	_enabled = false

func update_direction_by_controller() -> float:
	var x_sign := sign(_controller.get_direction(0).x)
	_direction_set(x_sign)
	return x_sign

func update_direction_by_velocity() -> void:
	if abs(_velocity.x) < .5: return
	var x_sign := sign(_velocity.x)
	_direction_set(x_sign)

func _update_sprite_flip() -> void:
	_root_sprite.scale.x = abs(_root_sprite.scale.x) * direction

func _direction_get() -> int:
	return direction

func _direction_set(dir: int) -> void:
	if not _enabled:
		return
	
	if dir == 0:
		return
	if dir == direction:
		return
	direction = dir
	emit_signal('direction_changed')
