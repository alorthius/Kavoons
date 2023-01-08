extends Control

## Provide the tower managing interface
##
## A decorator of a melon instance. It wraps above every melon using the unique
## instances for each melon separately. Provides the interface to upgrade,
## delete and view the information about a particular melon.
class_name MelonManager

## Define the region for the UI buttons
onready var _hud: Control = $UI/HUD
var _hud_box: Rect2

onready var _upgrade_butt_bar: HBoxContainer = $UI/HUD/UpgradeBar
onready var _upgr_butts := _upgrade_butt_bar.get_children()

onready var _sell_butt_bar: HBoxContainer = $UI/HUD/SellBar
onready var _target_butt_bar: HBoxContainer = $UI/HUD/TargetingBar

onready var _target_label: Label = $UI/HUD/TargetingBar/Targeting/Label

var _focus_delta_size = Vector2(5, 5)

onready var _next_range: Sprite = $UI/NextRange
onready var _curr_range: Sprite = $UI/CurrRange


## The reference to the current melon this class is wrapped above
var _curr_melon: Melon

var _sell_cost: int
var _next_costs := []

var _next_num: int
var _next_icons := []
var _next_ranges := []
var _next_colors := []
var _next_scenes := []

## Is the building mode currently active. If so, ignore the UI input
var _is_build_active: bool = false

## Send the new melon instance on upgrade and delete itself
signal upgrade_to(new_melon)


func _ready():
	_hud.set_visible(false)
	_next_range.set_visible(false)
	_curr_range.set_visible(true)
	
	var sell_butts := _sell_butt_bar.get_children()
	var targ_butts := _target_butt_bar.get_children()
	
	for butt in _upgr_butts + sell_butts + targ_butts:
		assert(butt.connect("mouse_entered", self, "_focus_button", [butt]) == 0)
		assert(butt.connect("mouse_exited", self, "_unfocus_button", [butt]) == 0)
		
		if butt in _upgr_butts:
			assert(butt.connect("pressed", self, "_upgrade_melon", [butt.name]) == 0)

		if butt in sell_butts:
			assert(butt.connect("pressed", self, "_sell_melon") == 0)
		
		if butt in targ_butts and butt.name != "Targeting":
			assert(butt.connect("pressed", self, "_change_targeting", [butt.name]) == 0)

## Wrap this node above the given melon instance. The melon is added as a child
## as a sibling of UI (CanvasLayer) node.
func attach_melon(melon: Melon):	
	_curr_melon = melon
	self.add_child(_curr_melon)
	
	assert(_curr_melon.connect("mouse_entered", self, "_on_melon_mouse_entered") == 0)
	
	_hud.rect_position = _curr_melon.position - Vector2(60, 140)  # shift HUD to capture the melon
	_next_range.position = _curr_melon.position
	_curr_range.position = _curr_melon.position
	
	_curr_range.scale = 2 * _curr_melon._base_attack_radius * Vector2(1, 1) / _curr_range.texture.get_size()
	_curr_range.modulate = _curr_melon._color
	
	_set_targeting_label()

	var data: Dictionary = Towers.get_tower_dict(_curr_melon.tier, _curr_melon.base_tower, _curr_melon.branch)
	Events.emit_signal("update_money", - data["cost"])
	
	_next_num = len(data["next"])
	for next in data["next"]:
		_next_costs.append(next["cost"])

		_next_icons.append(next["sprite"])
		_next_ranges.append(next["base_attack_radius"])
		_next_colors.append(next["color"])
		_next_scenes.append(next["scene"])
	
	if _next_num == 0:
		_upgrade_butt_bar.set_visible(false)
		# there are no more upgrades, so trim the _hud size on upgrade bar's vertical size
		var y_delta := Vector2(0, _upgrade_butt_bar.rect_size[1])
		_hud.rect_size -= y_delta
		_hud.rect_position += y_delta

	_set_upgr_icons()

	_hud_box = _hud.get_rect()  # prevents recalculations in _on_HUD_mouse_exited signal
	
	_sell_cost = int(0.7 * _curr_melon.total_money)
	var sell_label: Label = _sell_butt_bar.get_node("Sell/Icon/Cost")
	sell_label.text = String(_sell_cost)


