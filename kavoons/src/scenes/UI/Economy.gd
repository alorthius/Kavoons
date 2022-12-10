extends HBoxContainer

var curr_money: int

onready var label: Label = $Label

signal total_money_changed(new_total)


func _ready():
	assert(Events.connect("update_money", self, "_update_money") == 0)

func _update_money(delta: int):
	curr_money += delta
	_update_label()
	emit_signal("total_money_changed", curr_money)
	
func _update_label():
	label.text = String(curr_money)
