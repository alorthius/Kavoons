extends Control

class_name Upgrader

onready var upgrade_ui: Control = $UI/HUD/UpgradeBar

var is_last_upgr: bool = false

signal set_range_visibility(to_show)


func fill_icons(icons: Array):
	if icons.empty():
		is_last_upgr = true
		return

	var idx: int = 0
	for butt in upgrade_ui.get_children():
		butt.get_node("Icon").texture = load(icons[idx])
		idx += 1


func _ready():
	pass


func _on_HUD_mouse_entered():
	if not is_last_upgr: upgrade_ui.set_visible(true)
	emit_signal("set_range_visibility", true)


func _on_HUD_mouse_exited():
	if not is_last_upgr: upgrade_ui.set_visible(false)
	emit_signal("set_range_visibility", false)
