extends Node2D

onready var builder: Builder = $Builder
onready var waves_timer: Timer = $WavesTimer
onready var towers_container: Node = $Towers
onready var cats_container: Path2D = $Map/Path2D

func _ready():
	builder.connect("tower_placed", self, "_attach_melon")
	waves_timer.start()


func _attach_melon(new_tower: Melon):
	towers_container.add_child(new_tower, true)


func _on_WavesTimer_timeout():
	var _wave = load("res://src/scenes/waves/Wave.tscn").instance()
	self.add_child(_wave, true)
	$Wave.connect("spawn_enemy", self, "_on_cat_spawn")
	$Wave.connect("spawning_ended", self, "_on_spawn_end")


func _on_cat_spawn(cat):
	cats_container.add_child(cat, true)


func _on_spawn_end():
	print("SPAWN ENDED")
