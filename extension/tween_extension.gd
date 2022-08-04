extends Node

# signal must have no arguments.
func pause_until_signal(tween: SceneTreeTween, object: Object, signal_name: String) -> void:
	tween.tween_callback(self, '_pause_callback', [tween, object, signal_name])

# workaround for lack of cyclic references
func _pause_callback(tween: SceneTreeTween, object: Object, signal_name: String) -> void:
	tween.pause()
	
	yield(object, signal_name)
	
	tween.play()
