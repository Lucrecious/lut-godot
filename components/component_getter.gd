class_name Components

static func controller(entity: Node, error_if_node_found := true) -> Controller:
	return _component(
		entity, error_if_node_found, Controller
	) as Controller

static func velocity(entity: Node, error_if_not_found := true) -> Velocity:
	return _component(
		entity, error_if_not_found, Velocity
	) as Velocity

static func disabler(entity: Node, error_if_not_found := true) -> ComponentDisabler:
	return _component(
		entity, error_if_not_found, ComponentDisabler
	) as ComponentDisabler

static func _component(entity: Node, error_if_node_found: bool, type) -> Node:
	if error_if_node_found:
		return NodE.get_child_with_error(entity, type)
	return NodE.get_child(entity, type)
