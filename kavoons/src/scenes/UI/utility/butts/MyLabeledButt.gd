extends "res://src/scenes/UI/utility/butts/MyButt.gd"

onready var _label: Label = $Label

func butt_label(new_label: String):
	_label.text = new_label
	return self
