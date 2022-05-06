extends OptionButton

export(NodePath) var _level_editor_path := NodePath()

onready var _level_editor := NodE.get_node_with_error(self, _level_editor_path, LevelEditor2) as LevelEditor2

func _ready() -> void:
	_level_editor.connect('editable_scenes_changed', self, '_on_editable_scenes_changed')
	_on_editable_scenes_changed()
	
	_level_editor.connect('editing_level_changed', self, '_on_editing_level_changed')
	_on_editing_level_changed()

func _on_editable_scenes_changed() -> void:
	clear()
	for scene in _level_editor.get_editable_scenes():
		add_item(scene.name, scene.get_instance_id())
	
	_on_editing_level_changed()

func _on_editing_level_changed() -> void:
	if not _level_editor.editing_level:
		if get_item_count() > 0:
			select(0)
		return
	
	var found_index := get_item_index(_level_editor.editing_level.get_instance_id())
	if found_index < 0:
		if get_item_count() > 0:
			select(0)
		return
	
	select(found_index)