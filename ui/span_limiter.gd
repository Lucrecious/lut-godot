class_name SpanLimiter
extends MarginContainer

export(float) var max_span := 100_000.0
export(float) var min_span := 720.0

var _on_browser_scroll_js_callback := JavaScript.create_callback(self, '_on_browser_scroll')
var gameIFrame

func _ready() -> void:
	if not OS.get_name() == 'HTML5':
		return
	
	var parent = JavaScript.get_interface('window').parent
	gameIFrame = parent.document.getElementById('arpeegees-game-frame')
	
	parent.addEventListener('scroll', _on_browser_scroll_js_callback)

func _on_browser_scroll(args) -> void:
	var parent := get_parent() as CanvasLayer
	var top = gameIFrame.getBoundingClientRect().top
	if top > 0:
		parent.offset.y = 0
	else:
		var screen_scale := OS.get_screen_scale()
		var viewport_scale := get_viewport_rect().size.y / float(get_viewport().size.y)
		var scale := screen_scale * viewport_scale
		#printt(scale, viewport_scale, -top, -top * scale)
		parent.offset.y = -top * scale

func _init() -> void:
	connect('resized', self, '_on_SpanLimiter_resized')

func _on_SpanLimiter_resized():
	_limit_span()

func _limit_span():
	if rect_size.x > max_span:
		var half_margin = (rect_size.x - max_span) / 2.0
		
		set("custom_constants/margin_left", half_margin)
		set("custom_constants/margin_right", half_margin)
	elif rect_size.x < min_span:
		var half_margin = (min_span - rect_size.x) / 2.0
		
		set("custom_constants/margin_left", -half_margin)
		set("custom_constants/margin_right", -half_margin)
	else:
		set("custom_constants/margin_left", 0)
		set("custom_constants/margin_right", 0)
