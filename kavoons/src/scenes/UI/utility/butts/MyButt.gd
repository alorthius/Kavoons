extends TextureButton

export var focus_scale := Vector2(0.1, 0.1)


onready var _tween: Tween = $Tween

onready var _scale_init := rect_scale
onready var _scale_final := rect_scale + focus_scale

onready var _position_init := rect_position
onready var _position_final := rect_position - rect_size * focus_scale / 2.0

var _tween_time: float = 0.05


func _on_MyButt_mouse_entered():
	# There is no pretty way to keep button centered on changing its rect
	# https://godotengine.org/qa/10047/how-to-scale-button-when-pressed
	assert(_tween.interpolate_property(self, "rect_scale", _scale_init, _scale_final, _tween_time, Tween.TRANS_LINEAR, Tween.EASE_OUT) == true)
	assert(_tween.interpolate_property(self, "rect_position", _position_init, _position_final, _tween_time, Tween.TRANS_LINEAR, Tween.EASE_OUT) == true)
	assert(_tween.start() == true)

func _on_MyButt_mouse_exited():
	assert(_tween.interpolate_property(self, "rect_scale", _scale_final, _scale_init, _tween_time, Tween.TRANS_LINEAR, Tween.EASE_OUT))
	assert(_tween.interpolate_property(self, "rect_position", _position_final, _position_init, _tween_time, Tween.TRANS_LINEAR, Tween.EASE_OUT))
	assert(_tween.start())


func disable():
	pass
