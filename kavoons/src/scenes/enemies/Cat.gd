extends PathFollow2D

class_name Cat

var hp: int
var lifes_cost: int

var move_speed: int

var physical_armor_flat: int

var magical_resistance_percentage: float

var dodge_rate: float


func _ready():
	v_offset = rand_range(-30, 10)


func _physics_process(delta):
	set_offset(get_offset() + move_speed * delta)
	
	if get_unit_offset() >= 1:  # reached the end
		reached_end()


func reached_end():
	queue_free()
