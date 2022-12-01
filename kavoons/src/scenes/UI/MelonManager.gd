extends Control

## Provide the tower managing interface
##
## A decorator of a melon instance. It wraps above every melon using the unique
## instances for each melon separately. Provides the interface to upgrade,
## delete and view the information about a particular melon.
class_name MelonManager

## Define the region for the UI buttons
onready var _hud: VBoxContainer = $UI/HUD
var _hud_box: Rect2

onready var _melon_box: HBoxContainer = $UI/HUD/MelonBox
onready var _upgrade_butt_bar: HBoxContainer = $UI/HUD/UpgradeBar
onready var _sell_butt_bar: HBoxContainer = $UI/HUD/SellBar
onready var _target_butt_bar: HBoxContainer = $UI/HUD/TargetingBar

enum Buttons {UPGR, SELL, SWITCH}

var _upgr_butt_textures = [ "res://assets/UI/upgr_left.png", "res://assets/UI/upgr_right.png" ]
var _upgr_butt_names    = [ "Left", "Right"]

var _sell_butt_texture: Texture = preload("res://assets/UI/upgr_left.png") # TODO
var _sell_butt_icon = null  # TODO
var _sell_butt_name = "Sell"

var _switch_butt_texture: Texture = preload("res://assets/UI/upgr_right.png") # TODO
var _left_switch_icon = null # TODO
var _right_switch_icon = null # TODO

var _target_label: Label
var _target_butt_texture: Texture = preload("res://assets/UI/tower_build_button.png") # TODO

## Delta of button scale on hovering
var _focus_butt_scale_delta = Vector2(0.1, 0.1)
## Delta of button position on hovering
var _focus_butt_pos_delta = Vector2(0, -5)
## Delta of the rightmost button position on hovering
var _focus_butt_rightmost_pos_delta = Vector2(-7, 0)

onready var _range_texture: Sprite = $UI/NextRange
var _next_ranges: Array
var _next_ranges_colors: Array = [Color(1, 0.9, 0, 0.5), Color(1, 0.4, 0.5, 0.5)]  # TODO: refactor

## The reference to the current melon this class is wrapped above
var _curr_melon: Melon
## Is the building mode currently active. If so, ignore the UI input
var _is_build_active: bool = false

var _signal_err: int = 0

## Send the new melon instance on upgrade and delete itself
signal upgrade_to(new_melon)


func _ready():
	_hud.set_visible(false)
	_range_texture.set_visible(false)

## Listens to the signal from the builder to catch its status
func _toggle_build_status(status: bool):
	_is_build_active = status

## Wrap this node above the given melon instance. The melon is added as a child
## as a sibling of UI (CanvasLayer) node. Create the upgrade and sell buttons for the melon.
func attach_melon(melon: Melon):
	_curr_melon = melon
	self.add_child(_curr_melon)
	
	_signal_err = _curr_melon.connect("mouse_entered", self, "_on_melon_mouse_entered")
	if _signal_err != 0: print("Upgrader: attach_melon: connect: mouse_entered: ", _signal_err)
	
	_hud.rect_position = _curr_melon.position - _melon_box.rect_size / 2.0 - _melon_box.rect_position
	_range_texture.position = _curr_melon.position
	
	_add_sell_button()
	_add_targeting_buttons()
	_set_targeting_label()

	var butt_icons = Towers.towers_data[melon.base_tower][melon.tier]["next"]
	if butt_icons.empty():  # There are no updates of the melon
		_upgrade_butt_bar.set_visible(false)
		# there are no more upgrades, so trim the _hud size on upgrade bar's vertical size
		var y_delta := Vector2(0, _upgrade_butt_bar.rect_size[1] + _hud.get_constant("separation"))
		_hud.rect_size -= y_delta
		_hud.rect_position += y_delta
	else:
		_next_ranges = Towers.towers_data[melon.base_tower][melon.tier]["next_ranges"]
		_add_upgrade_buttons(butt_icons)
	
	_hud_box = _hud.get_rect()  # prevents recalculations in _on_HUD_mouse_exited signal


