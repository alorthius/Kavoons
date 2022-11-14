extends Node2D

func _ready():
	$Builder.connect("tower_placed", self, "_attach_melon")
	$WavesTimer.start()


func _attach_melon(new_tower: Melon):
	$Towers.add_child(new_tower, true)


func _on_WavesTimer_timeout():
	var _wave = load("res://src/scenes/waves/Wave.tscn").instance()
	self.add_child(_wave, true)
	$Wave.connect("spawn_enemy", self, "_on_cat_spawn")
	$Wave.connect("spawning_ended", self, "_on_spawn_end")


func _on_cat_spawn(cat):
	$Map/Path2D.add_child(cat, true)


func _on_spawn_end():
	print("SPAWN ENDED")
