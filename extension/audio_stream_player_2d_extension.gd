class_name AudioStrEamPlayer2D
extends AudioStreamPlayer2D


func play_if_not_playing(position := 0.0) -> void:
	if playing:
		return
	
	play(position)
