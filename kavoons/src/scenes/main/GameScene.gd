extends Node2D

var _upgrader = preload("res://src/scenes/UI/Upgrader.tscn")
var _upgr_bar_offset = Vector2(-85, -130)

onready var builder: Builder = $Builder
onready var waves_timer: Timer = $WavesTimer
onready var towers_container: Node = $Towers
onready var cats_container: Path2D = $Map/Path2D

var curr_wave

var _signal_err: int = 0

func _ready():
	_signal_err = builder.connect("tower_placed", self, "_attach_melon")
	if _signal_err != 0: print("GameScene: _ready: connect: ", _signal_err)
	waves_timer.start()


func _attach_melon(new_tower: Melon):
	towers_container.add_child(new_tower, true)
	
	var new_upgrader = _upgrader.instance()

	var buttons_bar = new_upgrader.get_node("UI/HUD")
	buttons_bar.rect_position = new_tower.position + _upgr_bar_offset
	new_tower.add_child(new_upgrader, true)
	
	new_upgrader.fill_icons(Towers.towers_data[new_tower.base_tower][new_tower.tier]["next"])
	
	_signal_err = new_upgrader.connect("set_range_visibility", new_tower, "_display_range")
	if _signal_err != 0: print("GameScene: _attach_melon: connect: set_range_visibility: ")
		
	if not new_upgrader.is_last_upgr:
		for butt in buttons_bar.get_node("UpgradeBar").get_children():
			_signal_err = butt.connect("pressed", new_tower, "_upgrade", [butt.name])
			if _signal_err != 0: print("GameScene: _attach_melon: connect: pressed: ")
	
		_signal_err = new_tower.connect("replace_tower", self, "_replace_tower")
		if _signal_err != 0: print("GameScene: _attach_melon: connect: replace_tower: ")
	else:
		new_upgrader.get_node("UI/HUD/UpgradeBar").visible = false
	

func _replace_tower(old_tower: Melon, new_tower: Melon):
	new_tower.position = old_tower.position
	_attach_melon(new_tower)
	old_tower.queue_free()


func _on_WavesTimer_timeout():
	var _wave = load("res://src/scenes/waves/Wave.tscn").instance()
	curr_wave = _wave
	add_child(_wave, true)
	
	_signal_err = curr_wave.connect("spawn_enemy", self, "_on_cat_spawn")
	if _signal_err != 0: print("GameScene: _on_WavesTimer_timeout: connect: spawn_enemy: ", _signal_err)
	
	_signal_err = curr_wave.connect("spawning_ended", self, "_on_spawn_end")
	if _signal_err != 0: print("GameScene: _on_WavesTimer_timeout: connect: spawning_ended: ", _signal_err)


func _on_cat_spawn(cat):
	cats_container.add_child(cat, true)


func _on_spawn_end():
	print("SPAWN ENDED")
	curr_wave.queue_free()
	waves_timer.start()
