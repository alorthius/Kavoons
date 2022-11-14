extends Node2D

var _cat = load("res://src/scenes/enemies/Cat1.tscn")
var _enemies_to_spawn: Array = [_cat, _cat, _cat]
var _time_between_spawns: Array = [0, 1, 3]

var _enemies_left: int = len(_enemies_to_spawn)

signal spawn_enemy(cat)

signal wave_ended()


func _ready():
	$CatsTimer.set_wait_time(_time_between_spawns.pop_front())
	$CatsTimer.start()


func _on_CatsTimer_timeout():
	var cat = _enemies_to_spawn.pop_front().instance()
	emit_signal("spawn_enemy", cat)
	_enemies_left -= 1
	if _enemies_left == 0:
		emit_signal("wave_ended")
		queue_free()
	else:
		$CatsTimer.set_wait_time(_time_between_spawns.pop_front())
		$CatsTimer.start()
