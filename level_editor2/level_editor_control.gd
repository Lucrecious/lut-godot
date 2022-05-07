extends Control

export(NodePath) var _camera_path := NodePath()
export(float) var camera_normal_speed_px := 200.0
export(float) var camera_fast_speed_px := 400.0
export(String) var up_action := 'ui_up'
export(String) var down_action := 'ui_down'
export(String) var left_action := 'ui_left'
export(String) var right_action := 'ui_right'

onready var _action_modes := $ActionModes

var _previous_camera: Camera2D = null
onready var camera := NodE.get_node_with_error(
	self, _camera_path, Camera2D
) as Camera2D

var _enable := false

func _ready() -> void:
	set_physics_process(false)
	visible = false
	_enable = false

func enable() -> void:
	if _enable:
		return
	
	_enable = true
	
	get_tree().connect('node_added', self, '_on_node_added')
	get_tree().connect('node_removed', self, '_on_node_removed')
	
	var current_camera := _current_set_camera(get_tree().root)
	if current_camera:
		_on_node_added(current_camera)
	
	set_physics_process(true)
	visible = true
	grab_focus()
	_switch_to_free_camera()

func disable() -> void:
	if not _enable:
		return
	
	get_tree().disconnect('node_added', self, '_on_node_added')
	get_tree().disconnect('node_removed', self, '_on_node_removed')
	set_physics_process(false)
	visible = false
	_revert_to_game_camera()
	_enable = false

func _on_node_added(node: Node) -> void:
	var camera := node as Camera2D
	if not camera:
		return
	
	if not camera.current:
		return
	
	_previous_camera = camera
	_switch_to_free_camera()

func _on_node_removed(node: Node) -> void:
	if node != _previous_camera:
		return
	
	_previous_camera = null

func _switch_to_free_camera() -> void:
	camera.current = true
	
	if not _previous_camera:
		return
	
	camera.global_position = _previous_camera.global_position

func _revert_to_game_camera() -> void:
	if not _previous_camera:
		return
	
	_previous_camera.current = true
	_previous_camera = null

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
