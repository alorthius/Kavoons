extends Control

class_name Upgrader

signal upgrade_to(next)

onready var upgrade_ui: Control = $UI/HUD/UpgradeBar
onready var tower_range: TextureRect = $UI/TowerRange

var _signal_err: int = 0

var curr_melon: Melon


func link_melon(melon: Melon):
	curr_melon = melon


func _ready():
	pass


func _on_HUD_mouse_entered():
	tower_range.set_visible(true)
	upgrade_ui.set_visible(true)


func _on_HUD_mouse_exited():
	tower_range.set_visible(false)
	upgrade_ui.set_visible(false)
