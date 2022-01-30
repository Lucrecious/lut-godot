class_name DeathTimer
extends Node

export(float) var sec := 1.0

func _ready():
	var timer := Timer.new()
	timer.wait_time = sec
	timer.one_shot = true
	timer.autostart = true
	
	add_child(timer)
	
	timer.connect('timeout', get_parent(), 'queue_free', [], CONNECT_ONESHOT)
	
	timer.start()
