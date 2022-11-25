extends Control

## Provide the tower building interface
## 
## A static factory to create Tier-1 towers with the attached UI interface.
## Renders the tower preview while deciding the position of a new tower.
## The class in a game tree exists only in one instance as a child of the
## [GameScene] node. Performing the pre-building checks, it creates the new
## melon with a final position and emits its instance to the [GameScene] node
## using the signal [signal tower_placed].
class_name Builder

## All Tier-1 towers preloaded to likely place them in the future
var _towers = {
	"NinjaMelon": preload("res://src/scenes/towers/ninja_melon/NinjaT1.tscn"),
}
var _shapes = {
	"NinjaMelon": preload("res://src/resources/melon/collision_shape.tres")
}

## Is building currently active
var _is_active: bool = false

## Is position of the new melon valid
var _is_valid: bool = false

var _overlapped_melons = []

## The node containing the preview sprite of the selected melon and
## the sprite of its atack range
onready var _tower_preview: Node2D = $UI/HUD/TowerPreview

var _build_position: Vector2
var _chosen_melon: String

var _signal_err: int = 0

signal build_status(is_active)
## Emmits a newly placed melon instance to the [GameScene] node
signal tower_placed(new_tower)

## Connect the signal on press for every button; the press action
## activates the building with a certain tower represented with a button name
func _ready():
	for butt in get_tree().get_nodes_in_group("build_buttons"):
		_signal_err = butt.connect("pressed", self, "_activate_building", [butt.get_name()])
		if _signal_err != 0: print("Builder: _ready: connect: pressed: ", _signal_err)

## Render the preview of the currently selected tower
func _process(_delta):
	if _is_active:
		_update_tower_preview()

## Listen to the left and mouse buttons clicks.
## on left click finishes the the new tower and emits it,
## on right click cancels the building mode
func _unhandled_input(event):
	if _is_active:
		_validate()
		if event.is_action_pressed("ui_accept") and _is_valid:
			_place_melon()
			_cancel_building()
		if event.is_action_pressed("ui_cancel"):
			_cancel_building()

## Hold the reference of a single tower to build and render its preview
func _activate_building(melon: String):
	_is_active = true
	emit_signal("build_status", _is_active)
	_chosen_melon = melon

	_tower_preview.set_preview(_chosen_melon, _shapes[_chosen_melon ], get_global_mouse_position(), _is_valid)

## Update the activated tower preview so the current mouse position on screen
func _update_tower_preview():
	_tower_preview.update_preview(get_global_mouse_position(), _is_valid)

## Check whether the current position of a mouse is valid to place the tower
func _validate():
	_is_valid = _overlapped_melons.empty()

func _on_melon_area_entered(area):
	if area.name == "BuildingShape":
		_overlapped_melons.append(area)

func _on_melon_area_exited(area):
	if area.name == "BuildingShape":
		_overlapped_melons.erase(area)

## Choose the final tower position and emit its instance
func _place_melon():
	var new_tower = _towers[_chosen_melon].instance()
	new_tower.position = get_global_mouse_position()

	emit_signal("tower_placed", new_tower)

## Reset the building mode, inclusing the previously chosen melon and its preview
func _cancel_building():
	_is_active = false
	_is_valid = false
	_chosen_melon = ""
	_tower_preview.cancel_preview()

	emit_signal("build_status", _is_active)
