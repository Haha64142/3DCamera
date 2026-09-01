class_name MouseButtonHandler

var _button_array: Array[int]
var _active_button: MouseButton = MOUSE_BUTTON_NONE
var _button_count: int = 0
var _max_priority: int = 0

func _init():
	_button_array.resize(9)
	# Number of items in MouseButton excluding MOUSE_BUTTON_NONE
	_button_array.fill(0)

func press(button: MouseButton) -> void:
	var button_index: int = button - 1
	if _button_array[button_index] == 0:
		_button_count += 1
	_max_priority += 1
	_button_array[button_index] = _max_priority
	_active_button = button

func release(button: MouseButton) -> void:
	var button_index: int = button - 1
	_button_count -= 1
	var button_priority = _button_array[button_index]
	_button_array[button_index] = 0
	if button_priority < _max_priority:
		return
	
	if _button_count == 0:
		_max_priority = 0
		_active_button = MOUSE_BUTTON_NONE
		return
	
	var max_priority_index = 0
	_max_priority = 0
	for i in range(_button_array.size()):
		if _button_array[i] > _max_priority:
			max_priority_index = i
			_max_priority = _button_array[i]
	
	_active_button = max_priority_index + 1 as MouseButton

func is_pressed(button: MouseButton) -> bool:
	return _button_array[button - 1] > 0

func get_button_count() -> int:
	return _button_count

func get_active_button() -> MouseButton:
	return _active_button
