class_name Component_Extents
extends CollisionShape2D


onready var value := shape.extents as Vector2

func _ready() -> void:
	assert(shape is RectangleShape2D, 'only handles this type right now')

func get_as_global_rect() -> Rect2:
	return Rect2(global_position - value, value * 2.0)
