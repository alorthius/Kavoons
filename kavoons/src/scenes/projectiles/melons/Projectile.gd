extends Area2D

## Represent a shooting projectile of a melon
class_name Projectile

var _speed: float
var _dmg: int
var _is_miss: bool = false

onready var _target: Cat
onready var _target_area: Area2D = _target.get_node("Area2D")

func _ready():
	set_as_toplevel(true)  # move independent from parent node
	set_scale(Vector2(3.5, 3.5))

# TODO: add misses

func _set_properties(speed: float, damage: int, miss_rate: float, target: Cat):
	_speed = speed
	_dmg = damage
	_target = target

func _physics_process(delta):
	# follow the enemy's moving position
	rotate(get_angle_to(_target.position))
	global_position += (_target.position - position).normalized() * _speed * delta

func _on_Projectile_area_entered(area):
	if area == _target_area:
		_target.on_hit(_dmg)
		queue_free()
