class_name Component_Turner
extends Node2D

signal direction_changed()

var direction := 1 setget _direction_set, _direction_get
export(NodePath) var _root_sprite_path := NodePath()

onready var _controller := NodE.get_sibling(self, Component_Controller) as Component_Controller
onready var _velocity := NodE.get_sibling(self, Component_Velocity) as Component_Velocity
onready var _root_sprite := get_node_or_null(_root_sprite_path) as Node2D

func _ready() -> void:
	assert(_controller, 'must have a controller as a sibling')
	assert(_root_sprite, 'must have an assigned root sprite')
	assert(_velocity, 'must be a sibling')
	
	connect('direction_changed', self, '_update_sprite_flip')

func update_direction_by_controller() -> void:
	var x_sign := sign(_controller.direction.x)
	_direction_set(x_sign)

func update_direction_by_velocity() -> void:
	if abs(_velocity.x) < .5: return
	var x_sign := sign(_velocity.x)
	_direction_set(x_sign)

func _update_sprite_flip() -> void:
	if direction == 0: return
	
	_root_sprite.scale.x = abs(_root_sprite.scale.x) * direction

func _direction_get() -> int:
	return direction

func _direction_set(dir: int) -> void:
	if dir == 0: return
	if dir == direction: return
	direction = dir
	emit_signal('direction_changed')
