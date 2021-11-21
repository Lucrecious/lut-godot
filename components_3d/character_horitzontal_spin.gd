extends Spatial

export(NodePath) var _rotating_node_path := NodePath()

export(int, 1, 10_000) var sensitivity := 100 

onready var _rotating_node := get_node(_rotating_node_path) as Spatial

func _unhandled_input(event: InputEvent) -> void:
	var motion := event as InputEventMouseMotion
	if not motion:
		return
	
	var relative := motion.relative
	var amount := -relative.x / sensitivity
	
	_rotating_node.rotate_y(amount)
	
	
