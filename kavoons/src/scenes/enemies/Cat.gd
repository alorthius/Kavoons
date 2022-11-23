extends PathFollow2D

class_name Cat

var lifes_cost: int

var _hp: int
onready var _hp_bar = $HP

var _move_speed: int
var _physical_armor_flat: int
var _magical_resistance_percentage: float

var _dodge_rate: float


func _ready():
	_hp_bar.max_value = _hp
	_hp_bar.value = _hp_bar.max_value
	_hp_bar.set_as_toplevel(true)

	v_offset = rand_range(-30, 10)


func _physics_process(delta):
	set_offset(get_offset() + _move_speed * delta)
	
	if get_unit_offset() >= 1:  # reached the path end
		_reached_end()
	
	_hp_bar.set_position(position - Vector2(25, 40))


func _reached_end():
	queue_free()


func on_hit(dmg: int):
	_hp = _hp - dmg
	if _hp <= 0:
		_reached_end()
	_hp_bar.value = _hp
