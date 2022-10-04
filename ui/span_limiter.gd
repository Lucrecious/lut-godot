class_name SpanLimiter
extends MarginContainer

const MAX_SPAN := 100_000
const MIN_SPAN := 720

func _init() -> void:
	connect('resized', self, '_on_SpanLimiter_resized')

func _on_SpanLimiter_resized():
	_limit_span()

func _limit_span():
	if rect_size.x > MAX_SPAN:
		var half_margin = (rect_size.x - MAX_SPAN) / 2.0
		
		set("custom_constants/margin_left", half_margin)
		set("custom_constants/margin_right", half_margin)
	elif rect_size.x < MIN_SPAN:
		var half_margin = (MIN_SPAN - rect_size.x) / 2.0
		
		set("custom_constants/margin_left", -half_margin)
		set("custom_constants/margin_right", -half_margin)
	else:
		set("custom_constants/margin_left", 0)
		set("custom_constants/margin_right", 0)
