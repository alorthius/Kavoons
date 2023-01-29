extends "res://src/scenes/UI/utility/butts/base/Butt.gd"

onready var _label: Label = $Label

func butt_label(new_label: String):
	_label.text = new_label
	return self

func _ready():
	print("Labeled Butt")
