extends Control

onready var _shader = $Icon.material
onready var _label = $Label
onready var _tween = $Tween
onready var _icon = $Icon


func _ready():
	_shader.set_shader_param("width", 0)
	_label.percent_visible = 0


func set_label(text):
	_label.text = str(text)
	return self

func set_icon(path: String):
	_icon.texture = load(path)
	return self


func _on_Icon_mouse_entered():
	assert(_tween.interpolate_property(_shader, "shader_param/width", 0, 1, 0.1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT))
	assert(_tween.interpolate_property(_label, "percent_visible", 0, 1, 0.1, Tween.TRANS_QUAD, Tween.EASE_IN_OUT))
	assert(_tween.start())

func _on_Icon_mouse_exited():
	assert(_tween.interpolate_property(_shader, "shader_param/width", 1, 0, 0.1, Tween.TRANS_QUAD, Tween.EASE_OUT_IN))
	assert(_tween.interpolate_property(_label, "percent_visible", 1, 0, 0.1, Tween.TRANS_QUAD, Tween.EASE_OUT_IN))
	assert(_tween.start())
