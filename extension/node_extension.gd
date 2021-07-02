class_name NodE
extends Reference

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

static func set_owner_recursive(root: Node, owner: Node) -> void:
	if not root: return
	
	if root != owner:
		root.set_owner(owner)
	
	for c in root.get_children():
		set_owner_recursive(c, owner)
