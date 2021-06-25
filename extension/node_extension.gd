class_name NodE
extends Reference

static func get_child(node: Node, type) -> Node:
	if not node: return null
	
	for child in node.get_children():
		if not child is type: continue
		return child
	
	return null

static func get_sibling(node: Node, type) -> Node:
	var parent := node.get_parent()
	if not parent: return null
	
	for child in parent.get_children():
		if not child is type: continue
		return child
	
	return null

static func set_owner_recursive(root: Node, owner: Node) -> void:
	if not root: return
	
	if root != owner:
		root.set_owner(owner)
	
	for c in root.get_children():
		set_owner_recursive(c, owner)
