extends Node2D

## Provide the single playable map interface and logic
## 
## Create the playable map, connect all the game logical parts and instances.
## A parent for all the map itself, UI, economy and life systems, enemy waves, and towers.

onready var _map = $Map

onready var _curr_wave_label = $UI/Wave/CurrWave
onready var _total_waves_label = $UI/Wave/TotalWaves

onready var _wave_scene = preload("res://src/scenes/waves/Wave.tscn")

onready var _starters_positions = $Map/Starters.get_children()
onready var _starter_butt = preload("res://src/scenes/UI/utility/butts/WaveStarter.tscn")

onready var _prestart_timer = $WavePrestart

## The only [Builder] instance responsible to build and create new towers
onready var _builder: Builder = $UI/Builder

onready var _measures = $UI/MeasuresManager

onready var _starters_container: Node = $Starters
## Container with all the placed towers
onready var _towers_container: Node = $Towers
## Container with all the spawned cats
onready var _cats_pathes: Array = $Map/Pathes.get_children()


var _wave_idx: int = 0
var _active_waves := []

## The preloaded [MelonManager] for the towers, is instanced for every new melon separately.
## Contains the melon itself as a child node and provides the UI to manage it.

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
	
	_create_starters(false)

func _create_starters(prestart=true):
	for i in range(len(_starters_positions)):
		var butt = _starter_butt.instance()
		butt.rect_position = _starters_positions[i].position
		_starters_container.add_child(butt)
		butt.set_enemies_label(_map.waves[_wave_idx + 1]["Path" + str(i + 1)]["label"])
		if prestart:
			butt.set_prestart(_map.waves[_wave_idx]["prestart_enable"], _map.waves[_wave_idx]["prestart_reward"])
		else:
			butt.set_prestart(0, 0)
		assert(butt.connect("start_wave", self, "_start_wave") == 0)


## Wrap the newly created melon with the new [Upgrader] instance.
func _attach_melon(new_tower: Melon):	
	_towers_container.add_child(new_tower, true)
	
	assert(new_tower.connect("tower_upgraded", self, "_attach_melon") == 0)
	assert(_measures._economics.connect("total_money_changed", new_tower._ui, "_validate_price") == 0)
	
	# forces melons to validate cost of upgrades according to current amount of money
	_measures._economics.emit_signal("total_money_changed", _measures._economics.money_total)  # shitcode

func _fade_all_starters():
	for butt in _starters_container.get_children():
		butt.fade_out()

func _start_wave():
	_fade_all_starters()
	
	_wave_idx += 1
	_curr_wave_label.text = str(_wave_idx)
	
	if _map.waves[_wave_idx]["prestart_enable"] > 0:
		_prestart_timer.wait_time = _map.waves[_wave_idx]["duration"] - _map.waves[_wave_idx]["prestart_enable"]
		_prestart_timer.start()
	
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

func _finish_game():
	var ded = load("res://src/scenes/UI/standalone/Ded.tscn").instance()
	add_child(ded)
	get_tree().paused = true

func _on_WavePrestart_timeout():
	_create_starters()
