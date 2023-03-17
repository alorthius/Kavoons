extends "res://src/scenes/UI/utility/butts/base/Butt.gd"

signal start_wave()

onready var _position_init = rect_position
onready var _position_shifted = rect_position + Vector2(0, 40)

onready var _anim_player = $PulsatingAnimation
onready var _countdown = $Countdown
onready var _timer = $PrestartTimer
onready var _timer_per_sec = $UpdatePerSec

onready var _enemies_label = $EnemiesLabel
onready var _reward_label = $PrestartReward

var _rotation_init := 330
var _rotation_final := 360

var _clicked = false
var _prestart_max_reward: int
var _prestart_reward: int
var _x_tick = 0


func _physics_process(delta):
	_countdown.value = _timer.wait_time - _timer.time_left

func _ready():
	_anim_player.play("pulsating")
	_hide_labels()
	set_physics_process(false)

func set_enemies_label(data):
	_enemies_label.text = str(data)
	return self

func set_prestart(time, max_reward):
	if time == 0:
		_countdown.value = _countdown.max_value
		return
	
	_prestart_max_reward = max_reward
	_prestart_reward = _prestart_max_reward
	_reward_label.text = str(_prestart_reward)
	
	_timer_per_sec.start()
	
	_timer.wait_time = time
	_timer.start()
	
	_countdown.max_value = time
	set_physics_process(true)

func _show_labels():
	_enemies_label.visible = true
	_reward_label.visible = true

func _hide_labels():
	_enemies_label.visible = false
	_reward_label.visible = false

func _show_data():
	_show_labels()
	assert(_tween.interpolate_property(self, "rect_rotation", _rotation_init, _rotation_final, 0.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT))
	assert(_tween.interpolate_property(self, "rect_scale", rect_scale, rect_scale, 0.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT))
	assert(_tween.start())

func _hide_data():
	assert(_tween.interpolate_property(self, "rect_rotation", 400, _rotation_final, 0.3, Tween.TRANS_ELASTIC, Tween.EASE_OUT))
	assert(_tween.start())
	_hide_labels()

func _process_left_click():
	if _clicked:
		if _timer.time_left > 0:  # prestarted wave
			Events.emit_signal("update_money", _prestart_reward)
		emit_signal("start_wave")
	else:
		_clicked = true
		_show_data()

func _process_right_click():
	if _clicked:
		_hide_data()
		_clicked = false

func fade_out():
	assert(_tween.interpolate_property(self, "modulate", Color(1, 1, 1, 1), Color(1, 1, 1, 0), 1, Tween.TRANS_EXPO, Tween.EASE_OUT))
	assert(_tween.interpolate_property(self, "rect_position", _position_init, _position_shifted, 1, Tween.TRANS_EXPO, Tween.EASE_OUT))
	assert(_tween.start())
	yield(_tween, "tween_all_completed")
	queue_free()

func _on_WaveStarter_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == BUTTON_LEFT:
			_process_left_click()
		if event.button_index == BUTTON_RIGHT:
			_process_right_click()

func _on_Timer_timeout():
	set_physics_process(false)
	_timer_per_sec.stop()
	_prestart_reward = 0
	_reward_label.text = str(_prestart_reward)

func _on_UpdatePerSec_timeout():
#	_prestart_reward -= _prestart_max_reward / float(_timer.wait_time)
	_x_tick += 1
#	var scale = - 1.0 / pow(_timer.wait_time, 2) * (_x_tick + _timer.wait_time) * (_x_tick - _timer.wait_time)
	var scale = 0.5 * cos(PI / _timer.wait_time * _x_tick) + 0.5
	print(scale)
	_prestart_reward = scale * _prestart_max_reward
	_reward_label.text = str(_prestart_reward)
