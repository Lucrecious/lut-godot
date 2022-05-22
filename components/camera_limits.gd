class_name CameraLimits
extends Node2D

const WALL_FLOOR_THRESHOLD_RADIANS := PI / 4.0

export(int, LAYERS_2D_PHYSICS) var collision_layer := 0

onready var _camera := get_parent() as Camera2D
onready var _follow := NodE.get_sibling(self, CameraFollow) as CameraFollow

func _ready() -> void:
	assert(_camera, 'must be child of camera2d')

func update_limits() -> void:
	var space := get_world_2d().direct_space_state
	
	var viewport_size := get_viewport_rect().size
	
	# I'm doing a manual xray
	var ray_start := _follow.target.global_position
	_camera.limit_bottom = 1_000_000
	while true:
		var bottom := space.intersect_ray(
			ray_start,
			_follow.target.global_position + Vector2.DOWN * viewport_size.y, [],
			collision_layer, false, true)
		
		if bottom.empty():
			break
		
		if abs(bottom.normal.angle_to(Vector2.UP)) >= WALL_FLOOR_THRESHOLD_RADIANS:
			ray_start = bottom.position + Vector2.DOWN * .01
			continue
		
		_camera.limit_bottom = bottom.position.y
		break
	
	ray_start = _follow.target.global_position
	_camera.limit_top = -1_000_000
	while true:
		var top := space.intersect_ray(
			ray_start,
			_follow.target.global_position + Vector2.UP * viewport_size.y, [],
			collision_layer, false, true)
		
		if top.empty():
			break
	
		if abs(top.normal.angle_to(Vector2.DOWN)) >= WALL_FLOOR_THRESHOLD_RADIANS:
			ray_start = top.position + Vector2.UP * .01
			continue
		
		# this ensures the bottom camera line has priority over the top one
		_camera.limit_top = min(top.position.y, _camera.limit_bottom - viewport_size.y)
		break
	
	ray_start = _follow.target.global_position
	_camera.limit_left = -1_000_000
	while true:
		var left := space.intersect_ray(
			ray_start,
			_follow.target.global_position + Vector2.LEFT * viewport_size.x, [],
			collision_layer, false, true)
	
		if left.empty():
			break
		 
		if abs(left.normal.angle_to(Vector2.RIGHT)) >= WALL_FLOOR_THRESHOLD_RADIANS:
			ray_start = left.position + Vector2.LEFT * .01
			continue
		
		_camera.limit_left = left.position.x
		break
	
	ray_start = _follow.target.global_position
	_camera.limit_right = 1_000_000
	while true:
		var right := space.intersect_ray(
			ray_start,
			_follow.target.global_position + Vector2.RIGHT * viewport_size.x, [],
			collision_layer, false, true)
		
		if right.empty():
			break
		
		if abs(right.normal.angle_to(Vector2.LEFT)) >= WALL_FLOOR_THRESHOLD_RADIANS:
			ray_start = right.position + Vector2.RIGHT * .01
			continue
		
		_camera.limit_right = right.position.x
		break

func _physics_process(delta: float) -> void:
	if not _follow.target:
		return
	
	update_limits()
