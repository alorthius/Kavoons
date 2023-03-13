extends Node2D

## Provide the single playable map interface and logic
## 
## Create the playable map, connect all the game logical parts and instances.
## A parent for all the map itself, UI, economy and life systems, enemy waves, and towers.

var _map_folder: String
onready var _map = $Map
onready var _pathes = $Map/Pathes
onready var _starters = $Map/Starters.get_children()

onready var _curr_wave_label = $UI/Wave/CurrWave
onready var _total_waves_label = $UI/Wave/TotalWaves

onready var _wave_scene = preload("res://src/scenes/waves/Wave.tscn")


## The only [Builder] instance responsible to build and create new towers
onready var _builder: Builder = $UI/Builder

onready var _measures = $UI/MeasuresManager


## Container with all the placed towers
onready var _towers_container: Node = $Towers
## Container with all the spawned cats
onready var _cats_pathes: Array = $Map/Pathes.get_children()
## Spawns effects
#onready var _effects_manager: Node = $EffectsManager

var _wave_idx: int = 0
var _active_waves := []

## The preloaded [MelonManager] for the towers, is instanced for every new melon separately.
## Contains the melon itself as a child node and provides the UI to manage it.
var _melon_manager: PackedScene = preload("res://src/scenes/UI/interactive/MelonManager.tscn")
var _melon_manager_final: PackedScene = preload("res://src/scenes/UI/interactive/MelonManagerFinal.tscn")

var enemies = []

# TODO: MAKE IT WORK
func attach_map(map):
	pass
#	_map = map
	

func _ready():
	_total_waves_label.text = str(_map.waves.keys()[-1])
	_curr_wave_label.text = str(_wave_idx)
	
	_measures.set_init_money(666)
	_measures.set_init_lifes(100)

	assert(_builder.connect("tower_placed", self, "_attach_melon") == 0)
	assert(_measures._economics.connect("total_money_changed", _builder, "_validate_price") == 0)
	assert(_measures._lifes.connect("finish_game", self, "_finish_game") == 0)
	
	var i = 1
	for butt in _starters:
		butt.set_data(_map.waves[_wave_idx + 1]["Path" + str(i)]["label"])
		assert(butt.connect("start_wave", self, "_start_wave") == 0)
		i += 1


## Wrap the newly created melon with the new [Upgrader] instance.
func _attach_melon(new_tower: Melon):
	var _manager: PackedScene
	
	var data: Dictionary = Towers.get_tower_dict(new_tower.tier, new_tower.base_tower, new_tower.branch)
	if len(data["next"]) == 0:
		_manager = _melon_manager_final
	else:
		_manager = _melon_manager
	
	var new_manager: MelonManager = _manager.instance()
	_towers_container.add_child(new_manager, true)
	new_manager.attach_melon(new_tower)
	
	assert(_builder.connect("build_status", new_manager, "_toggle_build_status") == 0)
	assert(_measures._economics.connect("total_money_changed", new_manager, "_validate_price") == 0)

	assert(new_manager.connect("upgrade_to", self, "_attach_melon") == 0)
	
	# forces melons to validate cost of upgrades according to current amount of money
	_measures._economics.emit_signal("total_money_changed", _measures._economics.money_total)  # shitcode

func _fade_all_starters():
	for butt in _starters:
		butt.fade_out()
	for butt in _starters:
		yield(butt._tween, "tween_all_completed")

func _start_wave():
	_wave_idx += 1
	_curr_wave_label.text = str(_wave_idx)
	
	yield(_fade_all_starters(), "completed")
	for butt in _starters:
		butt.clear_data()
		butt.disabled = true
	
	var wave = _wave_scene.instance()
	wave.set_wave_info(_map.waves[_wave_idx], _cats_pathes.size())
	add_child(wave, true)
	
	assert(wave.connect("spawn_enemy", self, "_attach_cat") == 0)
	assert(wave.connect("spawning_ended", self, "_on_spawn_end") == 0)
	
	_active_waves.append(wave)


## Spawn the cat
func _attach_cat(cat, wave_idx):
#	var path_idx = randi() % _cats_pathes.size()
	_cats_pathes[wave_idx].add_child(cat, true)
	enemies.append(cat)
	cat.connect("cat_deleted", self, "_remove_cat")

func _remove_cat(cat):
	enemies.erase(cat)
	if enemies.empty() and _active_waves.empty():
		end_wave()

## Manage the end of spawning enemies for a wave
func _on_spawn_end(wave):
	_active_waves.erase(wave)
	wave.queue_free()

func end_wave():
	Events.emit_signal("update_money", _map.waves[_wave_idx]["reward"])
	
	if _wave_idx == _map.waves.keys()[-1]:
		var win_scene = load("res://src/scenes/UI/standalone/Win.tscn").instance()
		add_child(win_scene)
		get_tree().paused = true
		return

	var i = 1
	for butt in _starters:
		butt.disabled = false
		butt.set_data(_map.waves[_wave_idx + 1]["Path" + str(i)]["label"])
		i += 1

func _finish_game():
	var ded = load("res://src/scenes/UI/standalone/Ded.tscn").instance()
	add_child(ded)
	get_tree().paused = true
