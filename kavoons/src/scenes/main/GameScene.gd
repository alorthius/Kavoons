extends Node2D

func _ready():
	var upgr = $Upgrader

	var ninja = load("res://src/scenes/towers/ninja_melon/NinjaT1.tscn").instance()
	upgr.add_child(ninja, true)
	print(upgr.get_child(0))

	ninja.position = Vector2(500, 500)
	ninja.base_sprite.scale.x = 5
	ninja.base_sprite.scale.y = 5

	yield(get_tree().create_timer(0.2), "timeout")
	var cat = load("res://src/scenes/enemies/Cat1.tscn").instance()
	$Map.get_node("Path2D").add_child(cat)
	
