class_name BackgroundResourceLoader
extends Node

signal finished()

var result := []

var _paths_to_load := []
var _current_loader: ResourceInteractiveLoader
var _is_busy := false

func _init().() -> void:
	set_process(false)

func load(paths: Array) -> void:
	if _is_busy:
		assert(false, 'busy')
		return
	
	_paths_to_load = paths
	_is_busy = true
	set_process(true)

func is_busy() -> bool:
	return _is_busy

func _process(delta: float) -> void:
	if not _is_busy:
		return
	
	if _paths_to_load.empty() and not _current_loader:
		set_process(false)
		call_deferred('_on_finished')
		return
	
	if not _current_loader:
		var path := _paths_to_load.pop_front() as String
		_current_loader = ResourceLoader.load_interactive(path)
	
	var err := 0
	for i in 30:
		err = _current_loader.poll()
		if err == ERR_FILE_EOF:
			break
	
	if err != ERR_FILE_EOF:
		return
	
	result.push_back(_current_loader.get_resource())
	_current_loader = null

func _on_finished() -> void:
	_is_busy = false
	emit_signal('finished')