## Create buttons for each possible melon update from the array of future melon sprites.
func _add_upgrade_buttons(icons: Array):	
	for idx in range(icons.size()):
		_add_generic_button(load(_upgr_butt_textures[idx]), _upgr_butt_names[idx], load(icons[idx]), Buttons.UPGR)

## Create the sell button.
func _add_sell_button():
	_add_generic_button(_sell_butt_texture, _sell_butt_name, _sell_butt_icon, Buttons.SELL)

## Create the targeting buttons and label between them.
func _add_targeting_buttons():
	_add_generic_button(_switch_butt_texture, "ToLeft", _left_switch_icon, Buttons.SWITCH)
	_add_targeting_label()
	_add_generic_button(_switch_butt_texture, "ToRight", _right_switch_icon, Buttons.SWITCH)

func _add_targeting_label():
	var label := Label.new()
	_target_butt_bar.add_child(label)
	_target_label = label

## Buttons static factory. The button type is given from enum [member Buttons]
func _add_generic_button(butt_texture: Texture, butt_name: String, icon_texture: Texture, butt_type: int):	
	var parent_container: HBoxContainer
	var butt_size: Vector2
	var icon_margin: int

	# define button and icon size
	if butt_type == Buttons.UPGR:
		butt_size = Vector2(80, 80)
		parent_container = _upgrade_butt_bar
		icon_margin = 10
	
	elif butt_type == Buttons.SELL:
		butt_size = Vector2(80, 80)
		parent_container = _sell_butt_bar
		icon_margin = 10
	
	elif butt_type == Buttons.SWITCH:
		parent_container = _target_butt_bar
		butt_size = Vector2(40, 40)
		icon_margin = 5
	
	var new_butt: TextureButton = _create_button(butt_texture, butt_name, butt_size)
	
	if icon_texture != null:  # TODO: emove later as every button should have an icon
		var new_icon = _create_button_icon(icon_texture, butt_size, icon_margin)
		new_butt.add_child(new_icon, true)
	
	parent_container.add_child(new_butt, true)

	# connect signals
	if butt_type == Buttons.UPGR:	
		_signal_err = new_butt.connect("pressed", self, "_upgrade_melon", [butt_name])
		if _signal_err != 0: print("Upgrader: _add_upgrade_button: connect: pressed: ", _signal_err)
	
	elif butt_type == Buttons.SELL:
		_signal_err = new_butt.connect("pressed", self, "_sell_melon")
		if _signal_err != 0: print("Upgrader: _add_sell_button: connect: pressed: ", _signal_err)
	
	elif butt_type == Buttons.SWITCH:
		_signal_err = new_butt.connect("pressed", self, "_change_targeting", [butt_name])
		if _signal_err != 0: print("Upgrader: _add_switch_button: connect: pressed: ", butt_name, ": ", _signal_err)
		
	_signal_err = new_butt.connect("mouse_entered", self, "_focus_button", [new_butt])
	if _signal_err != 0: print("Upgrader: _add_generic_button: connect: mouse_entered: ", _signal_err)
	_signal_err = new_butt.connect("mouse_exited", self, "_unfocus_button", [new_butt])
	if _signal_err != 0: print("Upgrader: _add_generic_button: connect: mouse_exited: ", _signal_err)

## Create and return a TextureButton instance
func _create_button(normal_texture: Texture, butt_name: String, butt_size: Vector2) -> TextureButton:
	var new_butt = TextureButton.new()
	new_butt.mouse_filter = MOUSE_FILTER_PASS
	new_butt.stretch_mode = TextureButton.STRETCH_KEEP_ASPECT_CENTERED
	new_butt.expand = true
	new_butt.rect_min_size = butt_size
	new_butt.size_flags_horizontal = SIZE_SHRINK_CENTER
	new_butt.size_flags_vertical = SIZE_SHRINK_CENTER
	new_butt.texture_normal = normal_texture
	new_butt.name = butt_name
	return new_butt

