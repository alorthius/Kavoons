extends HBoxContainer

var money_total: int = 0

onready var _label: Label = $Label

signal total_money_changed(new_total)


func _ready():
	assert(Events.connect("update_money", self, "_update_money") == 0)

## Update the current amount of money on delta. The delta is added,
## so to subtract the money, delta argument should be negative
func _update_money(delta: int):
	money_total += delta
	_update_label()
	emit_signal("total_money_changed", money_total)

## Update label text to a new amount of money
func _update_label():
	_label.text = String(money_total)
