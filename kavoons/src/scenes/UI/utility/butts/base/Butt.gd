extends TextureButton

export(float, 1) var focus_scale
export(float, 1) var butt_darkened
export(float, 1) var icon_darkened


onready var _icon: TextureRect = $Icon
onready var _tween: Tween = $Tween

var _range_sprite: Sprite


onready var _scale_init: Vector2 = rect_scale
onready var _scale_final: Vector2 = rect_scale + focus_scale * Vector2.ONE

onready var _modulate_init := modulate
onready var _modulate_butt_final := modulate.darkened(butt_darkened)
onready var _modulate_icon_final := modulate.darkened(icon_darkened)


var _scale_time: float = 0.05
var _modulate_time: float = 0.1


func _on_Butt_mouse_entered():
	assert(_tween.interpolate_property(self, "rect_scale", _scale_init, _scale_final, _scale_time, Tween.TRANS_LINEAR, Tween.EASE_OUT))
	assert(_tween.start())

func _on_Butt_mouse_exited():
	assert(_tween.interpolate_property(self, "rect_scale", _scale_final, _scale_init, _scale_time, Tween.TRANS_LINEAR, Tween.EASE_OUT))
	assert(_tween.start())


func enable():
	if disabled == false:
		return

	disabled = false
	assert(_tween.interpolate_property(self,  "self_modulate", _modulate_butt_final, _modulate_init, _modulate_time, Tween.TRANS_LINEAR, Tween.EASE_OUT))
	assert(_tween.interpolate_property(_icon, "self_modulate", _modulate_icon_final, _modulate_init, _modulate_time, Tween.TRANS_LINEAR, Tween.EASE_OUT))
	assert(_tween.start())

func disable():
	if disabled == true:
		return

	disabled = true
	assert(_tween.interpolate_property(self,  "self_modulate", _modulate_init, _modulate_butt_final, _modulate_time, Tween.TRANS_LINEAR, Tween.EASE_OUT))
	assert(_tween.interpolate_property(_icon, "self_modulate", _modulate_init, _modulate_icon_final, _modulate_time, Tween.TRANS_LINEAR, Tween.EASE_OUT))
	assert(_tween.start())


func title(new_name: String):
	name = new_name
	return self

func icon(texture_path: String):
	_icon.texture = load(texture_path)
	return self

func color(new_color: Color):
	self_modulate = new_color
	return self

func sprite(range_sprite: Sprite):
	_range_sprite = range_sprite
	return self
