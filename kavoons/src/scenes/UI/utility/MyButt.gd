extends TextureButton

var focus_delta_size := Vector2(10, 10)


onready var _tween: Tween = $Tween

onready var _size_init := rect_size
onready var _size_final := rect_size + focus_delta_size

onready var _position_init := rect_position
onready var _position_final := rect_position - focus_delta_size / 2.0

var _tween_time: float = 0.05


func _on_MyButt_mouse_entered():
	# There is no pretty way to keep button centered on changing its rect
	# https://godotengine.org/qa/10047/how-to-scale-button-when-pressed
	_tween.interpolate_property(self, "rect_size", _size_init, _size_final, _tween_time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_tween.interpolate_property(self, "rect_position", _position_init, _position_final, _tween_time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_tween.start()

func _on_MyButt_mouse_exited():
	_tween.interpolate_property(self, "rect_size", _size_final, _size_init, _tween_time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_tween.interpolate_property(self, "rect_position", _position_final, _position_init, _tween_time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_tween.start()


func disable():
	pass
