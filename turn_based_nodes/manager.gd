class_name TurnBased_Manager
extends Node

signal turn_changed()

export(int) var turn := 0 setget _turn_set

var _current_player: TurnBased_Player = null

func _ready() -> void:
	connect('turn_changed', self, '_on_turn_changed', [])
	_on_turn_changed()

func _on_turn_changed() -> void:
	_switch_players()

func _switch_players() -> void:
	if _current_player:
		_current_player.disconnect('command', self, '_on_command')
	
	_current_player = get_child(turn % get_child_count())
	
	if _current_player:
		_current_player.connect('command', self, '_on_command')
		_current_player.on_turn()

func _on_command(command: TurnBased_Command) -> void:
	command.execute()
	
	if command.go_to_next:
		_turn_set(turn + 1)
		return

func _turn_set(value: int) -> void:
	if value == turn:
		return
	
	turn = value
	
	# Delay the signal for the idle frame
	yield(get_tree(), 'idle_frame')
	emit_signal('turn_changed')

