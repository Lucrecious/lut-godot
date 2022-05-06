extends SpinBox

export(NodePath) var _tile_action_mode_path := NodePath()

onready var tile_action_mode := NodE.get_node_with_error(self, _tile_action_mode_path, TileActionMode) as TileActionMode

func _ready() -> void:
	tile_action_mode.connect('draw_mode_changed', self, '_on_draw_mode_changed')
	_on_draw_mode_changed()
	
	connect('value_changed', self, '_on_value_changed')

func _on_draw_mode_changed() -> void:
	if tile_action_mode.draw_mode == TileActionMode.Mode.FreeHand or tile_action_mode.draw_mode == TileActionMode.Mode.Line:
		visible = true
	else:
		visible = false

func _on_value_changed(value: float) -> void:
	tile_action_mode.brush_thickness = int(value)
