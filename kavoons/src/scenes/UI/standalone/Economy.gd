extends HBoxContainer

var money_total: int = 0

onready var _label: Label = $Label

var _popup: Resource = preload("res://src/scenes/effects/FloatingText.tscn")
onready var _pos_start = $PosFrom
onready var _pos_end = $PosTo

signal total_money_changed(new_total)


func _ready():
	assert(Events.connect("update_money", self, "_update_money") == 0)

## Update the current amount of money on delta. The delta is added,
## so to subtract the money, delta argument should be negative
func _update_money(delta: int):
	money_total += delta
	_update_label()
	_spawn_money_changed_popup(delta)
	emit_signal("total_money_changed", money_total)

## Update label text to a new amount of money
func _update_label():
	_label.text = String(money_total)

func _spawn_money_changed_popup(delta: int):
	var popup = _popup.instance()
	add_child(popup, true)
	
	var diff = _pos_end.position - _pos_start.position
	popup.position = _pos_start.position + Vector2(0, rand_range(_pos_start.position[1], diff[1]))

	var display_text: String = ""
	var color: Color
	
	if delta > 0:
		display_text += "+"
		color = Color.gold
	else:
		color = Color.crimson
	display_text += str(delta)
	
	popup.set_label(display_text).set_color(color).set_scale_pair(Vector2(3.5, 3.5), Vector2(1.2, 1.2))
	popup.set_fade_scale(Vector2(0.6, 0.6)).set_velocity(Vector2(- 36, 36)).set_time(0.1, 0.2)
	
	popup.animate()
