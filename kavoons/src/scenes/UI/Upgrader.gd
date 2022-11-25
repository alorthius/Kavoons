extends Control

## Provide the tower managing interface
##
## A decorator of a melon instance. It wrappes above every melon using the unique
## instances, for each melon separately. Provides the interface to upgrade,
## delete and view the information about a particular melon.
class_name Upgrader

## Define the region for the UI buttons
onready var _hud: Control = $UI/HUD
var _hud_box: Rect2
## The container of all the upgrade buttons
onready var _upgrade_butt_bar: HBoxContainer = $UI/HUD/UpgradeBar
onready var _sell_butt_bar: HBoxContainer = $UI/HUD/SellBar

## The shift of [member _hud] to be placed above the melon
var _hud_offset: Vector2 = Vector2(-85, -130)

## The size of [member _hud] if no upgrades available
onready var _final_hud_size: Vector2 = _sell_butt_bar.rect_min_size * Vector2(1, 2.5)
## The shift of [member _hud] above the melon if no upgrades available
var _final_hud_offset: Vector2 = Vector2(0, 80)


enum Buttons {UPGR, SELL, INFO}
## The textures of the buttons used to upgrade the melon
var _butt_textures = [ "res://assets/UI/upgr_left.png", "res://assets/UI/upgr_right.png" ]
## The names of the buttons used to upgrade the melon
var _butt_names    = [ "Left", "Right"]

var _focus_butt_scale_delta = Vector2(0.1, 0.1)
var _focus_butt_pos_delta = Vector2(0, -5)
var _focus_butt_rightmost_pos_delta = Vector2(-7, 0)


## True if there are no possible  updates, false otherwise
var _is_final: bool = false
## The reference to the current melon this class is wrapped above
var _curr_melon: Melon

var _is_build_active: bool = false

var _signal_err: int = 0

signal upgrade_to(new_melon)


func _ready():
	_hud.set_visible(false)
	_add_sell_button()  # the sell button should be added only once

func _toggle_build_status(status: bool):
	_is_build_active = status

## Wrap this node above the given melon instance. The melon is added as a child
## as a sibling of UI (CanvasLayer) node. Create the upgrade UI buttons for the melon.
## Shoukd be called each time the reattaching the melon instance (e.g. upgrade)
func attach_melon(melon: Melon):
	_curr_melon = melon
	self.add_child(_curr_melon)
	
	_signal_err = _curr_melon.connect("mouse_entered", self, "_on_melon_mouse_entered")
	if _signal_err != 0: print("Upgrader: attach_melon: connect: mouse_entered: ", _signal_err)
	
	_hud.rect_position = _curr_melon.position + _hud_offset

	var butt_icons = Towers.towers_data[melon.base_tower][melon.tier]["next"]
	if butt_icons.empty():  # There are no updates of the melon
		_is_final = true
		_upgrade_butt_bar.set_visible(false)
		_hud.rect_size = _final_hud_size
		_hud.rect_position += _final_hud_offset
	else:
		_add_upgrade_buttons(butt_icons)
	
	_hud_box = _hud.get_rect()  # prevents recalculations in _on_HUD_mouse_exited signal


## Create buttons for each possible melon update from the array of future melon sprites.
## Connect the press signal to every button as an upgrade action.
func _add_upgrade_buttons(icons: Array):	
	for idx in range(icons.size()):
		_add_generic_button(load(_butt_textures[idx]), _butt_names[idx], load(icons[idx]), Buttons.UPGR)

## Create the sell button. Should be called only once per instance
func _add_sell_button():
	_add_generic_button(load("res://assets/UI/upgr_left.png"), "Sell", null, Buttons.SELL)


