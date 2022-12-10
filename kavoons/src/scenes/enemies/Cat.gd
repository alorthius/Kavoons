extends PathFollow2D

## An interface for a cat
## 
## Describe the cat object following a prediscribed path.
class_name Cat

export(String) var base_name

## The number of lifes to remove if cat successfully reaches the path end
var _lifes_cost: int

var _hp: int
onready var _hp_bar = $HP

var _move_speed: int
var _physical_armor_flat: int
var _magical_resistance_percentage: float

onready var _sprite: Sprite = $Sprite
onready var _hit_timer: Timer = $HitTimer

var _on_hit_color: Color = Color(0.8, 0.2, 0.2, 0.8)

## Attach the health bar to a cat and spawn it with a random vertical offset
func _ready():
	_parse_cat_data()
	
	_hp_bar.max_value = _hp
	_hp_bar.value = _hp_bar.max_value
	_hp_bar.set_as_toplevel(true)

	v_offset = rand_range(-40, 0)

## Move the cat on a path
func _physics_process(delta):
	set_offset(get_offset() + _move_speed * delta)
	
	if get_unit_offset() >= 1:  # reached the path end
		_reached_end()
	
	_hp_bar.set_position(position - Vector2(25, 40))

## Destroy the cat on reach of the path end
func _reached_end():
	Events.emit_signal("update_lifes", - _lifes_cost)
	queue_free()

## Process the hit of the cat
func on_hit(dmg: int):
	_hit_timer.start()
	_sprite.set_modulate(_on_hit_color)
	_hp = _hp - dmg
	if _hp <= 0:
		_reached_end()
	_hp_bar.value = _hp

func _on_HitTimer_timeout():
	_sprite.set_modulate(Color(1, 1, 1, 1))

func _parse_cat_data():
	var data: Dictionary = Cats.cats[base_name]
	
	_lifes_cost = data["lifes_cost"]
	_hp = data["hp"]

	_move_speed = data["move_speed"]
	_physical_armor_flat = data["physical_armor_flat"]
	_magical_resistance_percentage = data["magical_resistance_percentage"]
