class_name SpanLimiter
extends MarginContainer

export(float) var max_span := 100_000.0
export(float) var min_span := 720.0

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
