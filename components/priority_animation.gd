class_name PriorityAnimationPlayer
extends AnimationPlayer

signal animation_changEd(old, new)

export(bool) var debug_print := false

# The last animation that was played but not stopped explicitly
var last_unstopped_animation_name := ''

func _ready() -> void:
	connect('animation_changEd', self, '_on_animation_changEd')
	connect('animation_finished', self, '_on_animation_finished')
	connect('animation_changed', self, '_on_animation_changed')
	
	for child in get_children():
		var signal_expression := child as SignalExpression
		if signal_expression:
			signal_expression.connect('conditions_met', self, '_on_conditions_met', [signal_expression])
			signal_expression.connect('conditions_unmet', self, '_on_conditions_unmet', [signal_expression])
			continue
		
		var placeholder := child as PriorityNodePlaceholder
		if placeholder: continue
		
		assert(false, 'not recognized type')
		continue
	
	play_default()

# override to include extra signal
func play(name: String = "", custom_blend: float = -1, custom_speed: float = 1.0, from_end: bool = false):
	if current_animation == name: return
	assert(has_animation(name))
	var blend_time := custom_blend if custom_blend >= 0 else get_blend_time(last_unstopped_animation_name, name)
	var old := current_animation
	
	# this ensures that the previous blend doesn't interfere with current blend.
	# i.e. if run transitions to idle with 1 second blend, but idle to jump transitions with
	# 0 blend, this forces the 0 blend to override 
	if blend_time == 0:
		.stop()
	
	
	if debug_print:
		printt('playing: "%s", from last unstopped "%s".' % [name, last_unstopped_animation_name])
	
	last_unstopped_animation_name = name
	.play(name, blend_time, custom_speed, from_end)
	emit_signal('animation_changEd', old, name)

func stop(reset := true) -> void:
	last_unstopped_animation_name = ''
	if not is_playing(): return
	var current := current_animation
	.stop(reset)
	emit_signal('animation_changEd', current, '')

func _on_animation_finished(animation: String) -> void:
	emit_signal('animation_changEd', animation, '')

func _on_animation_changed(old: String, new: String) -> void:
	emit_signal('animation_changEd', old, new)

var _playing_for_callback := false
var _play_priority := -1

func _on_conditions_met(sender: SignalExpression) -> void:
	if _play_priority > sender.get_index(): return
	
	
	#stop()
	play(sender.condition_key)
	
	_play_priority = sender.get_index()

var _callback_object: Object = null
var _callback_method := ''
func callback_on_finished(animation_name: String, sender: Node, object: Object, callback: String) -> bool:
	if _play_priority > sender.get_index(): return false
	
	#stop()
	_animation_callback()
	play(animation_name)
	seek(0, true)
	
	_play_priority = sender.get_index()
	_playing_for_callback = true
	_callback_object = object
	_callback_method = callback
	
	return true

func callback_on_finished_by_node(sender: PriorityNodePlaceholder, object: Object, callback: String) -> bool:
	assert(not sender.animation.empty())
	return callback_on_finished(sender.animation, sender, object, callback)
	

func _on_animation_changEd(_old_animation: String, _new_animation: String) -> void:
	_animation_callback()

func _animation_callback() -> void:
	if not _playing_for_callback:
		return
	
	_playing_for_callback = false
	
	var index := _play_priority
	_play_priority = -1
	
	var object := _callback_object
	var method := _callback_method
	_callback_object = null
	_callback_method = ''
	object.call(method)
	
	_play_next_highest_priority_expression(index)

func _on_conditions_unmet(sender: SignalExpression) -> void:
	if _play_priority > sender.get_index(): return
	if _play_priority < sender.get_index(): return
	var index := _play_priority
	_play_priority = -1
	_play_next_highest_priority_expression(index)

func play_default() -> void:
	_play_priority = -1
	_play_next_highest_priority_expression(get_child_count())

func reset_and_stop() -> void:
	_play_priority = -1
	stop()

func _play_next_highest_priority_expression(index: int) -> void:
	for i in range(0, index):
		var li := index - i - 1
		var expression := get_child(li) as SignalExpression
		if not expression: continue
		if not expression.is_true(): continue
		_on_conditions_met(expression)
		return




