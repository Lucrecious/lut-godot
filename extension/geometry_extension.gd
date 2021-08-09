class_name GEometry

static func rects_touch(rect1: Rect2, rect2: Rect2) -> bool:
	return rect1.intersects(rect2) or rect1.encloses(rect2) or rect2.encloses(rect1)
