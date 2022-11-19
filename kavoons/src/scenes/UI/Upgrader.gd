extends Control

class_name Upgrader

signal upgrade_to(next)

onready var upgrade_ui: Control = $UI/HUD/UpgradeBar
var _signal_err: int = 0

func _ready():
	pass


func _on_HUD_mouse_entered():
	upgrade_ui.set_visible(true)


func _on_HUD_mouse_exited():
	upgrade_ui.set_visible(false)
