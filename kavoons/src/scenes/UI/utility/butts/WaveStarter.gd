extends "res://src/scenes/UI/utility/butts/base/Butt.gd"

var _cat_icon = preload("res://src/scenes/UI/utility/icons/CatHoverIcon.tscn")

onready var _position_init = rect_position
onready var _position_shifted = rect_position + Vector2(0, 40)

onready var _anim_player = $PulsatingAnimation
onready var _countdown = $Countdown
onready var _timer = $PrestartTimer
onready var _timer_per_sec = $UpdatePerSec

onready var _cats_icons = $CatsIcons
onready var _reward_label = $PrestartReward

var _rotation_init := 330
var _rotation_final := 360

var _clicked = false
var _prestart_max_reward: int
var _prestart_reward: int
var _x_tick = 0


signal start_wave()


func _physics_process(_delta):
	_countdown.value = _timer.wait_time - _timer.time_left

func _ready():
	_reward_label.text = ""
	_anim_player.play("pulsating")
	_hide_icons()
	_hide_reward()
	set_physics_process(false)

func set_icons(dict: Dictionary):
	var d = Dictionary()
	for cat_name in dict.keys():
		var num = dict[cat_name]
		var new_icon = _cat_icon.instance()
		_cats_icons.add_child(new_icon)
		new_icon.set_name(cat_name).set_num(num)
		d[cat_name] = new_icon
	return d

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

func _show_reward():
	_reward_label.visible = true

func _hide_reward():
	_reward_label.visible = false

func _show_icons():
	_cats_icons.visible = true

func _hide_icons():
	_cats_icons.visible = false

func _show_data():
	_show_icons()
	_show_reward()
	assert(_tween.interpolate_property(self, "rect_rotation", _rotation_init, _rotation_final, 0.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT))
	assert(_tween.interpolate_property(self, "rect_scale", rect_scale, rect_scale, 0.5, Tween.TRANS_ELASTIC, Tween.EASE_OUT))
	assert(_tween.start())

func _hide_data():
	assert(_tween.interpolate_property(self, "rect_rotation", 400, _rotation_final, 0.3, Tween.TRANS_ELASTIC, Tween.EASE_OUT))
	assert(_tween.start())
	_hide_icons()
	_hide_reward()

func _process_left_click():
	if _clicked:
		if _timer.time_left > 0 and _prestart_reward > 0:  # prestarted wave
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
	_reward_label.text = ""

func _on_UpdatePerSec_timeout():
	_x_tick += 1
	var scale = 0.5 * cos(PI / _timer.wait_time * _x_tick) + 0.5
	_prestart_reward = scale * _prestart_max_reward
	_reward_label.text = str(_prestart_reward)
