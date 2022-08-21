extends Node2D

class_name Melon


var tier_num: int

var buy_cost: int
var sell_cost: int

var base_attack_radius: int
var base_attack_type  # from global enum DAMAGE_TYPES
var base_attack_damage: int

var attack_speed: float
var projectile_speed: float
var miss_rate: float

var crit_rate: float
var crit_strike_multiplier: int

var armor_reduction_percentage: float
var armor_reduction_flat: int

var resistence_reduction_percentage: float
var resistence_reduction_flat: int

var target_priority  # from global enum TARGET_PRIORITY

var last_hit_counter: int = 0

#var passive_abilities: Array = []
var active_abilities: Array = []

onready var sprite := $MelonSprite


func _init():
  pass

func _ready():
  pass

func _process(delta):
  pass

func _physics_process(delta):
	rotate_to()

func rotate_to():
	var enemy_position = get_global_mouse_position()
	sprite.look_at(enemy_position)

func perform_base_attack():
	pass

func perform_active_ability():
	pass

func level_up():
	pass

func sell():
	pass

