tool
class_name REferenceRect
extends Node2D

export (Color) var _color := Color.black setget _color_set
export (Vector2) var _extents := Vector2(50, 50) setget _extents_set
export(float) var _thickness := 1.0 setget _thickness_set

func extents() -> Vector2:
	return _extents

func rect() -> Rect2:
	return Rect2(position - _extents, _extents * 2)

func global_rect() -> Rect2:
	return Rect2(global_position - _extents, _extents * 2)

func random_global_point_inside() -> Vector2:
	var rect := global_rect()
	return rect.position + Vector2(randf(), randf()) * rect.size

func _extents_set(extents: Vector2) -> void:
	_extents = extents
	update()

func _color_set(color: Color) -> void:
	_color = color
	update()

func _thickness_set(width: float) -> void:
	_thickness = width
	update()

func _draw() -> void:
	var rect := Rect2(Vector2.ZERO - _extents, _extents * 2.0)
	draw_rect(rect, _color, false, _thickness)
