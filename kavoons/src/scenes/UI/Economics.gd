extends Control

class_name Economics

var _curr_money: int

onready var label: Label = $UI/HUD/Economy/Label

signal total_money_changed(new_total)


func _set_init_money(money: int):
	_curr_money = money
	_update_label()

func _ready():
	assert(Events.connect("update_money", self, "_update_money") == 0)

func _update_money(delta: int):
	_curr_money += delta
	_update_label()
	emit_signal("total_money_changed", _curr_money)
	
func _update_label():
	label.text = String(_curr_money)
