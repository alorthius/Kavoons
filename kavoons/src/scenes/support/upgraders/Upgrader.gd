extends Node2D

class_name Upgrader

func _ready():
	$UI/HUD.set_visible(false)
	for butt in get_tree().get_nodes_in_group("update_buttons"):
		butt.connect("mouse_entered", self, "_button_hovered")
		butt.connect("mouse_exited", self, "_button_released")

func _on_Melon_mouse_entered():
	$UI/HUD.set_visible(true)

func _on_Melon_mouse_exited():
	$UI/HUD.set_visible(false)

func _button_hovered():
	pass

func _button_released():
	pass
