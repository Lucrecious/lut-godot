class_name Move4
extends Spatial

export(float) var stride_speed := 1.0
export(float) var front_speed := 1.0

onready var _controller := NodE.get_sibling_with_error(self, Controller) as Controller
onready var _velocity := NodE.get_sibling_with_error(self, Velocity3) as Velocity3

func _physics_process(delta: float) -> void:
	var direction := _controller.get_direction(0).normalized()
	
	var front := global_transform.basis.z * front_speed * direction.y
	var side := global_transform.basis.x * stride_speed * direction.x
	
	var velocity := front + side
	
	_velocity.value =  velocity
	
