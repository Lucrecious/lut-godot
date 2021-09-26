class_name Controller_BindedActions
extends Resource

export(PoolStringArray) var single_actions := PoolStringArray([])
export(PoolStringArray) var vectors := PoolStringArray([])

var _vectors := {}
func get_leftrightupdown(index: int) -> PoolStringArray:
	var leftrightupdown := _vectors.get(index, PoolStringArray([])) as PoolStringArray
	if leftrightupdown.empty():
		_vectors[index] = vectors[index].split(',')
	return leftrightupdown
