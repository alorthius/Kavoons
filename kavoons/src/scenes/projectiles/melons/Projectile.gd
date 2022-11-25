extends Area2D

class_name Projectile

var _speed: float
var _dmg: int
var _miss_rate: float
onready var _target: Cat
onready var _target_area: Area2D = _target.get_node("Area2D")

func _ready():
	set_as_toplevel(true)  # move independent from parent node
	set_scale(Vector2(3.5, 3.5))

func _set_properties(speed: float, damage: int, miss_rate: float, target: Cat):
	_speed = speed
	_dmg = damage
	_miss_rate = miss_rate
	_target = target

func _physics_process(delta):
	var delta_angle: float = get_angle_to(_target.position)
	rotate(delta_angle)
	global_position += (_target.position - position).normalized() * _speed * delta
	
#	if overlaps_area(_target_area):
#		_target.on_hit(_dmg)
#		queue_free()

func _on_Projectile_area_entered(area):
	if area == _target_area:
		_target.on_hit(_dmg)
		queue_free()
