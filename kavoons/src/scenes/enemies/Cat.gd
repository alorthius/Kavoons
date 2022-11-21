extends PathFollow2D

class_name Cat

var hp: int
var lifes_cost: int

onready var hp_bar = $HP

var move_speed: int

var physical_armor_flat: int

var magical_resistance_percentage: float

var dodge_rate: float


func _ready():
	hp_bar.max_value = hp
	hp_bar.value = hp_bar.max_value
	v_offset = rand_range(-30, 10)


func _physics_process(delta):
	set_offset(get_offset() + move_speed * delta)
	
	if get_unit_offset() >= 1:  # reached the path end
		_reached_end()


func _reached_end():
	queue_free()


func on_hit(dmg: int):
	hp = max(0, hp - dmg)
	hp_bar.value = hp
	if hp == 0:
		print("Cat is DED")
		_reached_end()
