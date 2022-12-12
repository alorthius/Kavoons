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


onready var _build_bar: HBoxContainer = $UI/HUD/BuildBar
#onready var _build_butts: Array = _build_bar.get_children()
onready var _build_butts: Array = []

## Is building currently active
var _is_active: bool = false

## Is position of the new melon valid
var _is_valid: bool = false
## List of already places melons currently overlapping with the building one
var _overlapped_melons = []
## List of path tiles currently overlapping with the building one
var _overlapped_tiles = []

var _focus_delta_size = Vector2(10, 10)

## The node managing the melon preview while building is active
onready var _tower_preview: Node2D = $UI/HUD/TowerPreview

var _build_position: Vector2
var _chosen_melon: String

var _signal_err: int = 0

## Emits building status to not trigger other ui during the building
signal build_status(is_active)
## Emits a newly placed melon instance to the [GameScene] node
signal tower_placed(new_tower)

func _get_attr(base_tower: String, attr: String):
	return Towers.T1_towers[base_tower][0][attr]

func _create_build_button(tower_name: String):
	var butt: TextureButton = TextureButton.new()
	_build_bar.add_child(butt)

	butt.name = tower_name
	butt.expand = true
	
	butt.texture_normal = load("res://assets/UI/tower_build_button.png")
	butt.texture_disabled = load("res://assets/UI/disabled_build_button.png")
	
	butt.rect_min_size = Vector2(100, 100)
	butt.size_flags_horizontal = SIZE_SHRINK_CENTER
	butt.size_flags_vertical = SIZE_SHRINK_CENTER
	
	var icon: TextureRect = TextureRect.new()
	butt.add_child(icon)
	
	icon.name = "Icon"
	icon.expand = true
	
	icon.texture = load(_get_attr(tower_name, "sprite"))
	icon.rect_min_size = Vector2(80, 80)
	icon.margin_left = 10
	icon.margin_top = 10
	icon.margin_right = -10
	icon.margin_bottom = -10
	icon.anchor_right = 1
	icon.anchor_bottom = 1
	
	icon.size_flags_horizontal = SIZE_SHRINK_CENTER
	icon.size_flags_vertical = SIZE_SHRINK_CENTER
	
	var label: Label = Label.new()
	icon.add_child(label)
	
	label.name = "Cost"
	label.align = Label.ALIGN_CENTER
	label.valign = Label.VALIGN_BOTTOM
	
	label.margin_top = -30
	label.rect_min_size = Vector2(80, 30)
	
	label.set("custom_fonts/font", load("res://src/resources/fonts/build_cost.tres"))
	
	_build_butts.push_back(butt)


## Connect the signal on press for every button; the press action
## activates the building with a certain tower represented with its button name
func _ready():
	_tower_preview.visible = false
	
	for base_tower in Towers.T1_towers:
		var data = Towers.T1_towers[base_tower][0]
		_create_build_button(base_tower)

	for butt in _build_butts:
		assert(butt.connect("pressed", self, "_activate_building", [butt.name]) == 0)
		assert(butt.connect("mouse_entered", self, "_focus_button", [butt]) == 0)
		assert(butt.connect("mouse_exited", self, "_unfocus_button", [butt]) == 0)
		
		var label: Label = butt.get_node("Icon/Cost")
		label.text = String(_get_attr(butt.name, "cost"))
		label.set("custom_colors/font_color", _get_attr(butt.name, "color"))
		label.set("custom_colors/font_outline_modulate", _get_attr(butt.name, "color").darkened(0.65))

## Render the preview of the currently selected tower
func _process(_delta):
	if _is_active:
		_update_tower_preview()

## Disable buttons if not enough money for purchase
func _validate_price(total: int):
	for butt in _build_butts:
		var icon: TextureRect = butt.get_node("Icon")
		
		if _get_attr(butt.name, "cost") > total:
			if not butt.disabled:
				butt.disabled = true
				icon.self_modulate = icon.modulate.darkened(0.5)
		else:
			butt.disabled = false
			icon.self_modulate = Color(1, 1, 1, 1)

## Listen to the left and right mouse buttons clicks.
## On left click finishes the the new tower and emits it,
## on right click cancels the building mode
func _unhandled_input(event):
	if _is_active:
		_validate_position()
		if event.is_action_pressed("ui_accept") and _is_valid:
			_place_melon()
			_cancel_building()
		if event.is_action_pressed("ui_cancel"):
			_cancel_building()

func _focus_button(butt: TextureButton):
	butt.rect_size += _focus_delta_size
	butt.rect_position += - _focus_delta_size / 2.0

## Shrink button on hover
func _unfocus_button(butt: TextureButton):
	butt.rect_size -= _focus_delta_size
	butt.rect_position -= - _focus_delta_size / 2.0

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
	var new_tower = load(_get_attr(_chosen_melon, "scene")).instance()
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
