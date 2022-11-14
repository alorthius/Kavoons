extends Node2D
# the node is the child of CanvasLayer,
# because it should be displayed on top of everything


var _range_sprite = load("res://assets/towers/range.png")

var _tower_alpha_channel: float = 0.5
var _tower_scale_factor: Vector2 = Vector2(5, 5)

var _range_alpha_channel: float = 0.3


func set_preview(tower: String, position: Vector2):
	var tower_sprite = load(Towers.towers_data[tower]["T1"]["sprite"])
	var tower_range = Towers.towers_data[tower]["T1"]["range_scale"]

	$Tower.set_texture(tower_sprite)
	$Tower.set_scale(_tower_scale_factor)
	$Tower.modulate.a = _tower_alpha_channel
	
	$Range.set_texture(_range_sprite)
	# TODO: Magic constants will be removed with better sprite
	$Range.set_scale(Vector2(tower_range * 0.55, tower_range * 0.55))
	$Range.modulate.a = _range_alpha_channel

	update_preview(position)


func update_preview(position: Vector2):
	self.set_position(position)


func cancel_preview():
	$Tower.set_texture(null)
	$Range.set_texture(null)