## Creates any button of the type given from enum [member Buttons]
func _add_generic_button(butt_texture: Texture, butt_name: String, icon_texture: Texture, butt_type: int):
	var new_butt = _create_button(butt_texture, butt_name)
	if icon_texture != null:  # TODO: emove later as every button should have an icon
		var new_icon = _create_button_icon(icon_texture)
		new_butt.add_child(new_icon, true)
	
	var parent_container: HBoxContainer

	if butt_type == Buttons.UPGR:
		parent_container = _upgrade_butt_bar
		
		_signal_err = new_butt.connect("pressed", self, "_replace_melon", [butt_name])
		if _signal_err != 0: print("Upgrader: _add_upgrade_buttons: connect: pressed: ", _signal_err)
	
	elif butt_type == Buttons.SELL:
		parent_container = _sell_butt_bar
		
		_signal_err = new_butt.connect("pressed", self, "_sell_melon")
		if _signal_err != 0: print("Upgrader: _add_sell_button: connect: pressed: ", _signal_err)

	parent_container.add_child(new_butt, true)
		
	_signal_err = new_butt.connect("mouse_entered", self, "_focus_button", [new_butt])
	if _signal_err != 0: print("Upgrader: _add_upgrade_buttons: connect: mouse_entered: ", _signal_err)
	_signal_err = new_butt.connect("mouse_exited", self, "_unfocus_button", [new_butt])
	if _signal_err != 0: print("Upgrader: _add_upgrade_buttons: connect: mouse_exited: ", _signal_err)

## Create and return a TextureButton instance
func _create_button(normal_texture: Texture, butt_name: String) -> TextureButton:
	var new_butt = TextureButton.new()
	new_butt.mouse_filter = MOUSE_FILTER_PASS
	new_butt.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
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


## Expand button on hover
func _focus_button(butt: TextureButton):
	butt.rect_scale += _focus_butt_scale_delta
	butt.rect_position += _focus_butt_pos_delta
	if (butt.name in ["Right", "Sell"]):
		butt.rect_position += _focus_butt_rightmost_pos_delta

## Shrink button on hover
func _unfocus_button(butt: TextureButton):
	butt.rect_scale -= _focus_butt_scale_delta
	butt.rect_position -= _focus_butt_pos_delta
	if (butt.name in ["Right", "Sell"]):
		butt.rect_position -= _focus_butt_rightmost_pos_delta


## Upgrade teh current melon. Delete it from the tree and attaches the
## newly created melon to the field [member _curr_melon]
func _replace_melon(upgrade: String):
	var new_melon: Melon
	if upgrade == "Left":
		new_melon = _curr_melon.next_A.instance()
	elif upgrade == "Right":
		new_melon = _curr_melon.next_B.instance()

	new_melon.position = _curr_melon.position
	
	emit_signal("upgrade_to", new_melon)
	
	queue_free()
	
#	_curr_melon.queue_free()
#
#	attach_melon(new_melon)

## Sell the melon. Emit signal with the money earned with it
func _sell_melon():
	# TODO: emit signal
	queue_free()


### Display the UI
func _on_HUD_mouse_entered():
	_curr_melon.display_range(true)

## Hide the UI
func _on_HUD_mouse_exited():
	# The signal is wrongly triggered when mouse enters the child nodes of the
	# _hud node, even with pass mouse filter! The issue is also described here:
	# https://github.com/godotengine/godot/issues/16854

	# To ignore the false signal, we should manually check whether current
	# mouse position is in range of the Rect shape of _hud node.
	# This may cause the undesider behaviour if mouse exits the _hud shape via
	# another one overlapping it but ending outside the _hud boundaries, e.g.:
	
	#  .---.    In this case, if we escape the left figure with a signal like this
	#  |  .+-.  via the right figure, the signal will be discarded by the below
	#  |  |  |  if statement and it will never be caught unless hovering the mouse
	#  |  '+-'  again on the left shape. This will continue until the mouse exited
	#  '---'    the left shape via empty area outside the right figure.

	# Important!!! The code expects the overlying shapes to end in the _hud region,
	# so that the exit via top shapes instantly trigger the enter of the _hud shape.
	# The collision shape of a current melon should be fully inside the _hud shape!
	if not _hud_box.has_point(get_local_mouse_position()):
		_curr_melon.display_range(false)
		_hud.set_visible(false)


## Trigger the UI display on melon collision shape hover with making visible
## the larger area of mouse focus [member _hud]  with connected mouse signals.
## There is no signal _on_melon_mouse_exited as the UI hides on that signal
## connected to [member _hud] member.
## The signal [signal _on_HUD_mouse_entered] is instantly triggered after this one,
## hiding the UI only when receiving the [signal _on_HUD_mouse_exited]
func _on_melon_mouse_entered():
	if not _is_build_active:
		_hud.set_visible(true)
