extends Tabs

const keybind_property_scene := preload('res://lut-godot/ui/keybind_property.tscn')

export(Array, String) var _bindable_actions := []

onready var _vbox := $VBox as VBoxContainer
onready var _wait_for_key := $WaitForKey as WindowDialog

func _ready() ->void:
	for action in _bindable_actions:
		var keybind := keybind_property_scene.instance() as UI_KeybindProperty
		keybind.text = action
		keybind.button_text = _display_for_action(action)
		_vbox.add_child(keybind)
		keybind.connect('button_pressed', self, '_on_keybind_pressed', [action, keybind])

func _on_keybind_pressed(action, keybind: UI_KeybindProperty) -> void:
	_wait_for_key.popup_centered()
	
	_wait_for_key.reset()
	
	yield(_wait_for_key, 'popup_hide')
	
	var last_valid_input_event := _wait_for_key.last_valid_input_event() as InputEvent
	if not last_valid_input_event:
		return
	
	
	InputMap.action_erase_events(action)
	InputMap.action_add_event(action, last_valid_input_event)
	keybind.button_text = _display_for_action(action)
	

func _event_for_action(action: String) -> InputEvent:
	var input_events := InputMap.get_action_list(action)
	
	for e in input_events:
		return e
	
	return null

func _display_for_action(action: String) -> String:
	var event := _event_for_action(action)
	
	if event is InputEventKey:
		return OS.get_scancode_string(event.scancode)
	
	if event is InputEventJoypadButton:
		return Input.get_joy_button_string(event.button_index)
	
	if event is InputEventJoypadMotion:
		var s := sign(event.axis_value)
		return '%s %s' % [Input.get_joy_axis_string(event.axis), 'P' if s > 0 else 'N']
	
	return ''
