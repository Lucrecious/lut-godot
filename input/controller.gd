class_name Controller
extends Node

signal action_just_pressed()
signal action_just_released()

onready var button_input := NodE.get_child(self, IButtonInput) as IButtonInput
onready var directionals := NodE.get_children(self, IDirectionalInput)

func _ready() -> void:
	button_input.connect('action_just_pressed', self, '_on_action_just_pressed')
	button_input.connect('action_just_released', self, '_on_action_just_released')
	
	for action in button_input.actions():
		assert(action != 'action', 'reserved for action_just_pressed')
		add_user_signal('%s_just_pressed' % action)
		add_user_signal('%s_just_released' % action)
	
	for i in directionals.size():
		var d := directionals[i] as IDirectionalInput
		add_user_signal('direction%d_changed' % (i + 1), [{
			name = 'vector',
			type = TYPE_VECTOR2
		}])
		
		d.connect('direction_changed', self, '_on_direction_changed', [d, i])

func _on_action_just_pressed(action: String) -> void:
	emit_signal('%s_just_pressed' % action)
	emit_signal('action_just_pressed', action)

func _on_action_just_released(action: String) -> void:
	emit_signal('%s_just_released' % action)
	emit_signal('action_just_released', action)

func _on_direction_changed(directional: IDirectionalInput, index: int) -> void:
	emit_signal('direction%d_changed' % (index + 1), directional.get_direction())
