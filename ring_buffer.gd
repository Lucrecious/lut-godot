class_name RingBuffer
extends Reference

var _maximum_capacity := 0
var _buffer := []
var _head := 0
var _tail := 0

func _init(maximum_capacity: int) -> void:
	assert(maximum_capacity > 0)
	_maximum_capacity = max(1, maximum_capacity)
	_buffer.resize(_maximum_capacity)

func size() -> int:
	return _tail - _head

func at(index: int):
	return _buffer[_transform_to_valid_index(index)]

func as_array() -> Array:
	var a := []
	for i in size():
		a.push_back(_buffer[_transform_to_valid_index(i)])
	
	return a

func _transform_to_valid_index(index: int) -> int:
	index = index % _maximum_capacity
	if index < 0:
		index = _maximum_capacity + index
	
	index = (_head + index) % _maximum_capacity
	return index

func clear() -> void:
	_head = 0
	_tail = 0

func pop_front(amount: int) -> void:
	_head = min(_tail, _head + amount)

func push_back_array(array: Array) -> void:
	var start_index := 0
	if array.size() > _maximum_capacity:
		start_index = array.size() - _maximum_capacity
	
	for i in min(array.size(), _maximum_capacity):
		push_back(array[i + start_index])

func push_back(item) -> void:
	_buffer[_tail % _maximum_capacity] = item
	if _tail - _head == _maximum_capacity:
		_head += 1
	_tail += 1

func _to_string() -> String:
	return '<ring-buffer: %s>' % size()
