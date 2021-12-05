class_name Input_ActionBinding_Directional
extends Input_ActionBinding

export(String) var action_name := ''
export(String, 'any', 'none', 'none_y', 'none_x', 'custom') var direction_type := 'any'
export(Vector2) var direction := Vector2.DOWN
export(float) var angle_deg := 45
export(bool) var x_symmetry := true

func _ready() -> void:
	assert(direction != Vector2.ZERO)

func is_pressed(controller: Controller) -> bool:
	if not controller.is_action_pressed(action_name): return false
	
	if direction_type == 'any': return true
	
	if direction_type == 'custom' and\
		not controller.direction.is_equal_approx(Vector2.ZERO) and\
		(abs(rad2deg(direction.angle_to(controller.direction))) < angle_deg or\
		(x_symmetry and abs(rad2deg(direction.angle_to(controller.direction * Vector2(-1, 1)))) < angle_deg)):
			return true
	
	if direction_type == 'none' and controller.direction.is_equal_approx(Vector2.ZERO): return true
	
	if direction_type == 'none_x' and controller.direction.x == 0: return true
	
	if direction_type == 'none_y' and controller.direction.y == 0: return true
	
	return false
	
