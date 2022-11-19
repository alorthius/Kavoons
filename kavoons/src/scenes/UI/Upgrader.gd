extends Control

class_name Upgrader

signal upgrade_to(next)

onready var upgrade_ui: Control = $UI/HUD/UpgradeBar
var _signal_err: int = 0

func _ready():
	pass
#	for butt in get_tree().get_nodes_in_group("update_buttons"):
#		_signal_err = butt.connect("pressed", self, "_on_pressed", [butt.name])
#		if _signal_err != 0:
#			print("Upgrader: _ready: connect(): pressed: ")		


func _on_HUD_mouse_entered():
	upgrade_ui.set_visible(true)


func _on_HUD_mouse_exited():
	upgrade_ui.set_visible(false)