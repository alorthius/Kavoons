extends Node2D

## Render the preview of the tower chosen to be build via [Builder]
##
## Display the tower sprite and its range with a certain level of transparency.

var _tower_valid_rgba: Color = Color(1, 1, 1, 0.7)
var _tower_invalid_rgba: Color = Color(1, 0.2, 0.2, 0.8)

var _range_valid_rgba: Color = Color(1, 1, 1, 0.5)
var _range_invalid_rgba: Color = Color(0.5, 0, 0, 0.8)

onready var _tower_sprite: Sprite = $Tower
onready var _range_sprite: Sprite = $Range

# TODO: preload all melon sprites and range values in a dictionary

## Load the texture of a new tower, adjust its range value, and display them
func set_preview(tower: String, new_position: Vector2, is_valid: bool):
	visible = true

	_tower_sprite.set_texture(load(Towers.get_T1_attr(tower, "sprite")))
	_range_sprite.set_scale(2 * Towers.get_T1_attr(tower, "base_attack_radius") * Vector2(1, 1) / _range_sprite.texture.get_size())

	update_preview(new_position, is_valid)

## Change the position of the tower and range sprites to a new position
func update_preview(new_position: Vector2, is_valid: bool):
	_recolor(is_valid)
	position = new_position

## Remove the texture of a tower sprite and its range
func cancel_preview():
	visible = false

	_tower_sprite.set_texture(null)

## Set sprite_node's texture, scale and alpha channel to render
func _set_properties(sprite_node: Sprite, new_texture, new_scale, new_color):
	if new_texture != null:
		sprite_node.set_texture(new_texture)
	sprite_node.set_scale(Vector2(new_scale, new_scale))
	sprite_node.set_modulate(new_color)

func _recolor(is_valid):
	if is_valid:
		_tower_sprite.modulate = _tower_valid_rgba
		_range_sprite.modulate = _range_valid_rgba
	else:
		_tower_sprite.modulate = _tower_invalid_rgba
		_range_sprite.modulate = _range_invalid_rgba
