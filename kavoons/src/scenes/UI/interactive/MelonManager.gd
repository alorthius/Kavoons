extends Control

## Provide the tower managing interface
##
## A decorator of a melon instance. It wraps above every melon using the unique
## instances for each melon separately. Provides the interface to upgrade,
## delete and view the information about a particular melon.
class_name MelonManager

onready var _ui: CanvasLayer = $UI
onready var _pos: Position2D = $UI/Pos

onready var _upgrade_bar: HBoxContainer = $UI/Pos/HUD/UpgradeBar
onready var _upgrade_butt := preload("res://src/scenes/UI/utility/butts/UpgradeButt.tscn")
onready var _sell_butt: TextureButton = $UI/Pos/HUD/BaseActions/SellBar/SellButt
onready var _target_label: Label = $UI/Pos/HUD/BaseActions/TargetingBar/Targeting/Label

var _upgrade_butts := []

onready var _next_range: TextureRect = $UI/Pos/NextRange
onready var _curr_range: TextureRect = $UI/Pos/CurrRange


var _is_showing = false

onready var _tween: Tween = $UI/Pos/Tween

var _entrance_time: float = 0.4
var _exit_time: float = 0.4

var _rotation_init: int = 180
var _rotation_final: int = 360

var _scale_init := 0.1 * Vector2.ONE
var _scale_final := Vector2.ONE

## Ultra shitcode part.
## An array of every HoverArea children' rect. They are used to check whether
## to display the UI or not by checking mouse belonging to the rectangles.
var _hover_boxes := []

## Is the building mode currently active. If so, ignore the UI input
var _is_build_active: bool = false

## The reference to the current melon this class is wrapped above
var _curr_melon: Melon
var _sell_cost: int


## Send the new melon instance on upgrade and delete itself
signal upgrade_to(new_melon)


## Hide UI if mouse is outside HoverArea boxes
func _physics_process(_delta):
	var show = false
	for box in _hover_boxes:
		if box.has_point(get_local_mouse_position()):
			show = true

	if show == false and _is_showing == true:
		_hide_ui()

## Trigger the UI display on melon collision shape hover with making visible
## the larger area of mouse focus [member _hud]  with connected mouse signals.
## There is no signal _on_melon_mouse_exited as the UI hides on that signal
## connected to [member _hud] member.
## The signal [signal _on_HUD_mouse_entered] is instantly triggered after this one,
## hiding the UI only when receiving the [signal _on_HUD_mouse_exited]
func _on_melon_mouse_entered():
	if not _is_build_active:
		_show_ui()

func _show_ui():
	_is_showing = true
	_ui.visible = true

	assert(_tween.interpolate_property(_pos, "rotation_degrees", _rotation_init, _rotation_final, _entrance_time, Tween.TRANS_BACK, Tween.EASE_OUT))
	assert(_tween.interpolate_property(_pos, "scale", _scale_init, _scale_final, _entrance_time, Tween.TRANS_BACK, Tween.EASE_OUT))
	assert(_tween.start())

## Hide the UI and restore all possible features toggled while view to default
func _hide_ui():
	_is_showing = false
	_next_range.visible = false
	modulate.a = 1
	_curr_range.modulate.a = 1

	assert(_tween.interpolate_property(_pos, "rotation_degrees", _rotation_final, _rotation_init, _exit_time, Tween.TRANS_BACK, Tween.EASE_IN))
	assert(_tween.interpolate_property(_pos, "scale", _scale_final, _scale_init, _exit_time, Tween.TRANS_BACK, Tween.EASE_IN))
	
	assert(_tween.interpolate_property(_ui, "visible", true, false, 0, Tween.TRANS_BACK, Tween.EASE_IN, _exit_time))
	assert(_tween.start())

func _prep_to_free():
	_hide_ui()
	
	# fade melon paralell to UI fade
	assert(_tween.interpolate_property(_curr_melon, "rotation_degrees", _rotation_final, _rotation_init, _exit_time, Tween.TRANS_BACK, Tween.EASE_IN))
	assert(_tween.interpolate_property(_curr_melon, "scale", _scale_final, Vector2.ZERO, _exit_time, Tween.TRANS_BACK, Tween.EASE_IN))
	assert(_tween.start())
	
	# resume function when tween finished all the animations
	yield(_tween, "tween_all_completed")
	
	# automatically emit "completed" signal after function return
	# write `yield(_prep_to_free(), "completed")` in another function to resume it
	# only after completion of all the animations by tween

## Listens to the signal from the builder to catch its status
func _toggle_build_status(status: bool):
	_is_build_active = status

