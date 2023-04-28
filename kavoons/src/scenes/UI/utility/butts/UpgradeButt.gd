extends "res://src/scenes/UI/utility/butts/base/LabeledButt.gd"

var cost: int
var radius: int
var color: Color
var scene: String

var stats: Dictionary


func store(dict: Dictionary):
	cost = dict["cost"]
	radius = dict["base_attack_radius"]
	color = dict["color"]
	scene = dict["scene"]
	
	stats = dict
	
	icon(dict["sprite"]).label(cost).color(color)
	return self


func _on_UpgradeButt_pressed():
	Events.emit_signal("update_money", - cost)
