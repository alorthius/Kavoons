extends Position2D

var _init_scale := Vector2(0.8, 0.8)
var _peak_scale := Vector2(1, 1)
var _fade_scale := Vector2(0.4, 0.4)

onready var _label = $Label
onready var _tween = $Tween


func set_label(text: String):
	_label.text = text


func _ready():
	scale = _init_scale
	_animate()


func _animate():
	_tween.interpolate_property(self, "scale", _init_scale, _peak_scale, 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_tween.interpolate_property(self, "scale", _peak_scale, _fade_scale, 0.2, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.4)
	_tween.start()


func _on_Tween_tween_all_completed():
	queue_free()
