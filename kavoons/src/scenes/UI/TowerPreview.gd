extends Node2D
# the node is the child of CanvasLayer,
# because it should be displayed on top of everything

var _tower_alpha_channel: float = 0.5
var _tower_scale_factor: float = 5

var _range_texture = load("res://assets/towers/range.png")
var _range_alpha_channel: float = 0.3

onready var _tower_sprite: Sprite = $Tower
onready var _range_sprite: Sprite = $Range

# TODO: preload all melon sprites and range values in a dictionary

func set_preview(tower: String, new_position: Vector2):
	var tower_texture = load(Towers.towers_data[tower]["T1"]["sprite"])
	var tower_range = Towers.towers_data[tower]["T1"]["range_scale"]
	
	_set_properties(_tower_sprite, tower_texture, _tower_scale_factor, _tower_alpha_channel)
	_set_properties(_range_sprite, _range_texture, tower_range * 0.55, _range_alpha_channel)

	update_preview(new_position)


func update_preview(new_position: Vector2):
	self.set_position(new_position)


func cancel_preview():
	_tower_sprite.set_texture(null)
	_range_sprite.set_texture(null)


func _set_properties(sprite_node: Sprite, new_texture, new_scale, new_alpha):
	sprite_node.set_texture(new_texture)
	sprite_node.set_scale(Vector2(new_scale, new_scale))
	sprite_node.modulate.a = new_alpha
