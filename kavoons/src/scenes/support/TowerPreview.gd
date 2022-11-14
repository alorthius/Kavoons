extends Node2D
# the node is the child of CanvasLayer,
# because it should be displayed on top of everything


var _range_sprite = load("res://assets/towers/range.png")
var _preview_alpha_channel: float = 0.5
var _preview_scale_factor: Vector2 = Vector2(5, 5)


func set_preview(tower: String, position: Vector2):
	var tower_sprite = load(Towers.towers_data[tower]["T1"]["sprite"])
	$Tower.set_texture(tower_sprite)
	$Tower.set_scale(_preview_scale_factor)
	$Tower.modulate.a = _preview_alpha_channel
	
	$Range.set_texture(_range_sprite)
	$Range.set_scale(_preview_scale_factor)
	$Range.modulate.a = _preview_alpha_channel

	update_preview(position)

func update_preview(position: Vector2):
	self.set_position(position)

func cancel_preview():
	$Tower.set_texture(null)
	$Range.set_texture(null)

#func _ready():
#	set_preview('NinjaMelon', Vector2(500, 500))
