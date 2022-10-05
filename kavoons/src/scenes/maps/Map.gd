extends Node2D

class_name Map

func _ready():
	var upgr = load("res://src/scenes/support/Upgrader.tscn").instance()
	print(upgr)
	self.add_child(upgr, true)

	var ninja = load("res://src/scenes/towers/ninja_melon/NinjaT1.tscn").instance()
	upgr.add_child(ninja, true)
	print(upgr.get_child(0))

	ninja.position = Vector2(500, 500)
	ninja.base_sprite.scale.x = 5
	ninja.base_sprite.scale.y = 5
