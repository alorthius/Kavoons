extends HBoxContainer

var money_total: int

onready var _label: Label = $Label

signal total_money_changed(new_total)


func _ready():
	assert(Events.connect("update_money", self, "_update_money") == 0)

func _update_money(delta: int):
	money_total += delta
	_update_label()
	emit_signal("total_money_changed", money_total)
	
func _update_label():
	_label.text = String(money_total)
