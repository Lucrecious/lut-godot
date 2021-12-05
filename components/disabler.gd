class_name ComponentDisabler
extends Node

onready var _parent := get_parent()

func disable_below(node: Node) -> void:
	if not _parent: return
	
	var start_index := get_index() + 1
	
	
	for i in range(start_index, _parent.get_child_count()):
		var component := _parent.get_child(i)
		if component == node: break
		if not component.has_method('disable'): continue
		component.disable()

func enable(type) -> void:
	for component in _parent.get_children():
		if not component is type: continue
		
		if not component.has_method('enable'): return
		component.enable()
		return

func enable_below(node: Node) -> void:
	if not _parent: return
	
	var start_index := get_index() + 1
	
	for i in range(start_index, _parent.get_child_count()):
		var component := _parent.get_child(i)
		if component == node: break
		if not component.has_method('enable'): continue
		component.enable()





