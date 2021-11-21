class_name TurnBased_Manager
extends Node

signal turn_changed(player)

export(int) var turn := -1 setget _turn_set

var players := []

func _ready() -> void:
	yield(get_tree().create_timer(2.0), 'timeout')
	start()

func start() -> void:
	if turn > -1:
		# already started
		return
	
	_turn_set(0)

func register(node: Node, front: bool) -> void:
	if node in players:
		return
	
	if front:
		players.push_front(node)
	else:
		players.push_back(node)

func execute(command: TurnBased_Command) -> void:
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
	emit_signal('turn_changed', players[turn % players.size()])

