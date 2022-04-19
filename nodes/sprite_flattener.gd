class_name SpriteFlattener
extends Node2D

export(bool) var update_on_process := false setget _update_on_process_set
func _update_on_process_set(value: bool) -> void:
	if update_on_process == value:
		return
	
	update_on_process = value
	set_process(update_on_process)

var _sprites_to_flatten := []

func _ready() -> void:
	_sprites_to_flatten = _get_all_sprites_recursive(self)
	set_process(update_on_process)

func _draw() -> void:
	for s in _sprites_to_flatten:
		var sprite := s as Sprite
		var transform := global_transform.inverse() * sprite.global_transform
		transform = transform.translated(-sprite.texture.get_size() / 2.0 + sprite.offset)
		draw_set_transform_matrix(transform)
		draw_texture_rect_region(sprite.texture, Rect2(Vector2.ZERO, sprite.texture.get_size()), Rect2(Vector2.ZERO, sprite.texture.get_size()))

func _get_all_sprites_recursive(node: Node) -> Array:
	var sprites := []
	
	for child in node.get_children():
		if child is Sprite:
			sprites.push_back(child)
		
		for s in _get_all_sprites_recursive(child):
			sprites.push_back(s)
	
	return sprites

func _process(delta):
	update()
