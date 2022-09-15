class_name CameraShake
extends Node

export(float) var trauma_loss_per_second := 10.0
export(float) var translation_max := 50
export(float) var rotation_max_degrees := 45.0
export(NoiseTexture) var noise_template: NoiseTexture

onready var _camera := get_parent() as Camera2D

var trauma := 0.0

var _x_noise: OpenSimplexNoise = null
var _y_noise: OpenSimplexNoise = null
var _rotation_noise: OpenSimplexNoise = null

func add_trauma(amount: float, limit: float) -> void:
	trauma = min(trauma + amount, limit)

func _ready() -> void:
	assert(_camera)
	
	_x_noise = _create_noise()
	_y_noise = _create_noise()
	_rotation_noise = _create_noise()

func _create_noise() -> OpenSimplexNoise:
	if noise_template and noise_template.noise:
		var noise := noise_template.noise.duplicate() as OpenSimplexNoise
		noise.seed = randi()
		
		return noise
	else:
		assert(false)
		return null

var msec_passed := 0.0
func _process(delta: float) -> void:
	trauma = max(trauma - trauma_loss_per_second * delta, 0.0)
	
	if is_equal_approx(trauma, 0.0):
		return
	
	var offset_x := _get_noise(_x_noise, msec_passed) * translation_max * trauma
	var offset_y := _get_noise(_y_noise, msec_passed) * translation_max * trauma
	var rotation := _get_noise(_rotation_noise, msec_passed) * rotation_max_degrees * trauma
	
	msec_passed += (delta * noise_template.width)
	
	
	_camera.offset.x  = offset_x
	_camera.offset.y = offset_y
	_camera.rotation_degrees = rotation

func _get_noise(noise: OpenSimplexNoise, input: float) -> float:
	return min(noise.get_noise_1d(input) / .5, 1.0)
