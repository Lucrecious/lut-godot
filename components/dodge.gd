extends Node2D

export(String) var anim_name := ''
export(String) var action_name := ''
export(NodePath) var _priority_node_path := NodePath()
export(float) var dodge_velocity := 0.0

onready var _priority_node := get_node(_priority_node_path)
onready var _animation := Components.priority_animation_player(get_parent())
onready var _controller := Components.controller(get_parent())
onready var _disabler := Components.disabler(get_parent())
onready var _velocity := Components.velocity(get_parent())

var _enabled := false
var _is_dodging := false
var _dodge_side := 0

func _ready():
	set_physics_process(false)
	enable()

func enable() -> void:
	if _enabled:
		return
	_enabled = true
	_controller.connect('%s_just_pressed' % action_name, self, '_on_dodge_just_pressed')
	_controller.connect('direction1_changed', self, '_on_direction1_changed')

func disable() -> void:
	if not _enabled:
		return
	
	set_physics_process(false)
	_controller.disconnect('%s_just_pressed' % action_name, self, '_on_dodge_just_pressed')
	_controller.disconnect('direction1_changed', self, '_on_direction1_changed')
	_enabled = false

func _on_direction1_changed(value: Vector2) -> void:
	if not _controller.is_pressed(action_name):
		return
	
	_dodge(value.x)

func _on_dodge_just_pressed() -> void:
	_dodge(sign(_controller.get_direction(0).x))

func _dodge(side: int) -> void:
	if _is_dodging:
		return
	
	if side == 0:
		return
		
	_is_dodging = true
	_dodge_side = side
	_velocity.value = Vector2.ZERO
	set_physics_process(true)
	_disabler.disable_below(self)
	
	_animation.callback_on_finished(anim_name, _priority_node, self, '_finish_dodge')

func _physics_process(delta: float) -> void:
	_velocity.value.x = dodge_velocity * _dodge_side
	_velocity.value.y = 1

func _finish_dodge() -> void:
	if not _enabled:
		return
	
	set_physics_process(false)
	_dodge_side = 0
	_disabler.enable_below(self)
	_is_dodging = false