extends "res://src/scenes/UI/utility/butts/base/Butt.gd"

signal start_wave()

var is_showing = false
var data := ""

func set_data(new_data):
	visible = true
	$Label.visible = false
	data = str(new_data)
	return self

func show_data():
	$Label.visible = true
	$Label.text = data

func _on_WaveStarter_pressed():
	if not is_showing:
		is_showing = true
		show_data()
	else:
		is_showing = false
		$Label.visible = false
		emit_signal("start_wave")

func clear_data():
	data = ""
	visible = false