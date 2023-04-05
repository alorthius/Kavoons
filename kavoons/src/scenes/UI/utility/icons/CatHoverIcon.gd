extends "res://src/scenes/UI/utility/icons/HoverIcon.gd"

var _icons_path = "res://assets/icons/cats/"

var _cat_name: String

func set_name(cat: String):
	_cat_name = cat
	return set_icon(_icons_path + _cat_name + ".png")

func set_num(i: int):
	return set_label(str(i) + " x " + _cat_name)
