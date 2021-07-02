class_name Component_Death
extends Node2D

signal died()

onready var _disabler := NodE.get_sibling(self, Component_Disabler) as Component_Disabler
onready var _health := NodE.get_sibling(self, Component_Health) as Component_Health
onready var _velocity := NodE.get_sibling(self, Component_Velocity) as Component_Velocity

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
		collision.call_deferred('set', 'disabled', true)
	
	var gravity := NodE.get_sibling(self, Component_Gravity) as Component_Gravity
	if gravity:
		gravity.disable()
	
	emit_signal('died')

func __null(): return
