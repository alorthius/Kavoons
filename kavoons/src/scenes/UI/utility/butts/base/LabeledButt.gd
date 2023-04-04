extends "res://src/scenes/UI/utility/butts/base/Butt.gd"

var _data
onready var _label: Label = $Label

func label(data):
	_data = data
	_label.text = str(_data)
	return self
