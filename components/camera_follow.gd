class_name CameraFollow
extends Node2D

export(NodePath) var _initial_target_path := NodePath()

onready var _camera := get_parent() as Camera2D

var target: Node2D = null setget _target_set, _target_get
var _follow_target: Node2D = null
func _target_set(value: Node2D) -> void:
	if target == value:
		return
	
	target = value
	
	var root_sprite := NodE.get_child(target, RootSprite) as RootSprite
	if root_sprite:
		_follow_target = root_sprite
	else:
		_follow_target = target
	
	set_process(_follow_target != null)

func _target_get() -> Node2D:
	if not is_instance_valid(target):
		return null
	
	return target

func _ready() -> void:
	set_process(false)
	
	assert(_camera, 'must be child of camera')
	
	var initial_target := get_node_or_null(_initial_target_path) as Node2D
	if not initial_target:
		return
	
	_target_set(initial_target)

func _process(delta: float) -> void:
	if not is_instance_valid(_follow_target):
		_target_set(null)
		return
	
	_camera.global_position = _follow_target.global_position
