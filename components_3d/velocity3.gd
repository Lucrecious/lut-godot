class_name Velocity3
extends Spatial

export(Vector3) var value := Vector3()

export(Vector3) var up_direction := Vector3(0, 1, 0)

onready var _body := get_parent() as KinematicBody

func _physics_process(delta: float) -> void:
	_body.move_and_slide(value, up_direction)
