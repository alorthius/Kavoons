extends Position2D

var _init_scale := Vector2(0.8, 0.8)
var _peak_scale := Vector2(1, 1)
var _fade_scale := Vector2(0.4, 0.4)

var _first_time = 0.3
var _second_time = 0.1

var _velocity := Vector2(36, 36)

onready var _label = $Label
onready var _tween = $Tween


func set_label(text: String):
	_label.text = text
	return self

func set_color(color: Color):
	_label.set("custom_colors/font_color", color)
	return self

func set_scale_pair(init: Vector2, peak: Vector2):
	_init_scale = init
	_peak_scale = peak
	return self

func set_fade_scale(fade_scale: Vector2):
	_fade_scale = fade_scale
	return self

func set_velocity(velocity: Vector2):
	_velocity = velocity
	return self

func set_time(first_time, second_time):
	_first_time = first_time
	_second_time = second_time


func _process(delta):
	position -= _velocity * delta

func animate():
	_velocity *= _peak_scale.length()
	scale = _init_scale
	_tween.interpolate_property(self, "scale", _init_scale, _peak_scale, _first_time, Tween.TRANS_LINEAR, Tween.EASE_OUT)
	_tween.interpolate_property(self, "scale", _peak_scale, _fade_scale, _second_time, Tween.TRANS_LINEAR, Tween.EASE_OUT, _first_time)
	_tween.start()

func _on_Tween_tween_all_completed():
	queue_free()
