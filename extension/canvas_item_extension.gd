class_name CanvasItEm
extends Node

static func children_use_material_recursive(node: CanvasItem) -> void:
	if not node:
		return
	
	for child in node.get_children():
		var item := child as CanvasItem
		if not item:
			continue
		
		item.use_parent_material = true
		children_use_material_recursive(item)
		
