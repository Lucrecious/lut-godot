class_name Component_Extents
extends CollisionShape2D


onready var value := Vector2.ZERO setget __null_set

func _ready() -> void:
	assert(shape is RectangleShape2D\
		or shape is CapsuleShape2D\
		or shape is CircleShape2D, 'only handles these types right now')
	if shape is RectangleShape2D:
		value = shape.extents
		return
	
	if shape is CapsuleShape2D:
		value = Vector2(shape.radius, (shape.radius * 2.0 + shape.height) / 2.0)
	
	if shape is CircleShape2D:
		value = Vector2(shape.radius, shape.radius)


func get_as_global_rect() -> Rect2:
	return Rect2(global_position - value, value * 2.0)

func __null_set(__): return
