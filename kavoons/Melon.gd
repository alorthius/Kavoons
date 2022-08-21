extends Node2D

class_name Melon


var buy_cost: int
var sell_cost: int

var attack_damage: int
var attack_speed: float
var crit_rate: float
var crit_multiplier: int

onready var sprite := get_node("Sprite")


func _init():
	set_sprite()

func _physics_process(_delta):
	rotate_to()

func set_sprite():
	pass

func rotate_to():
	var enemy_position = get_global_mouse_position()
	sprite.look_at(enemy_position)
