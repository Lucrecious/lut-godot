class_name Turner4Directions
extends Node2D

signal direction_changed()

export(NodePath) var _animation_path := NodePath()
export(PoolStringArray) var _animations4 := PoolStringArray()
export(Array, NodePath) var _sprite_paths := []

onready var _controller := Components.controller(get_parent())
onready var _animation := NodE.get_node_with_error(
	self, _animation_path, PriorityAnimationPlayer)\
	as PriorityAnimationPlayer

onready var _sprites := _sprites_from_paths(_sprite_paths)

func _ready() -> void:
	_animation.connect('animation_changEd', self, '_on_animation_changed')
	_controller.connect('direction_changed', self, '_on_direction_changed')

func _on_animation_changed(_old, new: String) -> void:
	_update_direction(new, _controller.direction)

func _on_direction_changed(direction: Vector2) -> void:
	_update_direction(_animation.current_animation, direction)

var _direction := Vector2.ZERO
func get_direction() -> Vector2:
	return _direction

func _update_direction(animation: String, direction: Vector2) -> void:
	if not animation in _animations4:
		return
	
	var previous_direction := _direction
	
	if direction.is_equal_approx(Vector2.ZERO):
		direction = _direction
	else:
		_direction = direction
		if abs(direction.x) >= abs(direction.y):
			_direction.x = sign(_direction.x)
			_direction.y = 0
		else:
			_direction.x = 0
			_direction.y = sign(_direction.y)
	
	var direction_suffix := '_up'
	
	if direction.x > 0:
		direction_suffix = '_right'
	elif direction.x < 0:
		direction_suffix = '_left' 
	elif direction.y < 0:
		direction_suffix = '_up'
	else:
		direction_suffix = '_down'
	
	_sprites_set_animation(animation + direction_suffix)
	
	if previous_direction.is_equal_approx(_direction):
		return
	
	emit_signal('direction_changed')

func _sprites_set_animation(animation: String) -> void:
	for s in _sprites:
		(s as AnimatedSprite).animation = animation

func _sprites_from_paths(paths: Array) -> Array:
	var sprites := []
	for p in paths:
		var sprite := NodE.get_node_with_error(
			self, p, AnimatedSprite) as AnimatedSprite
		if not sprite:
			continue
		
		sprites.push_back(sprite)
	
	return sprites