## Create and return a TextureRect icon instance made for a button
func _create_button_icon(icon_texture: Texture, butt_size: Vector2, icon_margin: int) -> TextureRect:
	var tower_icon = TextureRect.new()
	tower_icon.mouse_filter = MOUSE_FILTER_IGNORE
	tower_icon.expand = true
	tower_icon.margin_left = icon_margin
	tower_icon.margin_top = icon_margin
	tower_icon.margin_right = butt_size[0] - icon_margin
	tower_icon.margin_bottom = butt_size[0] - icon_margin
	tower_icon.rect_min_size = Vector2(butt_size[0] - 2 * icon_margin, butt_size[0] - 2 * icon_margin)
	tower_icon.texture = icon_texture
	tower_icon.name = "Icon"
	return tower_icon


## Expand button on hover
func _focus_button(butt: TextureButton):
	butt.rect_scale += _focus_butt_scale_delta
	butt.rect_position += _focus_butt_pos_delta
	if (butt.name in ["Right", "Sell"]):
		butt.rect_position += _focus_butt_rightmost_pos_delta
	
	var next_range: int
	var color: Color
	if butt.name == "Left":
		next_range = _next_ranges[0]
		color = _next_ranges_colors[0]
	elif butt.name == "Right":
		next_range = _next_ranges[1]
		color = _next_ranges_colors[1]
	
	_range_texture.scale = Vector2(next_range * 0.55, next_range * 0.55)
	_range_texture.modulate = color
	_range_texture.set_visible(true)
	

## Shrink button on hover
func _unfocus_button(butt: TextureButton):
	_range_texture.set_visible(false)
	butt.rect_scale -= _focus_butt_scale_delta
	butt.rect_position -= _focus_butt_pos_delta
	if (butt.name in ["Right", "Sell"]):
		butt.rect_position -= _focus_butt_rightmost_pos_delta


## Upgrade the current melon. Pass the new melon instance via signal and delete current node
func _upgrade_melon(upgrade: String):
	var new_melon: Melon
	if upgrade == "Left":
		new_melon = _curr_melon.next_A.instance()
	elif upgrade == "Right":
		new_melon = _curr_melon.next_B.instance()

	new_melon.position = _curr_melon.position
	new_melon._target_priority = _curr_melon._target_priority
	
	emit_signal("upgrade_to", new_melon)
	
	queue_free()

## Sell the melon. Emit signal with the money earned with it
func _sell_melon():
	# TODO: emit signal
	queue_free()

func _change_targeting(action: String):
	var new_targeting: int
	if action == "ToLeft":
		new_targeting = (_curr_melon._target_priority - 1) % Constants.TARGET_PRIORITY.size()
	elif action == "ToRight":
		new_targeting = (_curr_melon._target_priority + 1) % Constants.TARGET_PRIORITY.size()
	if new_targeting == -1:  # -1 % 7 = -1
		new_targeting = Constants.TARGET_PRIORITY.size() - 1
	
	_curr_melon._target_priority = new_targeting
	_set_targeting_label()

func _set_targeting_label():
	_target_label.text = Constants.TARGET_PRIORITY.keys()[_curr_melon._target_priority]

## Trigger the UI display on melon collision shape hover with making visible
## the larger area of mouse focus [member _hud]  with connected mouse signals.
## There is no signal _on_melon_mouse_exited as the UI hides on that signal
## connected to [member _hud] member.
## The signal [signal _on_HUD_mouse_entered] is instantly triggered after this one,
## hiding the UI only when receiving the [signal _on_HUD_mouse_exited]
func _on_melon_mouse_entered():
	if not _is_build_active:
		_curr_melon.display_range(true)
		_hud.set_visible(true)

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

	#  .-----.    In this case, if we escape the left figure with a signal like this
	#  |   .-+-.  via the right figure, the signal will be discarded by the below
	#  |   |   |  if statement and it will never be caught unless hovering the mouse
	#  |   '-+-'  again on the left shape. This will continue until the mouse exited
	#  '-----'    the left shape via empty area outside the right figure.

	# Important!!! The code expects the overlying shapes to end in the _hud region,
	# so that the exit via top shapes instantly trigger the enter of the _hud shape.
	# The collision shape of a current melon should be fully inside the _hud shape!
	if not _hud_box.has_point(get_local_mouse_position()):
		_curr_melon.display_range(false)
		_hud.set_visible(false)
