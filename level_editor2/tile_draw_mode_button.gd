extends Button

export(NodePath) var _tile_action_mode_path := NodePath()
export(TileActionMode.Mode) var mode := TileActionMode.Mode.FreeHand

onready var tile_action_mode := NodE.get_node(self, _tile_action_mode_path, TileActionMode) as TileActionMode

func _ready() -> void:
	connect('pressed', self, '_on_pressed')

func _on_pressed() -> void:
	tile_action_mode.draw_mode = mode
