class_name Controller
extends Node

signal user_changed()

signal action_just_pressed()
signal action_just_released()

enum User {
	None,
	Player,
	Computer,
}

export(User) var user := User.Player setget _user_set
func _user_set(value: int) -> void:
	if user == value:
		return
	
	user = value
	emit_signal('user_changed')

onready var button_input := NodE.get_child(self, ButtonInput) as ButtonInput
onready var directionals := NodE.get_children(self, IDirectionalInput)

var _pressed_cache := {}

func disable() -> void:
	self.user = User.None
	clear_all_input()

# all buttons are released, all directionals are changed to the zero-vector
func clear_all_input() -> void:
	for action in _pressed_cache:
		if _pressed_cache[action]:
			release(action)
	
	for i in directionals.size():
		var direction := directionals[i].get_direction() as Vector2
		if not direction.is_equal_approx(Vector2.ZERO):
			set_direction(i, Vector2.ZERO)

func is_pressed(action: String) -> bool:
	return _pressed_cache.get(action, false)

func press(action: String) -> void:
	if user != User.Computer:
		return
	
	_press(action)

func _press(action: String) -> void:
	_pressed_cache[action] = true
	
	emit_signal('%s_just_pressed' % action)
	emit_signal('action_just_pressed', action)

func release(action: String) ->  void:
	if user != User.Computer:
		return
	
	_release(action)

func _release(action: String) -> void:
	_pressed_cache[action] = false
	
	emit_signal('%s_just_released' % action)
	emit_signal('action_just_released', action)

func get_direction(index: int) -> Vector2:
	return directionals[index].get_direction()

func set_direction(index: int, value: Vector2) -> void:
	if user != User.Computer:
		return
	
	_set_direction(index, value)

func _set_direction(index: int, value: Vector2) -> void:
	emit_signal('direction%d_changed' % (index + 1), value)

func _ready() -> void:
	for action in button_input.get_actions():
		assert(action != 'action', 'reserved for action_just_pressed')
		add_user_signal('%s_just_pressed' % action)
		add_user_signal('%s_just_released' % action)
	
	for i in directionals.size():
		add_user_signal('direction%d_changed' % (i + 1), [{
			name = 'vector',
			type = TYPE_VECTOR2
		}])
	
	connect('user_changed', self, '_on_user_changed')
	_on_user_changed()

func _on_user_changed() -> void:
	match user:
		User.Player:
			ObjEct.connect_once(button_input, 'action_just_pressed', self, '_on_action_just_pressed')
			ObjEct.connect_once(button_input, 'action_just_released', self, '_on_action_just_released')
			for i in directionals.size():
				var d := directionals[i] as IDirectionalInput
				ObjEct.connect_once(d, 'direction_changed', self, '_on_direction_changed', [d, i])
		
		User.None:
			continue
		User.Computer:
			ObjEct.disconnect_once(button_input, 'action_just_pressed', self, '_on_action_just_pressed')
			ObjEct.disconnect_once(button_input, 'action_just_pressed', self, '_on_action_just_pressed')
			
			for i in directionals.size():
				var d := directionals[i] as IDirectionalInput
				ObjEct.disconnect_once(d, 'direction_changed', self, '_on_direction_changed')
				
func _on_action_just_pressed(action: String) -> void:
	_press(action)

func _on_action_just_released(action: String) -> void:
	_release(action)

func _on_direction_changed(directional: IDirectionalInput, index: int) -> void:
	_set_direction(index, directional.get_direction())
