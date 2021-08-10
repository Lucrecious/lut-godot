class_name NodE

static func pause_interval(node: Node, sec: float) -> void:
	if not node: return
	
	var processing := node.is_processing()
	var physics_processing := node.is_physics_processing()
	var input_processing := node.is_processing_input()
	var unhandled_key_input_processing := node.is_processing_unhandled_key_input()
	var unhandled_input_processing := node.is_processing_unhandled_input()
	var internal_processing := node.is_processing_internal()
	var internal_physics_processing := node.is_physics_processing_internal()
	
	node.set_process(false)
	node.set_physics_process(false)
	node.set_process_input(false)
	node.set_process_unhandled_key_input(false)
	node.set_process_unhandled_input(false)
	node.set_process_internal(false)
	node.set_physics_process_internal(false)
	
	for child in node.get_children():
		pause_interval(child, sec)
	
	yield(node.get_tree().create_timer(sec), 'timeout')
	
	node.set_process(processing)
	node.set_physics_process(physics_processing)
	node.set_process_input(input_processing)
	node.set_process_unhandled_key_input(unhandled_key_input_processing)
	node.set_process_unhandled_input(unhandled_input_processing)
	node.set_process_internal(internal_processing)
	node.set_physics_process_internal(internal_physics_processing)

static func add_child(node: Node, child: Node) -> Node:
	if not node: return null
	if not child: return null
	node.add_child(child)
	return child

static func get_node_with_error(node: Node, path: NodePath, type) -> Node:
	var found := node.get_node_or_null(path)
	if found and found is type: return found
	
	assert(false, 'must be found')
	return null

static func get_ancestor(node: Node, type) -> Node:
	if not node: return null
	
	var parent := node.get_parent()
	if parent is type: return parent
	
	return get_ancestor(node.get_parent(), type)

static func get_ancestor_with_error(node: Node, type) -> Node:
	var ancestor := get_ancestor(node, type)
	assert(ancestor, 'must be found')
	return ancestor

static func get_child_by_name(node: Node, name: String) -> Node:
	if not node: return null
	
	for child in node.get_children():
		if child.name != name: continue
		return child
	
	return null

static func get_sibling_by_name(node: Node, name: String) -> Node:
	if not node:
		assert(false, 'must return something')
		return null
	
	var sibling := get_child_by_name(node.get_parent(), name)
	if not sibling:
		assert(false, 'must return something')
		return null
	
	return sibling

static func get_child(node: Node, type) -> Node:
	if not node: return null
	
	for child in node.get_children():
		if not child is type: continue
		return child
	
	return null

static func get_child_with_error(node: Node, type) -> Node:
	var child := get_child(node, type)
	assert(child, 'must be found')
	return child

static func get_sibling(node: Node, type) -> Node:
	var parent := node.get_parent()
	if not parent: return null
	
	for child in parent.get_children():
		if not child is type: continue
		return child
	
	return null

static func get_sibling_with_error(node: Node, type) -> Node:
	var child := get_sibling(node, type)
	assert(child, 'must be not null')
	return child

static func get_node_with_child_type(node: Node, type) -> Node:
	if not node:
		return null
	
	for child in node.get_children():
		var child_of_type := get_child(child, type)
		if not child_of_type:
			continue
		
		return child
	
	return null

static func set_owner_recursive(root: Node, owner: Node) -> void:
	if not root: return
	
	if root != owner:
		root.set_owner(owner)
	
	for c in root.get_children():
		set_owner_recursive(c, owner)
