extends Node2D

onready var builder: Builder = $Builder
onready var waves_timer: Timer = $WavesTimer
onready var towers_container: Node = $Towers
onready var cats_container: Path2D = $Map/Path2D

var curr_wave

var _signal_err: int = 0

func _ready():
	_signal_err = builder.connect("tower_placed", self, "_attach_melon")
	if _signal_err != 0:
		print("GameScene: _reade: connect(): ", _signal_err)
	waves_timer.start()


func _attach_melon(new_tower: Melon):
	towers_container.add_child(new_tower, true)


func _on_WavesTimer_timeout():
	var _wave = load("res://src/scenes/waves/Wave.tscn").instance()
	curr_wave = _wave
	add_child(_wave, true)
	
	_signal_err = curr_wave.connect("spawn_enemy", self, "_on_cat_spawn")
	if _signal_err != 0:
		print("GameScene: _on_WavesTimer_timeout: connect(): spawn_enemy: ", _signal_err)
	
	_signal_err = curr_wave.connect("spawning_ended", self, "_on_spawn_end")
	if _signal_err != 0:
		print("GameScene: _on_WavesTimer_timeout: connect(): spawning_ended: ", _signal_err)


func _on_cat_spawn(cat):
	cats_container.add_child(cat, true)


func _on_spawn_end():
	print("SPAWN ENDED")
	curr_wave.queue_free()
	waves_timer.start()
