class_name LevelEditor2
extends CanvasLayer

signal editing_level_changed()
signal editable_scenes_changed()

export(String) var custom_toggle_action := ''
export(String) var level_group := '__edit_level'
export(String) var left_click_action := ''
export(String) var right_click_action := ''

onready var commands := $Commands as LevelEditor2Commands
onready var _levels := $Levels
onready var _root_hud_control := $HUDLayer/HUD as Control

var editing_level: Level2 = null setget _editing_level_set
func _editing_level_set(value: Level2) -> void:
	if editing_level == value:
		return
	
	editing_level = value
	emit_signal('editing_level_changed')

var _editing := false
var _path_to_level2 := {}

func commit_editing_level() -> void:
	if not editing_level:
		return
	
	var packed_scene := PackedScene.new()
	packed_scene.pack(editing_level.get_orphan_scene())
	commands.commit_level(editing_level.tree_scene.filename, packed_scene)

func reload_editing_level() -> void:
	if not editing_level:
		return
	
	var parent := editing_level.tree_scene.get_parent()
	editing_level.connect('tree_exited', self,
		'_on_editing_tree_scene_exited_for_reload', [parent, editing_level.get_orphan_scene()],
		CONNECT_ONESHOT)
	editing_level.tree_scene.queue_free()

func _on_editing_tree_scene_exited_for_reload(parent: Node, new_level: Node) -> void:
	parent.call_deferred('add_child', new_level)

func get_editable_scenes() -> Array:
	var scenes := []
	for level in _path_to_level2.values():
		scenes.push_back(get_node(level.absolute_path))
	return scenes

func _ready() -> void:
	get_tree().connect('node_added', self, '_on_node_added')
	for node in get_tree().get_nodes_in_group(level_group):
		_on_node_added(node)
	
	get_tree().connect('node_removed', self, '_on_node_removed')
	
	if _levels.get_child_count() <= 0:
		return
	
	self.editing_level = _levels.get_child(0)

func _on_node_added(node: Node) -> void:
	if not node.is_in_group(level_group):
		return
	
	if node.filename.empty():
		assert(false)
		return
	
	assert(not node.filename in _path_to_level2)
	
	var level2 := Level2.new()
	level2.absolute_path = node.get_path()
	
	_path_to_level2[node.filename] = level2
	_levels.add_child(level2)
	emit_signal('editable_scenes_changed')

func get_level_owner(node: Node) -> Level2:
	for l in _path_to_level2.values():
		if not NodE.is_ancestor(node, l.tree_scene):
			continue
		
		return l
	return null
	

func _on_node_removed(node: Node) -> void:
	if not node.is_in_group(level_group):
		return
	
	if node.filename.empty():
		assert(false)
		return
	
	assert(node.filename in _path_to_level2)
	
	var level2 := _path_to_level2.get(node.filename, null) as Level2
	if level2:
		level2.queue_free()
	
	_path_to_level2.erase(node.filename)
	
	if level2 == editing_level:
		self.editing_level = null
	
	emit_signal('editable_scenes_changed')

func _input(event: InputEvent) -> void:
	var previous_editing := _editing
	
	if custom_toggle_action.empty():
		if not event is InputEventKey:
			return
		
		if not  event.is_pressed():
			return
		
		if event.scancode != KEY_ESCAPE:
			return
		
		_editing = not _editing
	else:
		if not event.is_action_pressed(custom_toggle_action):
			return
		
		_editing = not _editing
	
	if _editing == previous_editing:
		return
	
	if _editing:
		_root_hud_control.enable()
	else:
		_root_hud_control.disable()
