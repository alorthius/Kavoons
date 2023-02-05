extends Control

## Provide the tower managing interface
##
## A decorator of a melon instance. It wraps above every melon using the unique
## instances for each melon separately. Provides the interface to upgrade,
## delete and view the information about a particular melon.
class_name MelonManager

## Define the region for the UI buttons
onready var _hud: VBoxContainer = $UI/Pos/HUD
var _hud_box: Rect2

onready var _upgrade_butt := preload("res://src/scenes/UI/utility/butts/UpgradeButt.tscn")
onready var _upgrade_bar: HBoxContainer = $UI/Pos/HUD/UpgradeBar

onready var _sell_butt: TextureButton = $UI/Pos/HUD/BaseActions/SellBar/SellButt

#onready var _target_butt_bar: HBoxContainer = $UI/HUD/TargetingBar

onready var _target_label: Label = $UI/Pos/HUD/BaseActions/TargetingBar/Targeting/Label

var _focus_delta_size = Vector2(5, 5)

onready var _next_range: Sprite = $UI/Pos/NextRange
onready var _curr_range: Sprite = $UI/Pos/CurrRange

onready var _pos: Position2D = $UI/Pos

## The reference to the current melon this class is wrapped above
var _curr_melon: Melon

var _sell_cost: int

## Is the building mode currently active. If so, ignore the UI input
var _is_build_active: bool = false

## Send the new melon instance on upgrade and delete itself
signal upgrade_to(new_melon)


func _ready():
#	_hud.set_visible(false)
	_next_range.set_visible(false)	
	
#	var targ_butts := _target_butt_bar.get_children()
#
#	for butt in targ_butts:
#		assert(butt.connect("mouse_entered", self, "_focus_button", [butt]) == 0)
#		assert(butt.connect("mouse_exited", self, "_unfocus_button", [butt]) == 0)
#
#		if butt in targ_butts and butt.name != "Targeting":
#			assert(butt.connect("pressed", self, "_change_targeting", [butt.name]) == 0)


## Wrap this node above the given melon instance. The melon is added as a child
## as a sibling of UI (CanvasLayer) node.
func attach_melon(melon: Melon):	
	_curr_melon = melon
	self.add_child(_curr_melon)
	
	assert(_curr_melon.connect("mouse_entered", self, "_on_melon_mouse_entered") == 0)
	
	_pos.position = _curr_melon.position
	
#	_hud.rect_position = _curr_melon.position - Vector2(190, 180) # shift HUD to capture the melon
#	_next_range.position = _curr_melon.position
#	_curr_range.position = _curr_melon.position
	
	_curr_range.scale = 2 * _curr_melon._base_attack_radius * Vector2(1, 1) / _curr_range.texture.get_size()
	_curr_range.modulate = _curr_melon._color
	
	_set_targeting_label()

	var data: Dictionary = Towers.get_tower_dict(_curr_melon.tier, _curr_melon.base_tower, _curr_melon.branch)
	Events.emit_signal("update_money", - data["cost"])
	
	var idx := 0
	var next_num = len(data["next"])
	for next in data["next"]:
		idx += 1
		_add_upgrade_butt(str(idx), next)
	
	if next_num == 0:
		_upgrade_bar.set_visible(false)
		# there are no more upgrades, so trim the _hud size on upgrade bar's vertical size
		var y_delta := Vector2(0, _upgrade_bar.rect_size[1])
		_hud.rect_size -= y_delta
		_hud.rect_position += y_delta
		
	_add_sell_butt()

	_hud_box = _hud.get_rect()  # prevents recalculations in _on_HUD_mouse_exited signal


func a():
	print("base melon")
	if not _is_build_active:
		print("brrr")
		_curr_melon.get_node("UI").visible = true
#		_hud.set_visible(true)

func b():
	print("collision on")
	
	_hud.visible = true

func c():
	print("collision off")
	_hud.visible = false
	_curr_melon.get_node("UI").visible = false
	


func _add_upgrade_butt(name: String, dict: Dictionary):	
	var butt: Object = _upgrade_butt.instance()
	_upgrade_bar.add_child(butt)
#	butt.title(name).store(dict).color(_curr_melon._color.linear_interpolate(dict["color"], 0.7))
	butt.title(name).store(dict)
	
	assert(butt.connect("pressed", self, "_on_UpgradeButt_pressed", [butt]) == 0)
	assert(butt.connect("mouse_entered", self, "_on_UpgradeButt_mouse_entered", [butt]) == 0)
	assert(butt.connect("mouse_exited", self, "_on_UpgradeButt_mouse_exited") == 0)

func _add_sell_butt():
	_sell_cost = int(0.7 * _curr_melon.total_money)
	_sell_butt.label(str(_sell_cost))


func _on_UpgradeButt_mouse_entered(butt):
	_next_range.scale = 2 * butt.radius * Vector2(1, 1) / _next_range.texture.get_size()
	_next_range.modulate = butt.color
	_next_range.set_visible(true)

func _on_UpgradeButt_mouse_exited():
	_next_range.set_visible(false)

func _on_UpgradeButt_pressed(butt):
	var new_melon: Melon = load(butt.scene).instance()
	new_melon.position = _curr_melon.position
	new_melon._target_priority = _curr_melon._target_priority
	new_melon.total_money += _curr_melon.total_money
	
	emit_signal("upgrade_to", new_melon)
	queue_free()
	

func _on_SellButt_mouse_entered():
	modulate.a = 0.65

func _on_SellButt_mouse_exited():
	modulate.a = 1

func _on_SellButt_pressed():
	Events.emit_signal("update_money", _sell_cost)
	queue_free()


## Disable buttons if not enough money for purchase
func _validate_price(total: int):
	pass
#	for butt in _upgr_butts:
#		if not is_instance_valid(butt) or int(butt.name) > len(_next_costs):
#			continue
#
#		var icon: TextureRect = butt.get_node("Icon")
#		if _next_costs[int(butt.name) - 1] > total:
#			if not butt.disabled:
#				butt.disabled = true
#				icon.self_modulate = icon.modulate.darkened(0.5)
#		else:
#			butt.disabled = false
#			icon.self_modulate = Color(1, 1, 1, 1)

## Expand button on hover, show next melon range if button is upgrade
func _focus_button(butt: TextureButton):
	butt.rect_size += _focus_delta_size
	butt.rect_position += - _focus_delta_size / 2.0

	if butt.name == "Sell":
		modulate.a = 0.65
	
	if not butt.name in ["1", "2", "3"]:
		return
	
	var next_range = butt.radius
	var color = butt.color
	
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
		$UI.visible = true

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
#	if not _hud_box.has_point(get_local_mouse_position()):
#		_curr_range.set_visible(false)
#		_hud.set_visible(false)
	pass

## Listens to the signal from the builder to catch its status
func _toggle_build_status(status: bool):
	_is_build_active = status


func _on_Area2D_mouse_exited():
	$UI.visible = false
	print("exited")
