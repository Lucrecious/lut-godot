class_name BackgroundResourceLoader
extends Reference

signal finished()

var result = null

var _worker: Thread = null

func load(paths: PoolStringArray) -> void:
	_worker = Thread.new()
	
	_worker.start(self, '_load_resource', paths)

func _load_resource(paths: PoolStringArray) -> Array:
	var resources := []
	for p in paths:
		var resource := load(p)
		resources.push_back(resource)
	
	call_deferred('_on_finished')
	
	return resources

func _on_finished() -> void:
	result = _worker.wait_to_finish()
	emit_signal('finished')



