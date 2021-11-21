class_name Camera3Pivot
extends Position3D


export(float) var rotation_limit_x := 180

export(float) var offset_pitch_deg := 0.0 setget _offset_pitch_deg_set
export(float) var offset_yaw_deg := 0.0 setget _offset_yaw_deg_set

var _rot_x := 0.0

func rotate_x_limited(radians: float) -> void:
	_rot_x = clamp(_rot_x + radians, -deg2rad(rotation_limit_x), deg2rad(rotation_limit_x))
	_update_rotation()

func _offset_pitch_deg_set(value: float) -> void:
	if offset_pitch_deg == value:
		return
	
	offset_pitch_deg = value
	_update_rotation()

func _offset_yaw_deg_set(value: float) -> void:
	if offset_yaw_deg == value:
		return
	
	offset_yaw_deg = value
	_update_rotation()

func _update_rotation() -> void:
	var x_rot := clamp(_rot_x + deg2rad(offset_pitch_deg),
		-deg2rad(rotation_limit_x),
		deg2rad(rotation_limit_x))
	
	var y_rot := deg2rad(offset_yaw_deg)
	transform.basis = Basis()
	rotate_object_local(Vector3(0, 1, 0), y_rot)
	rotate_object_local(Vector3(1, 0, 0), x_rot)
