class_name TileActionMode
extends Control

signal draw_mode_changed()

enum Mode {
	FreeHand,
	Line,
	Rectangle,
}

export(NodePath) var _preview_map_path := NodePath()
export(NodePath ) var _map_cursor_path := NodePath()

export(Mode) var draw_mode := Mode.FreeHand setget _draw_mode_set
func _draw_mode_set(value: int) -> void:
	if draw_mode == value:
		return
	
	draw_mode = value
	emit_signal('draw_mode_changed')

export(int) var brush_thickness := 1

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
		_set_cellsv(_preview_map, [map_position], _current_tile.id, brush_thickness)
		
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
				_set_cell_line(_preview_map, _previous_mouse_coords, map_position, _current_tile.id, brush_thickness)
			elif draw_mode == Mode.Line:
				_preview_map.clear()
				if map_position.is_equal_approx(_last_coords_clicked):
					_set_cellsv(_preview_map, [map_position], _current_tile.id, brush_thickness)
				else:
					_set_cell_line(_preview_map, _last_coords_clicked, map_position, _current_tile.id, brush_thickness)
			elif draw_mode == Mode.Rectangle:
				_preview_map.clear()
				var a := _last_coords_clicked
				var b := map_position
				var delta := b - a
				if a.is_equal_approx(b):
					_set_cellsv(_preview_map, [a], _current_tile.id, 1)
				elif is_equal_approx(delta.x, 0) or is_equal_approx(delta.y, 0):
					_set_cell_line(_preview_map, a, b, _current_tile.id, 1)
				else:
					_set_cell_rect(_preview_map, Rect2(a, b - a).abs(), _current_tile.id)
			else:
				assert(false, 'not supported yet')
		
		_previous_mouse_coords = map_position
		

func _set_cellsv(tilemap: TileMap, coords: PoolVector2Array, id: int, thickness: int) -> void:
	if coords.empty():
		return
	
	for coord in coords:
		for i in thickness:
			for j in thickness:
				tilemap.set_cellv(coord + (Vector2.DOWN * i) + (Vector2.RIGHT * j), id)
	
	var used_rect := tilemap.get_used_rect()
	tilemap.update_bitmask_region(used_rect.position, used_rect.position + used_rect.size)

func _set_cell_rect(tilemap: TileMap, rect: Rect2, id: int) -> void:
	var points := PoolVector2Array()
	for i in rect.size.x:
		for j in rect.size.y:
			points.push_back(rect.position + Vector2(i, j))
	
	_set_cellsv(tilemap, points, id, 1)

func _set_cell_line(tilemap: TileMap, a: Vector2, b: Vector2, id: int, thickness: int) -> void:
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
		
	_set_cellsv(tilemap, points, id, thickness)
