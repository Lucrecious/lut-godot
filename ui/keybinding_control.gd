extends Tabs

const keybind_property_scene := preload('res://lut-godot/ui/keybind_property.tscn')

export(Array, String) var _bindable_actions := []

onready var _vbox := $VBox as VBoxContainer
onready var _wait_for_key := $WaitForKey as WindowDialog

func _ready() ->void:
	for action in _bindable_actions:
		var keybind := keybind_property_scene.instance() as UI_KeybindProperty
		keybind.text = action
		keybind.button_text = _scancode_for_action(action)
		_vbox.add_child(keybind)
		keybind.connect('button_pressed', self, '_on_keybind_pressed', [action, keybind])

func _on_keybind_pressed(action, keybind: UI_KeybindProperty) -> void:
	_wait_for_key.popup_centered()
	
	_wait_for_key.reset()
	
	yield(_wait_for_key, 'popup_hide')
	
	if _wait_for_key.last_scancode_pressed() == 0:
		return
	
	var key_event := _key_event_for_action(action)
	InputMap.action_erase_event(action, key_event)
	key_event.scancode = _wait_for_key.last_scancode_pressed()
	InputMap.action_add_event(action, key_event)
	keybind.button_text = _scancode_for_action(action)
	

func _key_event_for_action(action: String) -> InputEventKey:
	var input_events := InputMap.get_action_list(action)
	
	for e in input_events:
		if not e is InputEventKey:
			continue
		return e
	
	return null

func _scancode_for_action(action: String) -> String:
	var keyevent := _key_event_for_action(action)
	
	if keyevent:
		return OS.get_scancode_string(keyevent.scancode)
	
	return ''
