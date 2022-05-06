class_name LevelEditor2Commands
extends Node

signal committed_level(filename)
signal tilemap_changed(tilemap, region)

var _undoredo := UndoRedo.new()

func copy_used_tiles(source: TileMap, destination: TileMap, owner_level: Level2) -> void:
	var previous := {}
	var current := {}
	for cell in source.get_used_cells():
		previous[cell] = destination.get_cellv(cell)
		current[cell] = source.get_cellv(cell)
	
	_undoredo.create_action('Add Tiles')
	_undoredo.add_do_method(self, '_replace_tiles', owner_level, destination, current)
	_undoredo.add_undo_method(self, '_replace_tiles', owner_level, destination, previous)
	_undoredo.commit_action()
	
	emit_signal('tilemap_changed', destination, source.get_used_rect())

func remove_tiles(source: TileMap, destination: TileMap, owner_level: Level2) -> void:
	var previous := {}
	var current := {}
	for cell in source.get_used_cells():
		previous[cell] = destination.get_cellv(cell)
		current[cell] = -1
	
	_undoredo.create_action('Remove Tiles')
	_undoredo.add_do_method(self, '_replace_tiles', owner_level, destination, current)
	_undoredo.add_undo_method(self, '_replace_tiles', owner_level, destination, previous)
	_undoredo.commit_action()
	
	emit_signal('tilemap_changed', destination, source.get_used_rect())

func commit_level(path: String, scene: PackedScene) -> void:
	if not path.ends_with('.tscn'):
		assert(false)
		return
	
	var directory := Directory.new()
	if directory.file_exists(path):
		directory.copy(path, '%s.backup.tscn' % [path.left(path.find_last('.'))])
	
	ResourceSaver.save(path, scene)
	
	emit_signal('committed_level', path)

func _replace_tiles(owner_level: Level2, tilemap: TileMap, coords_to_id: Dictionary) -> void:
	if coords_to_id.empty():
		return
	
	var editing_level_tilemap := owner_level.get_orphan_equivalent(tilemap) as TileMap
	
	for c in coords_to_id:
		tilemap.set_cellv(c, coords_to_id[c])
		tilemap.update_bitmask_area(c)
		
		editing_level_tilemap.set_cellv(c, coords_to_id[c])
		editing_level_tilemap.update_bitmask_area(c)
		
