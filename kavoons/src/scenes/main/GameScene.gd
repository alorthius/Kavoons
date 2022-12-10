extends Node2D

## Provide the single playable map interface and logic
## 
## Create the playable map, connect all the game logical parts and instances.
## A parent for all the map itself, UI, economy and life systems, enemy waves, and towers.

## The only [Builder] instance responsible to build and create new towers
onready var _builder: Builder = $Builder
onready var _is_build_active: bool = false

onready var _measures = $MeasuresManager

## Timer managing the flow of the waves of a map
onready var _waves_timer: Timer = $WavesTimer
## Container with all the placed towers
onready var _towers_container: Node = $Towers
## Container with all the spawned cats
onready var _cats_pathes: Array = $Map/Pathes.get_children()
## Spawns effects
#onready var _effects_manager: Node = $EffectsManager

var _curr_wave: Wave

## The preloaded [MelonManager] for the towers, is instanced for every new melon separately.
## Contains the melon itself as a child node and provides the UI to manage it.
var _melon_manager: PackedScene = preload("res://src/scenes/UI/interactive/MelonManager.tscn")

var _signal_err: int = 0


func _ready():
	_measures.set_init_money(666)

	assert(_builder.connect("tower_placed", self, "_attach_melon") == 0)
	assert(_measures._economics.connect("total_money_changed", _builder, "_validate_price") == 0)

	_waves_timer.start()

## Wrap the newly created melon with the new [Upgrader] instance.
func _attach_melon(new_tower: Melon):
	var new_manager: MelonManager = _melon_manager.instance()
	_towers_container.add_child(new_manager, true)
	new_manager.attach_melon(new_tower)
	
	assert(_builder.connect("build_status", new_manager, "_toggle_build_status") == 0)
	assert(_measures._economics.connect("total_money_changed", new_manager, "_validate_price") == 0)

	assert(new_manager.connect("upgrade_to", self, "_attach_melon") == 0)
	
	# forces melons to validate cost of upgrades according to current amount of money
	_measures._economics.emit_signal("total_money_changed", _measures._economics.money_total)  # shitcode

## Start a new wave
func _on_WavesTimer_timeout():
	var wave = load("res://src/scenes/waves/Wave.tscn").instance()
	_curr_wave = wave
	add_child(wave, true)
	
	assert(_curr_wave.connect("spawn_enemy", self, "_attach_cat") == 0)
	assert(_curr_wave.connect("spawning_ended", self, "_on_spawn_end") == 0)

## Spawn the cat
func _attach_cat(cat):
	var path_idx = randi() % _cats_pathes.size()
	_cats_pathes[path_idx].add_child(cat, true)

## Manage the wave end; start the countdown for a new one
func _on_spawn_end():
	_curr_wave.queue_free()
	_waves_timer.start()


