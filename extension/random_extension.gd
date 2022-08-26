class_name RaNdom

static func randi_range(from: int, to_inclusive: int) -> int:
	return from + (randi() % ((to_inclusive + 1) - from))
