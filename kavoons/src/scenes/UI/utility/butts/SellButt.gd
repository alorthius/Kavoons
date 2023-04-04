extends "res://src/scenes/UI/utility/butts/base/LabeledButt.gd"


func _on_SellButt_pressed():
	Events.emit_signal("update_money", _data)
