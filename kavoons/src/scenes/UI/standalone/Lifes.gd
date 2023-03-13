extends HBoxContainer

var _lifes_remain: int = 0

onready var _label: Label = $Label

var _popup: Resource = preload("res://src/scenes/effects/FloatingText.tscn")
onready var _pos_start = $PosFrom
onready var _pos_end = $PosTo

signal finish_game()

func _ready():
	assert(Events.connect("update_lifes", self, "_update_lifes") == 0)

## Update the current amount of lifes on delta. The delta is added,
## so to subtract the lifes, delta argument should be negative
func _update_lifes(delta: int):
	_lifes_remain += delta
	_spawn_lifes_changed_popup(delta)
	if _lifes_remain <= 0:
		emit_signal("finish_game")
	_update_label()

## Update label text to a new amount of lifes
func _update_label():
	_label.text = String(_lifes_remain)

func _spawn_lifes_changed_popup(delta: int):
	var popup = _popup.instance()
	add_child(popup, true)
	
	var diff = _pos_end.position - _pos_start.position
	popup.position = _pos_start.position + Vector2(0, rand_range(_pos_start.position[1], diff[1]))

	var display_text: String = ""
	var color: Color
	
	if delta > 0:
		display_text += "+"
		color = Color.lightgreen
	else:
		color = Color.crimson
	display_text += str(delta)
	
	popup.set_label(display_text).set_color(color).set_scale_pair(Vector2(3.5, 3.5), Vector2(1.2, 1.2))
	popup.set_fade_scale(Vector2(0.6, 0.6)).set_velocity(Vector2(- 36, 36)).set_time(0.1, 0.2)
	
	popup.animate()
