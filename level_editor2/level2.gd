class_name Level2
extends Node

var absolute_path := NodePath()

var _tilemaps := []

func _ready() -> void:
	var level := get_node(absolute_path)
	
	_tilemaps = NodE.get_children_recursive(level, TileMap)

func get_tilemaps() -> Array:
	return _tilemaps.duplicate()
