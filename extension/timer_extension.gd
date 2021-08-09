class_name TimEr
extends Timer


static func one_shot(wait_sec: float, object: Object, timeout_callback: String, autostart := false) -> Timer:
	var timer := Timer.new()
	timer.one_shot = true
	timer.wait_time = wait_sec
	timer.autostart = autostart
	timer.connect('timeout', object, timeout_callback)
	
	return timer

static func repeated(wait_sec: float, object: Object, timeout_callback: String, autostart := false) -> Timer:
	var timer := Timer.new()
	timer.one_shot = false
	timer.wait_time = wait_sec
	timer.autostart = autostart
	timer.connect('timeout', object, timeout_callback)
	
	return timer







