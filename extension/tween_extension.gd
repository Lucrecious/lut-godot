extends Node

func pause_until_signal_if_condition(tween: SceneTreeTween, signal_object: Object, signal_name: String,
		predicate_object: Object, predicate: String) -> void:
	tween.tween_callback(self, '_pause_if_condition',
			[tween, signal_object, signal_name, predicate_object, predicate])

func _pause_if_condition(tween: SceneTreeTween, signal_object: Object, signal_name: String,
		predicate_object: Object, predicate: String) -> void:
	if not predicate_object.call(predicate):
		return
	
	tween.pause()
	
	yield(signal_object, signal_name)
	
	tween.play()
