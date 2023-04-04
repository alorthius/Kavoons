extends Node2D

class_name CircularEnum

var _enum
var _curr_i

func set_enum(e):
	_enum = e
	return self

func set_init(i):
	_curr_i = i
	return self

func next():
	_curr_i = (_curr_i + 1) % _enum.size()
	return _curr_i

func prev():
	_curr_i = (_curr_i - 1) % _enum.size()
	if _curr_i == -1:  # -1 % n = -1
		_curr_i = _enum.size() - 1
	return _curr_i

func get_value():
	return _enum.keys()[_curr_i]
