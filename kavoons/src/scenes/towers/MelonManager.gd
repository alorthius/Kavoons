extends CanvasLayer

## Provide the tower managing interface
##
## A decorator of a melon instance. It wraps above every melon using the unique
## instances for each melon separately. Provides the interface to upgrade,
## delete and view the information about a particular melon.

onready var _pos: Position2D = $BasePos

onready var _ranges_pos: Position2D = $RangesPos
onready var _curr_range = $RangesPos/CurrRangeContour

onready var _upgrade_bar: HBoxContainer = $BasePos/UpgradeBar
onready var _upgrade_butt := preload("res://src/scenes/UI/utility/butts/UpgradeButt.tscn")
onready var _sell_butt: TextureButton = $BasePos/BaseActions/SellBar/SellButt
onready var _target_label: Label = $BasePos/BaseActions/TargetingBar/Targeting/Label

var _upgrade_butts := []


onready var _tween: Tween = $BasePos/Tween

var _entrance_time: float = 0.4
var _exit_time: float = 0.4

var _rotation_init: int = 180
var _rotation_final: int = 360

var _scale_init := 0.1 * Vector2.ONE
var _scale_final := Vector2.ONE

## Is the building mode currently active. If so, ignore the UI input
var _is_build_active: bool = false

var _sell_cost: int

var _target_priority


## Send the new melon instance on upgrade and delete itself
signal upgrade_to(new_melon)

signal fade_out()

signal change_targeting(new_targeting)


func set_upgrades(data: Dictionary, radius: float, range_color: Color, sell_cost: int, target_priority):
	print(get_children())
	print(_ranges_pos)
	_ranges_pos.scale = Vector2(4, 4)
#	_ranges_pos.scale = 2 * radius * Vector2(1, 1) / _curr_range.rect_min_size
	_curr_range.self_modulate = range_color
	_sell_cost = sell_cost
	_target_priority = target_priority
	
	_set_targeting_label()
	
	var idx := 0
	for next in data["next"]:
		idx += 1
		_add_upgrade_butt(str(idx), next)

	_add_sell_butt()


func _on_Melon_input_event(viewport, event, shape_idx):
	if _is_build_active:
		return
	
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_LEFT:
			_show_ui()
		if event.button_index == BUTTON_RIGHT:
			_hide_ui()


func _show_ui():
	visible = true

	assert(_tween.interpolate_property(_pos, "rotation_degrees", _rotation_init, _rotation_final, _entrance_time, Tween.TRANS_BACK, Tween.EASE_OUT))
	assert(_tween.interpolate_property(_pos, "scale", _scale_init, _scale_final, _entrance_time, Tween.TRANS_BACK, Tween.EASE_OUT))
	assert(_tween.start())

## Hide the UI and restore all possible features toggled while view to default
func _hide_ui():
#	_next_range.visible = false
#	modulate.a = 1
#	_curr_range.modulate.a = 1

	assert(_tween.interpolate_property(_pos, "rotation_degrees", _rotation_final, _rotation_init, _exit_time, Tween.TRANS_BACK, Tween.EASE_IN))
	assert(_tween.interpolate_property(_pos, "scale", _scale_final, _scale_init, _exit_time, Tween.TRANS_BACK, Tween.EASE_IN))
	assert(_tween.start())
	
	yield(_tween, "tween_all_completed")
	visible = false

func _prep_to_free():
	_hide_ui()
	
	emit_signal("fade_out")
	
#	# fade melon paralell to UI fade
#	assert(_tween.interpolate_property(_curr_melon, "rotation_degrees", _rotation_final, _rotation_init, _exit_time, Tween.TRANS_BACK, Tween.EASE_IN))
#	assert(_tween.interpolate_property(_curr_melon, "scale", _scale_final, Vector2.ZERO, _exit_time, Tween.TRANS_BACK, Tween.EASE_IN))
#	assert(_tween.start())
	
	# resume function when tween finished all the animations
	yield(_tween, "tween_all_completed")
	
	# automatically emit "completed" signal after function return
	# write `yield(_prep_to_free(), "completed")` in another function to resume it
	# only after completion of all the animations by tween

## Listens to the signal from the builder to catch its status
func _toggle_build_status(status: bool):
	_is_build_active = status

# ------------------------- #

# Buttons and their signals #

func _create_next_range_sprite(name: String, color):
	var sprite = Sprite.new()
	_ranges_pos.add_child(sprite)
	sprite.texture = load("res://assets/UI/ranges/G.png")
	sprite.modulate = color
	return sprite

func _add_upgrade_butt(name: String, dict: Dictionary):	
	var butt: Object = _upgrade_butt.instance()
	_upgrade_bar.add_child(butt)
	_upgrade_butts.append(butt)
	butt.title(name).store(dict)
	
	var sprite = _create_next_range_sprite(name, dict["color"])
	butt.sprite(sprite)
	
#	radius = dict["base_attack_radius"]
	
	assert(butt.connect("pressed", self, "_on_UpgradeButt_pressed", [butt]) == 0)
	assert(butt.connect("mouse_entered", self, "_on_UpgradeButt_mouse_entered", [butt]) == 0)
	assert(butt.connect("mouse_exited", self, "_on_UpgradeButt_mouse_exited", [butt]) == 0)

func _on_UpgradeButt_mouse_entered(butt):
	butt._range_sprite.visible = true
#	_next_range.rect_scale = 2 * butt.radius * Vector2(1, 1) / _next_range.rect_min_size
#	_next_range.modulate = butt.color
#	_next_range.set_visible(true)

func _on_UpgradeButt_mouse_exited(butt):
	butt._range_sprite.visible = false

func _on_UpgradeButt_pressed(butt):
	# hide UI with tween and wait for animation to complete
	yield(_prep_to_free(), "completed")
	
	var new_melon: Melon = load(butt.scene).instance()
#	new_melon.position = _curr_melon.position
#	new_melon._target_priority = _curr_melon._target_priority
#	new_melon.total_money += _curr_melon.total_money
	
	emit_signal("upgrade_to", new_melon)
	queue_free()
	

func _add_sell_butt():
	_sell_butt.label(str(_sell_cost))

func _on_SellButt_mouse_entered():
#	modulate.a = 0.65
	_curr_range.modulate.a = 0.65

func _on_SellButt_mouse_exited():
#	modulate.a = 1
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
	var new_targeting = (_target_priority + action) % Constants.TargetPriority.size()
	if new_targeting == -1:  # -1 % 7 = -1
		new_targeting = Constants.TargetPriority.size() - 1
	
	emit_signal("change_targeting", new_targeting)
	_set_targeting_label()

func _set_targeting_label():
	var text: String = Constants.TargetPriority.keys()[_target_priority].to_lower()
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

