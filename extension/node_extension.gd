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
	
	if not node or not is_instance_valid(node):
		return
	
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

static func add_children(node: Node, children: Array) -> void:
	assert(node)
	for child in children:
		node.add_child(child)

static func get_node(node: Node, path: NodePath, type, error := true) -> Node:
	var found := node.get_node_or_null(path)
	if found and found is type:
		return found
	
	assert(not error, 'must be found')
	return null

static func get_ancestor(node: Node, type, with_error := true) -> Node:
	if not node:
		assert(not with_error)
		return null
	
	var parent := node.get_parent()
	if parent is type:
		return parent
	
	return get_ancestor(node.get_parent(), type)

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

static func get_child(node: Node, type, with_error := true) -> Node:
	if not node:
		assert(not with_error)
		return null
	
	for child in node.get_children():
		if not child is type: continue
		return child
	
	assert(not with_error)
	return null

static func get_children(node: Node, type) -> Array:
	if not node:
		return []
	
	var children := []
	for i in node.get_child_count():
		var child := node.get_child(i)
		if not child is type:
			continue
		
		children.push_back(child)
	
	return children

static func get_children_recursive(node: Node, type) -> Array:
	if not node:
		return []
	
	var children := get_children(node, type)
	for child in node.get_children():
		children += get_children_recursive(child, type)
	
	return children
	
static func get_sibling(node: Node, type, with_error := true) -> Node:
	var parent := node.get_parent()
	if not parent: 
		assert(not with_error)
		return null
	
	for child in parent.get_children():
		if not child is type: continue
		return child
	
	assert(not with_error)
	return null

static func get_child_by_group(parent: Node, group: String) -> Node:
	for c in parent.get_children():
		if not c.is_in_group(group):
			continue
		return c
	return null

static func set_owner_recursive(root: Node, owner: Node) -> void:
	if not root: return
	
	if root != owner:
		root.set_owner(owner)
	
	for c in root.get_children():
		set_owner_recursive(c, owner)

static func is_ancestor(node: Node, parent: Node) -> bool:
	if not node.get_parent():
		return false
	
	if node.get_parent() == parent:
		return true
	
	return is_ancestor(node.get_parent(), parent)
