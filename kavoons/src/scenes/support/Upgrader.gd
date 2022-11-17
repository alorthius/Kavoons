extends Node2D

class_name Upgrader

var _signal_err: int = 0

func _ready():
	for butt in get_tree().get_nodes_in_group("update_buttons"):
		_signal_err = butt.connect("pressed", self, "_on_pressed", [butt.name])
		if _signal_err != 0:
			print("Upgrader: _ready: connect(): pressed: ")


func _on_pressed(upgr: String):
	print("PRESSED")
