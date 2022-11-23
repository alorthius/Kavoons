extends Node2D

onready var _builder: Builder = $Builder
onready var _waves_timer: Timer = $WavesTimer
onready var _towers_container: Node = $Towers
onready var _cats_container: Path2D = $Map/Path2D

var _curr_wave

var _upgrader = preload("res://src/scenes/UI/Upgrader.tscn")

var _signal_err: int = 0


func _ready():
	_signal_err = _builder.connect("tower_placed", self, "_attach_melon")
	if _signal_err != 0: print("GameScene: _ready: connect: ", _signal_err)
	_waves_timer.start()


func _attach_melon(new_tower: Melon):
	var new_upgrader = _upgrader.instance()
	_towers_container.add_child(new_upgrader, true)
	new_upgrader.attach_melon(new_tower)


func _on_WavesTimer_timeout():
	var wave = load("res://src/scenes/waves/Wave.tscn").instance()
	_curr_wave = wave
	add_child(wave, true)
	
	_signal_err = _curr_wave.connect("spawn_enemy", self, "_on_cat_spawn")
	if _signal_err != 0: print("GameScene: _on_WavesTimer_timeout: connect: spawn_enemy: ", _signal_err)
	
	_signal_err = _curr_wave.connect("spawning_ended", self, "_on_spawn_end")
	if _signal_err != 0: print("GameScene: _on_WavesTimer_timeout: connect: spawning_ended: ", _signal_err)


func _on_cat_spawn(cat):
	_cats_container.add_child(cat, true)


func _on_spawn_end():
	print("SPAWN ENDED")
	_curr_wave.queue_free()
	_waves_timer.start()
