extends "res://src/scenes/UI/utility/butts/base/Butt.gd"

signal start_wave()

onready var _position_init = rect_position
onready var _position_shifted = rect_position + Vector2(0, 40)

onready var _anim_player = $PulsatingAnimation
onready var _countdown = $Countdown
onready var _timer = $PrestartTimer
onready var _timer_per_sec = $UpdatePerSec

onready var _enemies_label = $Label
onready var _reward_label = $PrestartReward


var _rotation_init := 330
var _rotation_final := 360

var is_showing = false

var _prestart_max_reward: int
var _prestart_reward: int
var _x_tick = 0

signal prestart(reward)


func _physics_process(delta):
	_countdown.value = _timer.wait_time - _timer.time_left

func _ready():
	_anim_player.play("pulsating")
	_hide_labels()
	set_physics_process(false)

func set_data(new_data):
	_enemies_label.text = str(new_data)
	return self

func set_prestart(time, max_reward):
	if time == 0:
		_countdown.value = _countdown.max_value
		return
	
	_prestart_max_reward = max_reward
	_prestart_reward = _prestart_max_reward
	_update_reward_label()
	
	_timer_per_sec.start()
	
	_timer.wait_time = time
	_timer.start()
	
	_countdown.max_value = time
	set_physics_process(true)

func _hide_labels():
	_enemies_label.visible = false
	_reward_label.visible = false

func _show_labels():
	_enemies_label.visible = true
	_reward_label.visible = true

func _update_reward_label():
	_reward_label.text = str(_prestart_reward)
	assert(_tween.interpolate_property(_reward_label, "rect_rotation", _rotation_init, _rotation_final, 0.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT))
#	assert(_tween.interpolate_property(_reward_label, "rect_scale", rect_scale, rect_scale, 0.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT))
	assert(_tween.start())

func show_data():
	_show_labels()
	assert(_tween.interpolate_property(self, "rect_rotation", _rotation_init, _rotation_final, 0.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT))
	assert(_tween.interpolate_property(self, "rect_scale", rect_scale, rect_scale, 0.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT))
	assert(_tween.start())

func hide_data():
	if not is_showing:
		return
	is_showing = false
	assert(_tween.interpolate_property(self, "rect_rotation", 400, _rotation_final, 0.3, Tween.TRANS_ELASTIC, Tween.EASE_OUT))
	assert(_tween.start())
	_hide_labels()

func _on_WaveStarter_pressed():
	if not is_showing:
		is_showing = true
		show_data()
	else:
		if _timer.time_left > 0:  # prestarted wave
			Events.emit_signal("update_money", _prestart_reward)
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

func _on_UpdatePerSec_timeout():
	_x_tick += 1
#	_prestart_reward -= _prestart_max_reward / float(_timer.wait_time)
#	var scale = - 1.0 / pow(_timer.wait_time, 2) * (_x_tick + _timer.wait_time) * (_x_tick - _timer.wait_time)
	var scale = 0.5 * cos(PI / _timer.wait_time * _x_tick) + 0.5
	_prestart_reward = scale * _prestart_max_reward
	_update_reward_label()

func _on_PrestartTimer_timeout():
	set_physics_process(false)
	_timer_per_sec.stop()
	_prestart_reward = 0
#	_update_reward_label()
