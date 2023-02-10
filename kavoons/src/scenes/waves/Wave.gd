extends Node2D

## Provide the enemies spawning for one attack wave
class_name Wave

# TODO: set the arrays via method

var _cat_1 = load("res://src/scenes/enemies/Cat1.tscn")
var _cat_2 = load("res://src/scenes/enemies/Cat2.tscn")
var _cat_3 = load("res://src/scenes/enemies/Cat3.tscn")

## Array with all the enemies expected to be spawn during current wave
var _enemies_to_spawn: Array = [_cat_3, _cat_1, _cat_2]
## Array with time to wait before the enemy was spawn, e.g.
## the first entry defines the time to wait before the first enemy spawn
var _time_between_spawns: Array = [1, 2, 3]

## Enemies left to spawn during the current wave
var _enemies_left: int = len(_enemies_to_spawn)

onready var _timer: Timer = $CatsTimer

## Emit the cat instance should be spawned
signal spawn_enemy(cat)
## Emit the current wave ended
signal spawning_ended()

## Set timer to wait for the first cat
func _ready():
	_timer.set_wait_time(_time_between_spawns.pop_front())
	_timer.start()

## Spawn the first cat from the array and set the timer to wait for the next one
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
