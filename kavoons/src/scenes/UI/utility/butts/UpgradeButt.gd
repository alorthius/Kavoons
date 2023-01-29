extends "res://src/scenes/UI/utility/butts/base/LabeledButt.gd"

var cost: int
var radius: int
var color: Color
var scene: String

func store(dict: Dictionary):
	cost = dict["cost"]
	radius = dict["base_attack_radius"]
	color = dict["color"]
	scene = dict["scene"]
	
	icon(dict["sprite"]).label(str(cost)).color(color)
	return self
	
