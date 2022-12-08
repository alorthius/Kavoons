extends Area2D

## Represent a shooting projectile of a melon
class_name Projectile

var _speed: float
var _dmg: int

var _is_miss: bool
var _miss_position: Vector2

onready var _target: Cat
onready var _target_area: Area2D = _target.get_node("Area2D")
var _cached_target_position: Vector2


func _ready():
	set_as_toplevel(true)  # move independent from parent node
	set_scale(Vector2(3.5, 3.5))


func _set_properties(speed: float, damage: int, target: Cat):
	_speed = speed
	_dmg = damage
	_target = target
		
	if is_instance_valid(_target):
		_cached_target_position = _target.position
	
	if damage == 0:
		_set_miss(target.position)


func _set_miss(target_position: Vector2):
	_is_miss = true
	_miss_position = target_position + Vector2(randi() % 20, randi() % 20)


## Follow the enemy's moving position
func _physics_process(delta):
	var velocity: Vector2
	
	if _is_miss:
		velocity = (_miss_position - position).normalized() * _speed
	elif is_instance_valid(_target):
		_cached_target_position = _target.position
		velocity = (_target.position - position).normalized() * _speed
	else:
		_set_miss(_cached_target_position)

	rotation = velocity.angle()
	position += velocity * delta
	
	if _is_miss and (position - _miss_position).abs() <= Vector2(5, 5):
		_notify_and_free(0)


func _on_Projectile_area_entered(area):
	if area == _target_area:
		_target.on_hit(_dmg)
		_notify_and_free(_dmg)


func _notify_and_free(dmg: int):
	Events.emit_signal("show_damage_dealt", position + Vector2(36, -25), dmg)
	queue_free()
