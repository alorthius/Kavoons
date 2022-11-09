extends Node2D

class_name Builder

var _is_active: bool = false
var _is_valid: bool = false
onready var _tower_preview: Sprite = $UI/HUD/TowerPreview

var build_position: Vector2
var chosen_melon: String

func _ready():
	for butt in get_tree().get_nodes_in_group("build_buttons"):
		butt.connect("pressed", self, "_make_active", [butt.get_name()])

func _process(delta):
	if _is_active:
		_update_tower_preview()

func _unhandled_input(event):
	pass

func _make_active(melon: String):
	_is_active = true
	_tower_preview.set_preview(melon, get_global_mouse_position())

func _update_tower_preview():
	_tower_preview.update_preview(get_global_mouse_position())

func _choose_melon():
	pass

func _place_melon():
	pass

func _cancel_building():
	pass
