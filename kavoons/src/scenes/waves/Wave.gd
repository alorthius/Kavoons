extends Node2D

var _cat = load("res://src/scenes/enemies/Cat1.tscn")
var _enemies_to_spawn: Array = [_cat, _cat, _cat]
var _time_between_spawns: Array = [1, 2, 3]

var _enemies_left: int = len(_enemies_to_spawn)

onready var _timer: Timer = $CatsTimer

signal spawn_enemy(cat)

signal spawning_ended()


func _ready():
	_timer.set_wait_time(_time_between_spawns.pop_front())
	_timer.start()


func _on_CatsTimer_timeout():
	var cat = _enemies_to_spawn.pop_front().instance()
	emit_signal("spawn_enemy", cat)
	_enemies_left -= 1
	if _enemies_left == 0:
		emit_signal("spawning_ended")
		_timer.stop()
		queue_free()
	else:
		_timer.set_wait_time(_time_between_spawns.pop_front())
		_timer.start()
