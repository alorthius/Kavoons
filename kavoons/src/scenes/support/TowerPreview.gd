extends Sprite
# the node is the child of CanvasLayer,
# because it should be displayed on top of everything

# preload sprites to reuse during building
var _sprites = {
	'NinjaMelon': preload('res://assets/towers/ninja_melon/T1.png'),
}

var _preview_alpha_channel: float = 0.5
var _preview_scale_factor: Vector2 = Vector2(5, 5)


func set_preview(tower: String, position: Vector2):
	self.set_texture(_sprites[tower])
	self.set_scale(_preview_scale_factor)
	self.modulate.a = _preview_alpha_channel
	update_preview(position)

func update_preview(position: Vector2):
	self.set_position(position)

func cancel_preview():
	self.set_texture(null)

#func _ready():
#	set_preview('NinjaMelon', Vector2(500, 500))