## Wrap this node above the given melon instance. The melon is added as a child
## as a sibling of UI (CanvasLayer) node.
func attach_melon(melon: Melon):
	_curr_melon = melon
	self.add_child(_curr_melon)
	
	assert(_curr_melon.connect("mouse_entered", self, "_on_melon_mouse_entered") == 0)
	
	_pos.position = _curr_melon.position

	_curr_range.rect_scale = 2 * _curr_melon._base_attack_radius * Vector2(1, 1) / _curr_range.rect_min_size
	_curr_range.self_modulate = _curr_melon._color
	
	_set_targeting_label()

	var data: Dictionary = Towers.get_tower_dict(_curr_melon.tier, _curr_melon.base_tower, _curr_melon.branch)
	Events.emit_signal("update_money", - data["cost"])
	
	var idx := 0
	for next in data["next"]:
		idx += 1
		_add_upgrade_butt(str(idx), next)

	_add_sell_butt()
	
	## Save the rect of HoverArea nodes to prevent recalculations in _physics_process
	for child in $UI/Pos/HoverArea.get_children():
		child.visible = false
		_hover_boxes.append(child.get_global_rect())


# ------------------------- #

# Buttons and their signals #

func _add_upgrade_butt(name: String, dict: Dictionary):	
	var butt: Object = _upgrade_butt.instance()
	_upgrade_bar.add_child(butt)
	_upgrade_butts.append(butt)
#	butt.title(name).store(dict).color(_curr_melon._color.linear_interpolate(dict["color"], 0.7))
	butt.title(name).store(dict)
	
	assert(butt.connect("pressed", self, "_on_UpgradeButt_pressed", [butt]) == 0)
	assert(butt.connect("mouse_entered", self, "_on_UpgradeButt_mouse_entered", [butt]) == 0)
	assert(butt.connect("mouse_exited", self, "_on_UpgradeButt_mouse_exited") == 0)

func _on_UpgradeButt_mouse_entered(butt):
	_next_range.rect_scale = 2 * butt.radius * Vector2(1, 1) / _next_range.rect_min_size
	_next_range.modulate = butt.color
	_next_range.set_visible(true)

func _on_UpgradeButt_mouse_exited():
	_next_range.set_visible(false)

func _on_UpgradeButt_pressed(butt):
	# hide UI with tween and wait for animation to complete
	yield(_prep_to_free(), "completed")
	
	var new_melon: Melon = load(butt.scene).instance()
	new_melon.position = _curr_melon.position
	new_melon._target_priority = _curr_melon._target_priority
	new_melon.total_money += _curr_melon.total_money
	
	emit_signal("upgrade_to", new_melon)
	queue_free()
	

func _add_sell_butt():
	_sell_cost = int(0.7 * _curr_melon.total_money)
	_sell_butt.label(str(_sell_cost))

func _on_SellButt_mouse_entered():
	modulate.a = 0.65
	_curr_range.modulate.a = 0.65

func _on_SellButt_mouse_exited():
	modulate.a = 1
	_curr_range.modulate.a = 1

func _on_SellButt_pressed():
	# hide UI with tween and wait for animation to complete
	yield(_prep_to_free(), "completed")

	Events.emit_signal("update_money", _sell_cost)
	queue_free()


## Disable buttons if not enough money for purchase
## The function is called externaly if ammount of money was changed by listening
## to the global signal total_money_changed emmitted from MeasuresManager
func _validate_price(total: int):
	for butt in _upgrade_butts:
		if butt.cost > total:
			butt.disable()
		else:
			butt.enable()


## Change the current targeting. The action argument is either 1 or -1
## If action = 1, then the targeting goes to the next in ascending list order.
## If action = -1, then it returns back in the descending order
func _change_targeting(action: int):
	var new_targeting = (_curr_melon._target_priority + action) % Constants.TargetPriority.size()
	if new_targeting == -1:  # -1 % 7 = -1
		new_targeting = Constants.TargetPriority.size() - 1
	
	_curr_melon._target_priority = new_targeting
	_set_targeting_label()

func _set_targeting_label():
	var text: String = Constants.TargetPriority.keys()[_curr_melon._target_priority].to_lower()
	_target_label.text = text.replace("_", " ")

func _on_ToLeft_pressed():
	_change_targeting(-1)

func _on_ToRight_pressed():
	_change_targeting( 1)


# ------------------------------------------------------------------- #

# OLD FUNCTIONALITY TO REMEMBER WHY I WAS FORCED BY GODOT TO SHITCODE

## Hide the UI
#func _on_HUD_mouse_exited():

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
