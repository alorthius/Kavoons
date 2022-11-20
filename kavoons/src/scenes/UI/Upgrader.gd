extends Control

class_name Upgrader

onready var upgrade_ui: Control = $UI/HUD/UpgradeBar

var base_button_textures = [ "res://assets/UI/upgr_left.png", "res://assets/UI/upgr_right.png" ]
var base_button_names    = [ "Left", "Right"]

var is_last_upgr: bool = false

signal set_range_visibility(to_show)


func fill_icons(icons: Array):
	if icons.empty():
		is_last_upgr = true
		return
	
	for idx in range(icons.size()):
		var new_butt = TextureButton.new()
		new_butt.mouse_filter = MOUSE_FILTER_PASS
		new_butt.expand = true
		new_butt.rect_min_size = Vector2(40, 40)
		new_butt.size_flags_horizontal = false
		new_butt.size_flags_vertical = false
		new_butt.texture_normal = load(base_button_textures[idx])
		new_butt.name = base_button_names[idx]
		
		var tower_icon = TextureRect.new()
		tower_icon.expand = true
		tower_icon.margin_left = 5
		tower_icon.margin_top = 5
		tower_icon.margin_right = 35
		tower_icon.margin_bottom = 35
		tower_icon.rect_min_size = Vector2(30, 30)
		tower_icon.texture = load(icons[idx])
		
		new_butt.add_child(tower_icon, true)
		upgrade_ui.add_child(new_butt, true)


func _ready():
	pass


func _on_HUD_mouse_entered():
	if not is_last_upgr: upgrade_ui.set_visible(true)
	emit_signal("set_range_visibility", true)


func _on_HUD_mouse_exited():
	if not is_last_upgr: upgrade_ui.set_visible(false)
	emit_signal("set_range_visibility", false)
