class_name SignalAnimationFinishedCallback
extends Node

signal called()

export(String) var animation_name: String
export(NodePath) var _node_to_callback_path: NodePath
export(String) var _callback_name: String

onready var _animation_player := get_parent() as AnimationPlayer
onready var _node_to_callback := get_node_or_null(_node_to_callback_path) as Node

func _ready() -> void:
	assert(_animation_player, 'must be child of animation player')
	
	_animation_player.connect('animation_finished', self, '_on_animation_finished')
	_animation_player.connect('animation_changed', self, '_on_animation_changed')

func animation_callback(_1=null,_2=null,_3=null,_4=null,_5=null) -> void:
	_needs_callback = true
	emit_signal('called')

var _needs_callback := false

func _on_animation_finished(animation_name: String) -> void:
	if not _needs_callback: return
	if animation_name != self.animation_name: return
	
	_needs_callback = false
	_node_to_callback.call(_callback_name)

func _on_animation_changed(old_animation: String, _new_animation: String) -> void:
	if not _needs_callback: return
	if old_animation != animation_name: return
	
	_needs_callback = false
	_node_to_callback.call(_callback_name)





