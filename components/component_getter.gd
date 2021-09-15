class_name Components

static func controller(entity: Node, error_if_node_found := true) -> Component_Controller:
	return _component(entity, error_if_node_found, Component_Controller) as Component_Controller

static func velocity(entity: Node, error_if_not_found := true) -> Component_Velocity:
	return _component(entity, error_if_not_found, Component_Velocity) as Component_Velocity

static func _component(entity: Node, error_if_node_found: bool, type) -> Node:
	if error_if_node_found:
		return NodE.get_child_with_error(entity, type)
	return NodE.get_child(entity, type)
