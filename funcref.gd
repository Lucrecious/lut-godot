class_name FuncREf
extends Reference

var _object: Object
var _method: String
var _bindings: Array

func _init(object: Object, method: String, bindings := []).() -> void:
	_object = object
	_method = method
	_bindings = bindings

func call_func(): return _object.callv(_method, _bindings)
