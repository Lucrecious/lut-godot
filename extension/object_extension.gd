class_name ObjEct
extends Node

static func connect_once(source: Object, signal_name: String, object: Object, method: String, args := []) -> void:
	if source.is_connected(signal_name, object, method): return
	source.connect(signal_name, object, method, args)

static func disconnect_once(source: Object, signal_name: String, object: Object, method: String) -> void:
	if not source.is_connected(signal_name, object, method): return
	source.disconnect(signal_name, object, method)

static func group_call(objects: Array, method: String, args := []) -> void:
	for obj in objects:
		obj.callv(method, args)
