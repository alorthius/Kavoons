extends Node2D

## Provide the enemies spawning for one attack wave
class_name Wave

## Emit the cat instance should be spawned
signal spawn_enemy(cat, wave)
## Emit the current wave ended
signal spawning_ended(wave)

var _timers = []
var _dicts = []


func set_wave_info(info: Dictionary, num_pathes: int):
	for i in range(num_pathes):
		var dict = info["Path" + str(i + 1)]
		dict["enemies_left"] = len(dict["enemies"])
		
		var new_timer = Timer.new()
		_timers.append(new_timer)
		_dicts.append(dict)
		
		add_child(new_timer, true)
		
		assert(new_timer.connect("timeout", self, "_on_CatsTimer_timeout", [i]) == 0)
		
		new_timer.set_wait_time(_dicts[i]["spawns"].pop_front())

## Set timer to wait for the first cat
func _ready():
	for timer in _timers:
		timer.start()

## Spawn the first cat from the array and set the timer to wait for the next one
func _on_CatsTimer_timeout(idx):
	var cat = _dicts[idx]["enemies"].pop_front().instance()
	emit_signal("spawn_enemy", cat, idx)
	_dicts[idx]["enemies_left"] -= 1
	if _dicts[idx]["enemies_left"] == 0:
		_timers[idx].stop()
		_timers[idx].queue_free()
		
		var to_free = true
		for i in len(_timers):
			if _dicts[i]["enemies_left"] != 0:
				to_free = false
		if to_free:
			emit_signal("spawning_ended", self)
			queue_free()

	else:
		_timers[idx].set_wait_time(_dicts[idx]["spawns"].pop_front())
		_timers[idx].start()
