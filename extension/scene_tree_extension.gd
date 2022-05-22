class_name TrEe
extends Node

static func get_single_node_in_group(tree: SceneTree, group: String, error_on_null := true) -> Node:
	var nodes := tree.get_nodes_in_group(group)
	if nodes.empty():
		assert(not error_on_null)
		return null
	
	return nodes[0]
