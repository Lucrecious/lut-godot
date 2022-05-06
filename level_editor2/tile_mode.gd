class_name TileActionMode
extends Control

enum Mode {
	FreeHand,
	Line,
	Rectangle,
}

export(NodePath) var _preview_map_path := NodePath()
export(NodePath ) var _map_cursor_path := NodePath()
export(Mode) var draw_mode := Mode.FreeHand

onready var _map_cursor := NodE.get_node_with_error(self, _map_cursor_path, TileMapCursor) as TileMapCursor
onready var _preview_map := NodE.get_node_with_error(self, _preview_map_path, TileMap) as TileMap

var _current_tile := {}
var _is_dragging := false
var _last_coords_clicked := Vector2.ZERO
var _previous_mouse_coords := Vector2.ZERO

func set_current_tile(tile: Dictionary) -> void:
	_current_tile = tile
	
	var tilemap := tile.parent as TileMap
	_map_cursor.cell_size = tilemap.cell_size
	_map_cursor.regenerate()
	
	_preview_map.cell_size = tilemap.cell_size
	_preview_map.tile_set = tilemap.tile_set
	_preview_map.global_position = tilemap.global_position

func _gui_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	
	if _current_tile.empty():
		return
	
	var mouse_event := event as InputEventMouse
	if not mouse_event:
		return
	
	var tilemap := _current_tile.parent as TileMap
	var map_position := tilemap.world_to_map(tilemap.get_local_mouse_position())
	var world_position := tilemap.map_to_world(map_position)
	
	_map_cursor.position = world_position
	
	if event.is_pressed()\
		and mouse_event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
		_is_dragging = true
		_last_coords_clicked = map_position
		_set_preview_cellv(map_position, _current_tile.id)
		
	if not event.is_pressed()\
		and mouse_event is InputEventMouseButton and event.button_index == BUTTON_LEFT:
			_is_dragging = false
			
			for p in _preview_map.get_used_cells():
				tilemap.set_cellv(p, _current_tile.id)
			var used_rect := _preview_map.get_used_rect()
			tilemap.update_bitmask_region(used_rect.position, used_rect.position + used_rect.size)
			
			_preview_map.clear()
	elif mouse_event is InputEventMouseMotion:
		if _is_dragging:
			if draw_mode == Mode.FreeHand:
				_set_preview_cell_line(_previous_mouse_coords, map_position, _current_tile.id)
			elif draw_mode == Mode.Line:
				_preview_map.clear()
				_set_preview_cell_line(_last_coords_clicked, map_position, _current_tile.id)
			elif draw_mode == Mode.Rectangle:
				_preview_map.clear()
				var a := _last_coords_clicked
				var b := map_position
			
				_set_preview_cell_rect(Rect2(a, b - a).abs(), _current_tile.id)
			else:
				assert(false, 'not supported yet')
		
		_previous_mouse_coords = map_position
		

func _set_preview_cellv(coords: Vector2, id: int) -> void:
	_preview_map.set_cellv(coords, id)
	_preview_map.update_bitmask_area(coords)

func _set_preview_cell_rect(rect: Rect2, id: int) -> void:
	for i in rect.size.x:
		for j in rect.size.y:
			_set_preview_cellv(rect.position + Vector2(i, j), id)

func _set_preview_cell_line(a: Vector2, b: Vector2, id: int) -> void:
	var points := []
	var delta := (b - a).abs() * 2.0
	var step := (b - a).sign()
	var current := a
	
	if delta.x > delta.y:
		var err := int(delta.x / 2)
		while current.x != b.x:
			points.push_back(current)
			
			err -= int(delta.y)
			if err < 0:
				current.y += step.y
				err += delta.x
			
			current.x += step.x
	else:
		var err := int(delta.y / 2)
		while current.y != b.y:
			points.push_back(current)
			
			err -= int(delta.x)
			if err < 0:
				current.x += step.x
				err += delta.y
			
			current.y += step.y
	
	for p in points:
		_set_preview_cellv(p, id)