## Set icons of the future towers for the upgrade buttons
func _set_upgr_icons():
	for i in range(_upgrade_butt_bar.get_child_count()):
		var butt: TextureButton = _upgrade_butt_bar.get_child(i)
		if i >= _next_num:
			butt.queue_free()
		else:
			var icon: TextureRect = butt.get_node("Icon")
			icon.texture = load(_next_icons[i])
			
			var label: Label = icon.get_node("Cost")
			label.text = String(_next_costs[i])
			label.set("custom_colors/font_color", _next_colors[i])
			label.set("custom_colors/font_outline_modulate", _next_colors[i].darkened(0.65))

			butt.self_modulate = _next_colors[i]

## Disable buttons if not enough money for purchase
func _validate_price(total: int):
	for butt in _upgr_butts:
		if not is_instance_valid(butt) or int(butt.name) > len(_next_costs):
			continue
		
		var icon: TextureRect = butt.get_node("Icon")
		if _next_costs[int(butt.name) - 1] > total:
			if not butt.disabled:
				butt.disabled = true
				icon.self_modulate = icon.modulate.darkened(0.5)
		else:
			butt.disabled = false
			icon.self_modulate = Color(1, 1, 1, 1)

## Expand button on hover, show next melon range if button is upgrade
func _focus_button(butt: TextureButton):
	butt.rect_size += _focus_delta_size
	butt.rect_position += - _focus_delta_size / 2.0

	if butt.name == "Sell":
		modulate.a = 0.65
	
	if not butt.name in ["1", "2", "3"]:
		return
	
	var next_range = _next_ranges[int(butt.name) - 1]
	var color = _next_colors[int(butt.name) - 1]
	
	_next_range.scale = 2 * next_range * Vector2(1, 1) / _next_range.texture.get_size()
	_next_range.modulate = color
	_next_range.set_visible(true)

## Shrink button on hover
func _unfocus_button(butt: TextureButton):
	_curr_range.set_visible(false)
	_next_range.set_visible(false)
	butt.rect_size -= _focus_delta_size
	butt.rect_position -= - _focus_delta_size / 2.0

	if butt.name == "Sell":
		modulate.a = 1

## Upgrade the current melon. Pass the new melon instance via signal and delete current node
func _upgrade_melon(upgrade: String):
	var new_melon: Melon = load(_next_scenes[int(upgrade) - 1]).instance()
	new_melon.position = _curr_melon.position
	new_melon._target_priority = _curr_melon._target_priority
	new_melon.total_money += _curr_melon.total_money
	
	emit_signal("upgrade_to", new_melon)
	
	queue_free()

## Sell the melon. Emit signal with the money earned with it
func _sell_melon():
	Events.emit_signal("update_money", _sell_cost)
	queue_free()

func _change_targeting(action: String):
	var new_targeting: int
	if action == "ToLeft":
		new_targeting = (_curr_melon._target_priority - 1) % Constants.TargetPriority.size()
	elif action == "ToRight":
		new_targeting = (_curr_melon._target_priority + 1) % Constants.TargetPriority.size()
	if new_targeting == -1:  # -1 % 7 = -1
		new_targeting = Constants.TargetPriority.size() - 1
	
	_curr_melon._target_priority = new_targeting
	_set_targeting_label()

func _set_targeting_label():
	var text: String = Constants.TargetPriority.keys()[_curr_melon._target_priority].to_lower()
	_target_label.text = text.replace("_", "\n")

## Trigger the UI display on melon collision shape hover with making visible
## the larger area of mouse focus [member _hud]  with connected mouse signals.
## There is no signal _on_melon_mouse_exited as the UI hides on that signal
## connected to [member _hud] member.
## The signal [signal _on_HUD_mouse_entered] is instantly triggered after this one,
## hiding the UI only when receiving the [signal _on_HUD_mouse_exited]
func _on_melon_mouse_entered():
	if not _is_build_active:
		_hud.set_visible(true)

### Display the UI
func _on_HUD_mouse_entered():
	_curr_range.set_visible(true)

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
		_curr_range.set_visible(false)
		_hud.set_visible(false)

## Listens to the signal from the builder to catch its status
func _toggle_build_status(status: bool):
	_is_build_active = status
