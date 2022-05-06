extends Control

export(NodePath) var _camera_path := NodePath()
export(float) var camera_normal_speed_px := 200.0
export(float) var camera_fast_speed_px := 400.0
export(String) var up_action := 'ui_up'
export(String) var down_action := 'ui_down'
export(String) var left_action := 'ui_left'
export(String) var right_action := 'ui_right'

onready var _action_modes := $ActionModes

onready var camera := NodE.get_node_with_error(
	self, _camera_path, Camera2D
) as Camera2D

var _enable := false
var _previous_camera: Camera2D

func _ready() -> void:
	_enable = true
	disable()

func enable() -> void:
	if _enable:
		return
	
	_enable = true
	set_physics_process(true)
	visible = true
	grab_focus()
	_switch_to_free_camera()

func disable() -> void:
	if not _enable:
		return
	
	set_physics_process(false)
	visible = false
	_revert_to_game_camera()
	_enable = false

func _switch_to_free_camera() -> void:
	_previous_camera = _current_set_camera(get_tree().root)
	if not _previous_camera:
		return
	
	camera.current = true
	camera.global_position = _previous_camera.global_position

func _revert_to_game_camera() -> void:
	if not _previous_camera:
		return
	
	_previous_camera.current = true

func _current_set_camera(viewport: Viewport) -> Camera2D:
	var cameras := _camera_group(viewport)
	
	for c in cameras:
		if not c.current:
			continue
		
		return c
	
	return null

func _camera_group(viewport: Viewport) -> Array:
	var group_name := '__cameras_%s' % [viewport.get_viewport_rid().get_id()]
	return get_tree().get_nodes_in_group(group_name)

func _gui_input(event: InputEvent) -> void:
	if event.is_echo():
		return
	
	if event is InputEventKey and event.scancode == KEY_SHIFT:
		_camera_fast = event.is_pressed()
	elif event.is_action(up_action) or event.is_action(down_action) or event.is_action(left_action) or event.is_action(right_action):
		_camera_direction = Vector2(int(Input.is_action_pressed(right_action)) - int(Input.is_action_pressed(left_action)),
									int(Input.is_action_pressed(down_action)) - int(Input.is_action_pressed(up_action))).normalized()
	
	accept_event()

var _camera_fast := false
var _camera_direction := Vector2.ZERO
func _physics_process(delta: float) -> void:
	var speed := camera_normal_speed_px if not _camera_fast else camera_fast_speed_px
	camera.position += _camera_direction * speed * delta
