extends Node2D


func _ready():
	$Builder.connect("tower_placed", self, "_create_melon")

func _create_melon(new_tower: Melon):
#	$Towers
#	var manager = MelonManager.new()
#	manager.fill(melon)
	$Towers.add_child(new_tower, true)
