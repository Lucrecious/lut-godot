class_name UI_KeybindProperty
extends Control

signal button_pressed()

export(String) var text := 'property' setget _text_set
export(String) var button_text := '<button>' setget _button_text_set

onready var _action := $HBox/Action as Label
onready var _button := $HBox/Button as Button

onready var _is_ready := true

func _ready() -> void:
	_button.connect('pressed', self, '_on_button_pressed')

func _on_button_pressed() -> void:
	emit_signal('button_pressed')

func _button_text_set(value: String) -> void:
	button_text = value
	
	if not _is_ready:
		yield(self, 'ready')
	
	_button.text = value

func _text_set(value: String) -> void:
	text = value
	
	if not _is_ready:
		yield(self, 'ready')
	
	_action.text = text

