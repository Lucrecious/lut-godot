extends ItemList

export(NodePath) var _level_editor_path := NodePath()
export(NodePath) var _tile_mode_action_path := NodePath()

onready var level_editor := NodE.get_node(self, _level_editor_path, LevelEditor2) as LevelEditor2
onready var tile_mode_action := NodE.get_node(self, _tile_mode_action_path, TileActionMode) as TileActionMode

var _editing_level: Level2 = null

func _ready() -> void:
	level_editor.connect('editing_level_changed', self, '_on_editing_level_changed')
	_on_editing_level_changed()
	
	connect('item_selected', self, '_on_item_selected')

func _on_item_selected(index: int) -> void:
	if index < 0:
		tile_mode_action.set_current_tile({})
	else:
		var tile_metadata := get_item_metadata(index) as Dictionary
		print_debug(tile_metadata)
		tile_mode_action.set_current_tile(tile_metadata)

func _on_editing_level_changed() -> void:
	var level := level_editor.editing_level
	if _editing_level == level:
		return
	
	clear()
	_on_item_selected(-1)
	
	if _editing_level:
		pass
		
	_editing_level = level
	
	if _editing_level:
		var tilemaps := _editing_level.get_tilemaps()
		var tiles := []
		for map in tilemaps:
			tiles.append_array(_get_tiles(map))
		
		for t in tiles:
			add_item(t.name, t.icon)
			set_item_metadata(get_item_count() - 1, t)

func _get_tiles(tilemap: TileMap) -> Array:
	var tiles := []
	var set := tilemap.tile_set
	
	for id in set.get_tiles_ids():
		var tile := {}
		tile.name = set.tile_get_name(id)
		tile.id = id
		tile.icon = _get_icon(set, id)
		tile.parent = tilemap
		tile.tile_mode = set.tile_get_tile_mode(id)
		
		tiles.push_back(tile)
	return tiles

func _get_icon(tileset: TileSet, id: int) -> Texture:
	if tileset.tile_get_tile_mode(id) == TileSet.ATLAS_TILE:
		print_debug('not implemented')
		return null
	
	var texture := tileset.tile_get_texture(id)
	var icon := AtlasTexture.new()
	icon.atlas = texture
	if tileset.tile_get_tile_mode(id) == TileSet.SINGLE_TILE:
		icon.region = tileset.tile_get_region(id)
	elif tileset.tile_get_tile_mode(id) == TileSet.AUTO_TILE:
		var icon_coords := tileset.autotile_get_icon_coordinate(id)
		var size := tileset.autotile_get_size(id)
		var region := Rect2(icon_coords * size, size)
		icon.region = region
	
	return icon
