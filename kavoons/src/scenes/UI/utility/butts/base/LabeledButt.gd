extends "res://src/scenes/UI/utility/butts/base/Butt.gd"

onready var _label: Label = $Label

func label(new_label: String):
	_label.text = new_label
	return self
