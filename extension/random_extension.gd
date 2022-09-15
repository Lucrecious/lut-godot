class_name RaNdom

static func randi_range(from: int, to_inclusive: int) -> int:
	return from + (randi() % ((to_inclusive + 1) - from))

static func random_unit_vector() -> Vector2:
	var x := rand_range(-1, 1)
	var y := sqrt(1.0 - x * x)
	y *= -1 if randf() > 0.5 else 1
	return Vector2(x, y)
