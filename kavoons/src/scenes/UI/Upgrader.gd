extends Control

class_name Upgrader

onready var _hud: Control = $UI/HUD
onready var _buttons_bar: HBoxContainer = $UI/HUD/UpgradeBar

var _upgr_bar_offset = Vector2(-85, -130)

var _button_textures = [ "res://assets/UI/upgr_left.png", "res://assets/UI/upgr_right.png" ]
var _button_names    = [ "Left", "Right"]

var _is_last_upgr: bool = false
var _curr_melon: Melon

var _signal_err: int = 0

signal set_range_visibility(to_show)


func _add_buttons(icons: Array):
	for idx in range(icons.size()):
		var new_butt = _create_button(load(_button_textures[idx]), _button_names[idx])
		var new_icon = _create_button_icon(load(icons[idx]))
		new_butt.add_child(new_icon, true)
		
		_buttons_bar.add_child(new_butt, true)
		
		_signal_err = new_butt.connect("pressed", self, "_replace_melon", [_button_names[idx]])
		if _signal_err != 0: print("Upgrader: add_buttons: connect: pressed: ")


func attach_melon(melon: Melon):
	_curr_melon = melon
	self.add_child(_curr_melon)

	var butt_icons = Towers.towers_data[melon.base_tower][melon.tier]["next"]
	if butt_icons.empty():
		_is_last_upgr = true
		_buttons_bar.set_visible(false)
		return

	_add_buttons(butt_icons)
	_hud.rect_position = _curr_melon.position + _upgr_bar_offset


func _create_button(normal_texture: Texture, butt_name: String) -> TextureButton:
	var new_butt = TextureButton.new()
	new_butt.mouse_filter = MOUSE_FILTER_PASS
	new_butt.expand = true
	new_butt.rect_min_size = Vector2(40, 40)
	new_butt.size_flags_horizontal = false
	new_butt.size_flags_vertical = false
	new_butt.texture_normal = normal_texture
	new_butt.name = butt_name
	return new_butt


func _create_button_icon(icon_texture: Texture) -> TextureRect:
	var tower_icon = TextureRect.new()
	tower_icon.expand = true
	tower_icon.margin_left = 5
	tower_icon.margin_top = 5
	tower_icon.margin_right = 35
	tower_icon.margin_bottom = 35
	tower_icon.rect_min_size = Vector2(30, 30)
	tower_icon.texture = icon_texture
	tower_icon.name = "Icon"
	return tower_icon


func _replace_melon(upgrade: String):
	var new_melon: Melon
	if upgrade == "Left":
		new_melon = _curr_melon.next_A.instance()
	elif upgrade == "Right":
		new_melon = _curr_melon.next_B.instance()

	new_melon.position = _curr_melon.position
	_curr_melon.queue_free()
	
	attach_melon(new_melon)


func _on_HUD_mouse_entered():
	if not _is_last_upgr:
		_buttons_bar.set_visible(true)
	_curr_melon.display_range(true)


func _on_HUD_mouse_exited():
	if not _is_last_upgr:
		_buttons_bar.set_visible(false)
	_curr_melon.display_range(false)
