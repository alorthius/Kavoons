extends Control

class_name Upgrader

signal upgrade_to(next)

onready var upgrade_ui: Control = $UI/HUD/UpgradeBar
onready var tower_range: TextureRect = $UI/TowerRange


func _ready():
	pass


func _on_HUD_mouse_entered():
	tower_range.set_visible(true)
	upgrade_ui.set_visible(true)


func _on_HUD_mouse_exited():
	tower_range.set_visible(false)
	upgrade_ui.set_visible(false)
