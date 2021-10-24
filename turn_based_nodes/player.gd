class_name TurnBased_Player
extends Node

signal command(command_node)

func on_turn() -> void:
	_on_turn()

func _on_turn() -> void:
	pass
