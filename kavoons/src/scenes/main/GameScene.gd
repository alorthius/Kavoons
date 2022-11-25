extends Node2D

## Provide the single playable map interface and logic
## 
## Create the playable map, connect all the game logical parts and instances.
## A parent for all the map itself, UI, economy and life systems, enemy waves, and towers.

## The only [Builder] instance responsible to build and create new towers
onready var _builder: Builder = $Builder
onready var _is_build_active: bool = false

## Timer managing the flow of the waves of a map
onready var _waves_timer: Timer = $WavesTimer
## Container with all the placed towers
onready var _towers_container: Node = $Towers
## Container with all the spawned cats
onready var _cats_pathes: Array = $Map/Pathes.get_children()

var _curr_wave: Wave

## The preloaded [Upgrader] for the towers, is instanced for every new melon separately.
## Contains the melon itself as a child node and provides the UI to manage it.
var _melon_manager: PackedScene = preload("res://src/scenes/UI/MelonManager.tscn")

var _signal_err: int = 0


func _ready():
	_signal_err = _builder.connect("tower_placed", self, "_attach_melon")
	if _signal_err != 0: print("GameScene: _ready: connect: tower_placed: ", _signal_err)

	_waves_timer.start()

## Wrap the newly created melon with the new [Upgrader] instance.
func _attach_melon(new_tower: Melon):
	var new_manager: MelonManager = _melon_manager.instance()
	_towers_container.add_child(new_manager, true)
	new_manager.attach_melon(new_tower)
	
	_signal_err = _builder.connect("build_status", new_manager, "_toggle_build_status")
	if _signal_err != 0: print("GameScene: _ready: connect: ", _signal_err)
	
	_signal_err = new_manager.connect("upgrade_to", self, "_attach_melon")
	if _signal_err != 0: print("GameScene: _ready: connect: ", _signal_err)

## Start a new wave
func _on_WavesTimer_timeout():
	var wave = load("res://src/scenes/waves/Wave.tscn").instance()
	_curr_wave = wave
	add_child(wave, true)
	
	_signal_err = _curr_wave.connect("spawn_enemy", self, "_on_cat_spawn")
	if _signal_err != 0: print("GameScene: _on_WavesTimer_timeout: connect: spawn_enemy: ", _signal_err)
	
	_signal_err = _curr_wave.connect("spawning_ended", self, "_on_spawn_end")
	if _signal_err != 0: print("GameScene: _on_WavesTimer_timeout: connect: spawning_ended: ", _signal_err)

## Spawn the cat
func _on_cat_spawn(cat):
	var path_idx = randi() % _cats_pathes.size()
	_cats_pathes[path_idx].add_child(cat, true)

## Manage the wave end; start the countdown for a new one
func _on_spawn_end():
	_curr_wave.queue_free()
	_waves_timer.start()
