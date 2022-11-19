extends Node2D
# the node is the child of CanvasLayer,
# because it should be displayed on top of everything


var _range_texture = load("res://assets/towers/range.png")

var _tower_alpha_channel: float = 0.5
var _tower_scale_factor: Vector2 = Vector2(5, 5)

var _range_alpha_channel: float = 0.3

onready var _tower_sprite: Sprite = $Tower
onready var _range_sprite: Sprite = $Range


func set_preview(tower: String, position: Vector2):
	# TODO: preload all melon sprites in a dictionary
	var new_tower_sprite = load(Towers.towers_data[tower]["T1"]["sprite"])
	var tower_range = Towers.towers_data[tower]["T1"]["range_scale"]

	_tower_sprite.set_texture(new_tower_sprite)
	_tower_sprite.set_scale(_tower_scale_factor)
	_tower_sprite.modulate.a = _tower_alpha_channel
	
	_range_sprite.set_texture(_range_texture)
	# TODO: Magic constants will be removed with better sprite
	_range_sprite.set_scale(Vector2(tower_range * 0.55, tower_range * 0.55))
	_range_sprite.modulate.a = _range_alpha_channel

	update_preview(position)


func update_preview(position: Vector2):
	self.set_position(position)


func cancel_preview():
	_tower_sprite.set_texture(null)
	_range_sprite.set_texture(null)
