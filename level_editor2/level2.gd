class_name Level2
extends Node

var absolute_path := NodePath()

onready var tree_scene := get_node(absolute_path)

var _tilemaps := []

var _orphan_scene: Node = null 

func _ready() -> void:
	_orphan_scene = load(tree_scene.filename).instance()
	
	_tilemaps = NodE.get_children_recursive(tree_scene, TileMap)

func get_tilemaps() -> Array:
	return _tilemaps.duplicate()

func get_orphan_scene() -> Node:
	return _orphan_scene

func get_orphan_equivalent(node: Node) -> Node:
	if not NodE.is_ancestor(node, tree_scene):
		assert('should only be called with children of the level')
		return null
	
	var relative_path := tree_scene.get_path_to(node)
	
	var equivalent_node := _orphan_scene.get_node_or_null(relative_path)
	
	assert(equivalent_node, 'editing level and the level should be the same')
	
	return equivalent_node
