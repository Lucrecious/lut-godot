class_name SignalDetector
extends Reference

var _signal_raised := false

var _signal_name := ''
var _object: Object = null

func raised() -> bool: return _signal_raised

func _init(object: Object, signal_name: String).():
	_signal_name = signal_name
	_object = object
	_object.connect(_signal_name, self, '_on_signal_called')

func _on_signal_called(_1=null,_2=null,_3=null,_4=null,_5=null,_6=null) -> void:
	_object.disconnect(_signal_name, self, '_on_signal_called')
	_signal_raised = true
