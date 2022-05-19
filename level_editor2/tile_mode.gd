class_name TileActionMode
extends Control

signal draw_mode_changed()
signal brush_thickness_changed()

enum Mode {
	FreeHand,
	Line,
	Rectangle,
}

export(NodePath) var _preview_map_path := NodePath()
export(NodePath) var _map_cursor_path := NodePath()
export(NodePath) var _commands_path := NodePath()
export(NodePath) var _editor_path := NodePath()

export(Mode) var draw_mode := Mode.FreeHand setget _draw_mode_set
func _draw_mode_set(value: int) -> void:
	if draw_mode == value:
		return
	
	draw_mode = value
	emit_signal('draw_mode_changed')

export(int) var brush_thickness := 1 setget _brush_thickness_set
func _brush_thickness_set(value: int) -> void:
	if brush_thickness == value:
		return
	
	brush_thickness = value
	emit_signal('brush_thickness_changed')

onready var _editor := NodE.get_node(self, _editor_path, LevelEditor2) as LevelEditor2
onready var _commands := NodE.get_node(self, _commands_path, LevelEditor2Commands) as LevelEditor2Commands
onready var _map_cursor := NodE.get_node(self, _map_cursor_path, TileMapCursor) as TileMapCursor
onready var _preview_map := NodE.get_node(self, _preview_map_path, TileMap) as TileMap

var _current_tile := {}
var _is_dragging := false
var _last_coords_clicked := Vector2.ZERO
var _previous_mouse_coords := Vector2.ZERO

func _ready() -> void:
	connect('brush_thickness_changed', self, '_on_brush_thickness_changed')

func _on_brush_thickness_changed() -> void:
	if _current_tile.empty():
		return
	
	_adjust_map_cursor_size(_current_tile.parent as TileMap)

func set_current_tile(tile: Dictionary) -> void:
	if tile.empty():
		_current_tile = {}
		_map_cursor.visible = false
		return
	
	_map_cursor.visible = true
	_current_tile = tile
	
	var tilemap := tile.parent as TileMap
	_adjust_map_cursor_size(tilemap)
	
	_preview_map.cell_size = tilemap.cell_size
	_preview_map.tile_set = tilemap.tile_set
	_preview_map.global_position = tilemap.global_position

func _adjust_map_cursor_size(tilemap: TileMap) -> void:
	_map_cursor.cell_size = tilemap.cell_size * brush_thickness
	_map_cursor.regenerate()

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
	
	var mouse_button := mouse_event as InputEventMouseButton
	
	if event.is_pressed()\
		and mouse_button and\
		(mouse_button.button_index == BUTTON_LEFT or mouse_button.button_index == BUTTON_RIGHT):
		_is_dragging = true
		_last_coords_clicked = map_position
		_set_cellsv(_preview_map, [map_position], _current_tile.id, brush_thickness)
		
	elif not event.is_pressed()\
		and mouse_button and\
		(mouse_button.button_index == BUTTON_LEFT or mouse_button.button_index == BUTTON_RIGHT):
		_is_dragging = false
		
		var level_owner := _editor.get_level_owner(tilemap)
		
		if level_owner:
			if mouse_button.button_index == BUTTON_LEFT:
				_commands.copy_used_tiles(_preview_map, tilemap, level_owner)
			else:
				_commands.remove_tiles(_preview_map, tilemap, level_owner)
		else:
			assert(false, 'all tilemaps should be part of a level')
		
		_preview_map.clear()
		
	elif mouse_event is InputEventMouseMotion:
		if _is_dragging:
			if draw_mode == Mode.FreeHand:
				_set_cell_line(_preview_map, _previous_mouse_coords, map_position, _current_tile.id, brush_thickness)
			elif draw_mode == Mode.Line:
				_preview_map.clear()
				
				var a := _last_coords_clicked
				var b := map_position
				var delta := b - a
				
				if mouse_event.shift:
					if abs(delta.x) > abs(delta.y):
						b.y = a.y
						delta.y = 0
					else:
						b.x = a.x
						delta.x = 0
				
				if a.is_equal_approx(b):
					_set_cellsv(_preview_map, [a], _current_tile.id, brush_thickness)
				else:
					_set_cell_line(_preview_map, a, b, _current_tile.id, brush_thickness)
			elif draw_mode == Mode.Rectangle:
				_preview_map.clear()
				
				var a := _last_coords_clicked
				var b := map_position
				var delta := b - a
				
				if mouse_event.shift:
					if abs(delta.x) > abs(delta.y):
						b.y = a.y + abs(delta.x)
					else:
						b.x = a.x + abs(delta.y)
					
					delta = b - a
				
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
