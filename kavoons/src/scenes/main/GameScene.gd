extends Node2D

var _wave = load("res://src/scenes/waves/Wave.tscn").instance()

func _ready():
	$Builder.connect("tower_placed", self, "_attach_melon")
	$WavesTimer.start()


func _attach_melon(new_tower: Melon):
	$Towers.add_child(new_tower, true)


func _physics_process(delta):
	pass


func _on_WavesTimer_timeout():
	self.add_child(_wave, true)
	$Wave.connect("spawn_enemy", self, "_on_cat_spawn")
	$Wave.connect("wave_ended", self, "_on_wave_end")


func _on_cat_spawn(cat):
	$Map/Path2D.add_child(cat, true)


func _on_wave_end():
	print("WAVE ENDED")
