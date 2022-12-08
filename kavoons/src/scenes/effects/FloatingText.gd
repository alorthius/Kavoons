extends Position2D

var _init_scale := Vector2(0.8, 0.8)
var _peak_scale := Vector2(1, 1)
var _fade_scale := Vector2(0.4, 0.4)

var _velocity := Vector2(36, 36)

onready var _label = $Label
onready var _tween = $Tween


func set_label(text: String):
	_label.text = text

func set_color(color: Color):
	_label.set("custom_colors/font_color", color)

func set_scale_pair(init: Vector2, peak: Vector2):
	_init_scale = init
	_peak_scale = peak

func _set_velocity():
	_velocity *= _peak_scale.length()


func _process(delta):
	position -= _velocity * delta


func animate():
	_set_velocity()
	scale = _init_scale
	_tween.interpolate_property(self, "scale", _init_scale, _peak_scale, 0.3, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_tween.interpolate_property(self, "scale", _peak_scale, _fade_scale, 0.1, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.3)
	_tween.start()

func _on_Tween_tween_all_completed():
	queue_free()
