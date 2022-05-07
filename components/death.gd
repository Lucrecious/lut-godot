class_name Death
extends Node2D

signal died()
signal revived()

onready var _body := NodE.get_ancestor_with_error(self, KinematicBody2D) as KinematicBody2D
onready var _disabler := NodE.get_sibling(self, ComponentDisabler) as ComponentDisabler
onready var _health := NodE.get_sibling(self, Health) as Health
onready var _velocity := NodE.get_sibling(self, Velocity) as Velocity

var _is_dead := false

func is_dead() -> bool: return _is_dead

func _ready():
	assert(_disabler, 'must be sibling')
	assert(_health, 'must be sibling')
	
	_health.connect('zeroed', self, '_on_zeroed')

func _on_zeroed() -> void:
	_health.disconnect('zeroed', self, '_on_zeroed')
	_disabler.disable_below(self)
	_is_dead = true
	if _velocity:
		_velocity.value = Vector2.ZERO
	
	var collision := NodE.get_sibling(self, CollisionShape2D) as CollisionShape2D
	if collision:
		collision.set_deferred('disabled', true)
	
	var gravity := NodE.get_sibling(self, Gravity) as Gravity
	if gravity:
		gravity.disable()
	
	emit_signal('died')
	
	_health.connect('increased', self, '_on_revived')

func _on_revived(_amount: int) -> void:
	_health.disconnect('increased', self, '_on_revived')
	
	_health.connect('zeroed', self, '_on_zeroed')
	_disabler.enable_below(self)
	_is_dead = false
	
	var collision := NodE.get_sibling(self, CollisionShape2D) as CollisionShape2D
	if collision:
		call_deferred('_wait_then_enable_collision', collision)
	
	var gravity := NodE.get_sibling(self, Gravity) as Gravity
	if gravity:
		gravity.enable()
	
	emit_signal('revived')

func _wait_then_enable_collision(collision: CollisionShape2D) -> void:
	yield(get_tree(), 'idle_frame')
	collision.set_deferred('disabled', false)

func __null(): return
