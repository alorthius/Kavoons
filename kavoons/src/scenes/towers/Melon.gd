extends Node2D

class_name Melon


var tier_num: int

var buy_cost: int
var sell_cost: int

var attack_type
var attack_damage: int

var armor_

var attack_speed: float
var projectile_speed: float
var miss_rate: float

var crit_rate: float
var crit_damage_multiplier: int

var last_hit_counter: int = 0

onready var sprite := $MelonSprite


func _physics_process(_delta):
	rotate_to()

func rotate_to():
	var enemy_position = get_global_mouse_position()
	sprite.look_at(enemy_position)

func level_up():
	pass

func sell():
	pass

