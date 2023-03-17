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


onready var _build_bar: HBoxContainer = $BuildBar
onready var _build_butts: Array = []

## Is building currently active
var _is_active: bool = false

## Is position of the new melon valid
var _is_valid: bool = false
## List of already placed melons currently overlapping with the building one
var _overlapped_melons = []
## List of path tiles currently overlapping with the building one
var _overlapped_tiles = []

## The node managing the melon preview while building is active
onready var _tower_preview: Node2D = $TowerPreview

var _chosen_melon: String

## Emits building status to not trigger other ui during the building
signal build_status(is_active)
## Emits a newly placed melon instance to the [GameScene] node
signal tower_placed(new_tower)

var _build_butt := preload("res://src/scenes/UI/utility/butts/BuildButt.tscn")


## Connect the signal on press for every button; the press action
## activates the building with a certain tower represented with its button name
func _ready():
	_tower_preview.visible = false
	
	for base_tower in Towers.T1:
		var icon = Towers.get_T1_attr(base_tower, "sprite")
		var text = String(Towers.get_T1_attr(base_tower, "cost"))
		
		var butt: Object = _build_butt.instance()
		_build_bar.add_child(butt)
		butt.title(base_tower).icon(icon).label(text)
		
		assert(butt.connect("pressed", self, "_activate_building", [butt.name]) == 0)

## Render the preview of the currently selected tower
func _process(_delta):
	if _is_active:
		_update_tower_preview()
		_validate_position()
		
		if Input.is_action_pressed("ui_accept") and _is_valid:
			_place_melon()
			_cancel_building()
		
		if Input.is_action_pressed("ui_cancel"):
			_cancel_building()

## Disable buttons if not enough money for purchase
func _validate_price(total: int):
	for butt in _build_butts:
		var icon: TextureRect = butt.get_node("Icon")
		
		if Towers.get_T1_attr(butt.name, "cost") > total:
			if not butt.disabled:
				butt.disabled = true
				icon.self_modulate = icon.modulate.darkened(0.5)
		else:
			butt.disabled = false
			icon.self_modulate = Color(1, 1, 1, 1)


## Hold the reference of a single tower to build and render its preview
func _activate_building(melon: String):
	_is_active = true
	emit_signal("build_status", _is_active)
	_chosen_melon = melon

	_tower_preview.set_preview(_chosen_melon, get_global_mouse_position(), _is_valid)

## Update the activated tower preview to the current mouse position on screen
func _update_tower_preview():
	_tower_preview.update_preview(get_global_mouse_position(), _is_valid)

## Check whether the current position of a mouse is valid to place the tower
func _validate_position():
	# valid only if the current melon doesn't overlap with other melons and collision tiles (e.g. road)
	_is_valid = _overlapped_melons.empty() and _overlapped_tiles.empty()

## Choose the final tower position and emit its instance
func _place_melon():
	var new_tower = load(Towers.get_T1_attr(_chosen_melon, "scene")).instance()
	new_tower.position = get_global_mouse_position()

	emit_signal("tower_placed", new_tower)

## Reset the building mode, including the previously chosen melon and its preview
func _cancel_building():
	_is_active = false
	_is_valid = false
	_chosen_melon = ""
	_tower_preview.cancel_preview()

	emit_signal("build_status", _is_active)

## Listen to collision tiles entering
func _on_BuildingShape_body_entered(body):
	_overlapped_tiles.append(body)

## Listen to collision tiles exiting
func _on_BuildingShape_body_exited(body):
	_overlapped_tiles.erase(body)

## Listen to other melons entering
func _on_BuildingShape_area_entered(area):
	if area.is_in_group("melons"):
		_overlapped_melons.append(area)

## Listen to other melons exiting
func _on_BuildingShape_area_exited(area):
	if area.is_in_group("melons"):
		_overlapped_melons.erase(area)
