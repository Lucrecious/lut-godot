class_name FPSLook
extends Spatial

export(int, 1, 10_000) var sensitivity_x := 100
export(int, 1, 10_000) var sensitivity_y := 100 
export(NodePath) var _rotating_node_path := NodePath()

onready var _pivot := NodE.get_sibling_with_error(self, Camera3Pivot) as Camera3Pivot
onready var _rotating_node := get_parent() as KinematicBody

func _ready() -> void:
	assert(_rotating_node)

func get_amount_x_radians(relative: float) -> float:
	return -relative / sensitivity_x

func get_amount_y_radians(relative: float) -> float:
	return -relative / sensitivity_y

func _unhandled_input(event: InputEvent) -> void:
	var motion := event as InputEventMouseMotion
	if not motion:
		return
	
	var relative := motion.relative
	
	var amount_x := get_amount_x_radians(relative.y)
	
	if false and not is_equal_approx(_pivot.offset_pitch_deg, 0)\
	and sign(_pivot.offset_pitch_deg) != sign(amount_x):
		var pitch := abs(deg2rad(_pivot.offset_pitch_deg)) - abs(amount_x)
		if pitch < 0:
			_pivot.offset_pitch_deg = 0
			amount_x = sign(amount_x) * (-pitch)
		else:
			_pivot.offset_pitch_deg = sign(_pivot.offset_pitch_deg) * rad2deg(pitch)
			amount_x = 0
	
	if amount_x != 0:
		_pivot.rotate_x_limited(amount_x)
	
	var amount_y := get_amount_y_radians(relative.x)
	
	if false and  not is_equal_approx(_pivot.offset_yaw_deg, 0)\
	and sign(_pivot.offset_yaw_deg) != sign(amount_y):
		var yaw := abs(deg2rad(_pivot.offset_pitch_deg)) - abs(amount_y)
		if yaw < 0:
			_pivot.offset_yaw_deg = 0
			amount_y = sign(amount_y) * (-yaw)
		else:
			_pivot.offset_yaw_deg = sign(_pivot.offset_pitch_deg) * rad2deg(yaw)
			amount_y = 0
	
	if amount_y != 0:
		_rotating_node.rotate_y(amount_y)
	
