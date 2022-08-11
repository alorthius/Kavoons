extends Node2D


func _physics_process(delta):
	turn()

func turn():
	var enemy_position = get_global_mouse_position()
	get_node("Turret").look_at(enemy_position)
