extends Tabs

onready var _master := $Margin/VBox/Master as UI_SliderProperty
onready var _music := $Margin/VBox/Music as UI_SliderProperty
onready var _sound := $Margin/VBox/Sound as UI_SliderProperty

export(String) var _master_bus_name := ''
export(String) var _music_bus_name := ''
export(String) var _sound_bus_name := ''

const top_volume := 20.0
const bottom_volume := -60.0

func _ready() -> void:
	if not _master_bus_name.empty():
		_master.connect('value_changed', self, '_on_master_volume_changed')
		_master.value = inverse_lerp(bottom_volume, top_volume, _get_bus_volume(_master_bus_name))
	else:
		_master.visible = false
	
	if not _music_bus_name.empty():
		_music.connect('value_changed', self, '_on_music_volume_changed')
		_music.value = inverse_lerp(bottom_volume, top_volume, _get_bus_volume(_music_bus_name))
	else:
		_music.visible = false
	
	if not _sound_bus_name.empty():
		_sound.connect('value_changed', self, '_on_sound_volume_changed')
		_sound.value = inverse_lerp(bottom_volume, top_volume, _get_bus_volume(_sound_bus_name))
	else:
		_sound.visible = false

func _on_master_volume_changed(value: float) -> void:
	_set_volume_to_bus(_master_bus_name, value)

func _on_music_volume_changed(value: float) -> void:
	_set_volume_to_bus(_music_bus_name, value)

func _on_sound_volume_changed(value: float) -> void:
	_set_volume_to_bus(_sound_bus_name, value)

func _get_bus_volume(bus_name: String) -> float:
	return AudioServer.get_bus_volume_db(AudioServer.get_bus_index(bus_name))

func _set_volume_to_bus(bus_name: String, percent: float) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	AudioServer.set_bus_volume_db(bus_index, lerp(bottom_volume, top_volume, percent))

