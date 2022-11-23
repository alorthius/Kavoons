extends Control

class_name Builder

var _towers = {
	"NinjaMelon": preload("res://src/scenes/towers/ninja_melon/NinjaT1.tscn"),
}

var _is_active: bool = false
var _is_valid: bool = false
onready var _tower_preview: Node2D = $UI/HUD/TowerPreview

var _build_position: Vector2
var _chosen_melon: String

var _signal_err: int = 0

signal tower_placed(new_tower)


func _ready():
	for butt in get_tree().get_nodes_in_group("build_buttons"):
		_signal_err = butt.connect("pressed", self, "_activate_building", [butt.get_name()])
		if _signal_err != 0: print("Builder: _ready: connect: pressed: ", _signal_err)


func _process(_delta):
	if _is_active:
		_update_tower_preview()


func _unhandled_input(event):
	if _is_active:
		if event.is_action_pressed("ui_accept"):
			_place_melon()
			_cancel_building()
		if event.is_action_pressed("ui_cancel"):
			_cancel_building()


func _activate_building(melon: String):
	_is_active = true
	_chosen_melon = melon
	_tower_preview.set_preview(_chosen_melon, get_global_mouse_position())


func _update_tower_preview():
	_tower_preview.update_preview(get_global_mouse_position())


func _validate():
	pass


func _place_melon():
	var new_tower = _towers[_chosen_melon].instance()
	new_tower.position = get_global_mouse_position()
	emit_signal("tower_placed", new_tower)


func _cancel_building():
	_is_active = false
	_is_valid = false
	_tower_preview.cancel_preview()
