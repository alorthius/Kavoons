extends Control

class_name Upgrader

onready var upgrade_ui: Control = $UI/HUD/UpgradeBar

signal set_range_visibility(to_show)


func fill_icons():
	pass


func _ready():
	pass


func _on_HUD_mouse_entered():
	upgrade_ui.set_visible(true)
	emit_signal("set_range_visibility", true)


func _on_HUD_mouse_exited():
	upgrade_ui.set_visible(false)
	emit_signal("set_range_visibility", false)
