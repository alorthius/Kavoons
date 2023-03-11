extends HBoxContainer

var _lifes_remain: int = 0

onready var _label: Label = $Label

signal finish_game()

func _ready():
	assert(Events.connect("update_lifes", self, "_update_lifes") == 0)

## Update the current amount of lifes on delta. The delta is added,
## so to subtract the lifes, delta argument should be negative
func _update_lifes(delta: int):
	_lifes_remain += delta
	if _lifes_remain <= 0:
		emit_signal("finish_game")
	_update_label()

## Update label text to a new amount of lifes
func _update_label():
	_label.text = String(_lifes_remain)
