extends "res://src/scenes/UI/utility/butts/base/Butt.gd"

signal start_wave()

onready var _position_init = rect_position
onready var _position_shifted = rect_position + Vector2(0, 40)

onready var _anim_player = $PulsatingAnimation

var _rotation_init := 330
var _rotation_final := 360

var is_showing = false
var data := ""

func _ready():
	_anim_player.play("pulsating")
	$Label.visible = false

func set_data(new_data):
	data = str(new_data)
	return self

func show_data():
	$Label.visible = true
	$Label.text = data
	assert(_tween.interpolate_property(self, "rect_rotation", _rotation_init, _rotation_final, 0.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT))
	assert(_tween.interpolate_property(self, "rect_scale", rect_scale, rect_scale, 0.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT))
	assert(_tween.start())

func hide_data():
	if not is_showing:
		return
	is_showing = false
	assert(_tween.interpolate_property(self, "rect_rotation", 400, _rotation_final, 0.3, Tween.TRANS_ELASTIC, Tween.EASE_OUT))
	assert(_tween.start())
	$Label.visible = false

func _on_WaveStarter_pressed():
	if not is_showing:
		is_showing = true
		show_data()
	else:
		is_showing = false
		emit_signal("start_wave")

func fade_out():
	assert(_tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1, Tween.TRANS_EXPO, Tween.EASE_OUT))
	assert(_tween.interpolate_property(self, "rect_position", _position_init, _position_shifted, 1, Tween.TRANS_EXPO, Tween.EASE_OUT))
	assert(_tween.start())
	yield(_tween, "tween_all_completed")
	queue_free()

func _on_WaveStarter_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_LEFT:
			_on_WaveStarter_pressed()
		if event.button_index == BUTTON_RIGHT:
			hide_data()

