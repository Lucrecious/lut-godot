tool
class_name UI_SliderProperty
extends Control

signal value_changed(value)

onready var _label := $HBoxContainer/Label as Label
onready var _slider := $HBoxContainer/HSlider as HSlider

onready var _is_ready := true

export(String) var text := 'property' setget _text_set
export(float, 0.0, 1.0) var value := 0.0 setget _value_set 

func _ready() -> void:
	if Engine.editor_hint:
		return
	
	_slider.connect('value_changed', self, '_update_own_value')

func _text_set(value: String) -> void:
	text = value
	
	if not _is_ready:
		yield(self, 'ready')
	
	_label.text = value

func _update_own_value(value: float) -> void:
	_value_set(inverse_lerp(_slider.min_value, _slider.max_value, value))

func _value_set(value_: float) -> void:
	if is_equal_approx(value, value_):
		return
	
	value = value_
	
	emit_signal('value_changed', value)
	
	if not _is_ready:
		yield(self, 'ready')
	
	_slider.value = lerp(_slider.min_value, _slider.max_value, value_)

