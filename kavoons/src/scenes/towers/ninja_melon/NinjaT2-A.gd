extends Melon


func _init():
	base_tower = "NinjaMelon"
	tier = "T2-A"
	
	projectile = preload("res://src/scenes/projectiles/melons/Kunai.tscn")

	next_A = null
	next_B = null
