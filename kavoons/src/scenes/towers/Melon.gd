extends Area2D

class_name Melon

var _enemies_in_range: Array = []

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

var armor_reduction_flat: int

var resistance_reduction_percentage: float

var target_priority  # from global enum TARGET_PRIORITY

var last_hit_counter: int = 0

var _range: int = 1
#onready var base_sprite := $BaseSprite

#var passive_abilities: Array = []
#var active_abilities: Array = []

var _upgr_bar_offset = Vector2(-85, -130)


func _init():
	pass

func _ready():
	$Range/CollisionShape2D.scale = Vector2(_range, _range)
	$Upgrader/UI/HUD.rect_position = position + _upgr_bar_offset
	$Upgrader/UI/FocusRegion.position = position + _upgr_bar_offset

func _process(delta):
	pass

func _physics_process(delta):
	rotate_to()

func set_sprite():
	pass

func rotate_to():
	if _enemies_in_range.size() > 0:
		var enemy_position = _enemies_in_range[0].get_global_transform().origin
		$BaseSprite.look_at(enemy_position)

func perform_base_attack():
	pass

func perform_active_ability():
	pass

func sell():
	pass

func level_up():
	pass


func _on_Range_area_entered(area):
	var node = area.get_parent()
	if node.is_in_group("enemies"):
		_enemies_in_range.append(node)
	print(_enemies_in_range)


func _on_Range_area_exited(area):
	var node = area.get_parent()
	if node.is_in_group("enemies"):
		_enemies_in_range.erase(node)
	print(_enemies_in_range)
