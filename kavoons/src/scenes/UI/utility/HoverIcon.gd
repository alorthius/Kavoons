extends Control

onready var _shader = $Icon.material
onready var _tween = $Tween


func _ready():
	_shader.set_shader_param("width", 0)


func _on_Icon_mouse_entered():
#	_shader.set_shader_param("width", 1)
	assert(_tween.interpolate_property(_shader, "shader_param/width", 0, 1, 0.1))
	assert(_tween.start())


func _on_Icon_mouse_exited():
	assert(_tween.interpolate_property(_shader, "shader_param/width", 1, 0, 0.1))
	assert(_tween.start())
