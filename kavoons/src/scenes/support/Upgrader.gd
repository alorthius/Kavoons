extends Node2D

class_name Upgrader


func _ready():
#	$UI/HUD.set_visible(false)
	for butt in get_tree().get_nodes_in_group("update_buttons"):
		butt.connect("pressed", self, "_on_pressed", [butt.name])


func _on_pressed(upgr: String):
	print("PRESSED")
