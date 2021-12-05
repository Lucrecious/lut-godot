class_name PlatformerTurnerListener
extends Node

enum TurnBy {
	None,
	Controller,
	Velocity,
	Controller_Inverted,
	Velocity_Inverted,
}

export(NodePath) var _animation_player_path := NodePath()
export(Array, String) var _animation_names := []
export(Array, TurnBy) var _turn_bys := []

var _animation_2_turnby := {}

onready var _turner := get_parent() as PlatformerTurner
onready var _animation_player := get_node_or_null(_animation_player_path) as AnimationPlayer

func _ready() -> void:
	assert(_turner, 'turner must be parent for this to be valid')
	assert(_animation_player, 'must be set')
	assert(_animation_names.size() == _turn_bys.size(), 'must be same size')
	
	for i in _animation_names.size():
		_animation_2_turnby[_animation_names[i]] = _turn_bys[i]
	
	_animation_player.connect('animation_changEd', self, '_on_animation_changEd')

func _on_animation_changEd(_old_animation: String, new_animation: String) -> void:
	if new_animation.empty(): return
	
	yield(get_tree(), 'idle_frame')
	_on_update_flip(new_animation)

func _on_update_flip(animation_name: String) -> void:
	var turn_by := _animation_2_turnby.get(animation_name, -1) as int
	if turn_by == -1: return
	
	match turn_by:
		TurnBy.Controller: _turner.update_direction_by_controller()
		TurnBy.Controller_Inverted:
			_turner.update_direction_by_controller()
			_turner.direction *= -1
		TurnBy.Velocity: _turner.update_direction_by_velocity()
		TurnBy.Velocity_Inverted:
			_turner.update_direction_by_velocity()
			_turner.direction *= -1








