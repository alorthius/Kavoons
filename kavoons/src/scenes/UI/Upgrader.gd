extends Control

## Provide the tower managing interface
##
## A decorator of a melon instance. It wrappes above every melon using the unique
## instances, for each melon separately. Provides the interface to upgrade,
## delete and view the information about a particular melon.
class_name Upgrader

## Define the region for the UI buttons
onready var _hud: Control = $UI/HUD
## The container of all the upgrade buttons
onready var _upgrade_butt_bar: HBoxContainer = $UI/HUD/UpgradeBar
onready var _sell_butt_bar: HBoxContainer = $UI/HUD/SellBar

## The upgrade bar should be placed above the melon. This vector defines the shift
var _upgr_bar_offset = Vector2(-85, -130)

## The textures of the buttons used to upgrade the melon
var _button_textures = [ "res://assets/UI/upgr_left.png", "res://assets/UI/upgr_right.png" ]
## The names of the buttons used to upgrade the melon
var _button_names    = [ "Left", "Right"]

## True if there are future updates, false if the final Tier is reached
var _is_last_upgr: bool = false
## The reference to the current melon this class is wrapped above
var _curr_melon: Melon

var _signal_err: int = 0


func _ready():
	_hud.set_visible(false)
	_add_sell_button()  # the sell button should be added only once

## Wrap this node above the given melon instance. The melon is added as a child.
## Create all the UI buttons for this current melon
func attach_melon(melon: Melon):
	_curr_melon = melon
	self.add_child(_curr_melon)
	
	_signal_err = _curr_melon.connect("mouse_entered", self, "_on_melon_mouse_entered")
	if _signal_err != 0: print("Upgrader: attach_melon: connect: mouse_entered: ", _signal_err)
	
	_hud.rect_position = _curr_melon.position + _upgr_bar_offset

	var butt_icons = Towers.towers_data[melon.base_tower][melon.tier]["next"]
	if butt_icons.empty():
		_is_last_upgr = true
		_upgrade_butt_bar.set_visible(false)
		return

	_add_upgrade_buttons(butt_icons)

## Create buttons for each possible melon update from the array of future melon sprites.
## Connect the press signal to every button as an upgrade action.
func _add_upgrade_buttons(icons: Array):	
	for idx in range(icons.size()):
		var new_butt = _create_button(load(_button_textures[idx]), _button_names[idx])
		var new_icon = _create_button_icon(load(icons[idx]))
		new_butt.add_child(new_icon, true)
		
		_upgrade_butt_bar.add_child(new_butt, true)
		
		_signal_err = new_butt.connect("pressed", self, "_replace_melon", [_button_names[idx]])
		if _signal_err != 0: print("Upgrader: _add_upgrade_buttons: connect: pressed: ", _signal_err)

func _add_sell_button():
	var sell_butt = _create_button(load("res://assets/UI/upgr_left.png"), "sell")
	_sell_butt_bar.add_child(sell_butt, true)
	
	_signal_err = sell_butt.connect("pressed", self, "_sell_melon")
	if _signal_err != 0: print("Upgrader: _add_sell_button: connect: pressed: ", _signal_err)

## Create and return a TextureButton instance
func _create_button(normal_texture: Texture, butt_name: String) -> TextureButton:
	var new_butt = TextureButton.new()
	new_butt.mouse_filter = MOUSE_FILTER_PASS
	new_butt.expand = true
	new_butt.rect_min_size = Vector2(80, 80)
	new_butt.size_flags_horizontal = SIZE_SHRINK_CENTER
	new_butt.size_flags_vertical = SIZE_SHRINK_CENTER
	new_butt.texture_normal = normal_texture
	new_butt.name = butt_name
	return new_butt

## Create and return a TextureRect icon instance made for a button
func _create_button_icon(icon_texture: Texture) -> TextureRect:
	var tower_icon = TextureRect.new()
	tower_icon.mouse_filter = MOUSE_FILTER_IGNORE
	tower_icon.expand = true
	tower_icon.margin_left = 10
	tower_icon.margin_top = 10
	tower_icon.margin_right = 70
	tower_icon.margin_bottom = 70
	tower_icon.rect_min_size = Vector2(60, 60)
	tower_icon.texture = icon_texture
	tower_icon.name = "Icon"
	return tower_icon

## Upgrade teh current melon. Delete it from the tree and attaches the
## newly created melon to the field [member _curr_melon]
func _replace_melon(upgrade: String):
	var new_melon: Melon
	if upgrade == "Left":
		new_melon = _curr_melon.next_A.instance()
	elif upgrade == "Right":
		new_melon = _curr_melon.next_B.instance()

	new_melon.position = _curr_melon.position
	_curr_melon.queue_free()
	
	attach_melon(new_melon)

func _sell_melon():
	queue_free()

### Display the UI
func _on_HUD_mouse_entered():
	_curr_melon.display_range(true)

## Hide the UI
func _on_HUD_mouse_exited():
	if not _hud.get_rect().has_point(get_local_mouse_position()):
		_curr_melon.display_range(false)
		_hud.set_visible(false)

## Display the UI
func _on_melon_mouse_entered():
	print("a")
	_hud.set_visible(true)
