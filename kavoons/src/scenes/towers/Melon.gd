extends Area2D

## An interface for a tower
## 
## Store all the tower properties. Manage the enemies targeting and aim.
## Define the tower attack range and track the enemies enterred it. Hit the enemies.
class_name Melon

## Array of all the enemies enterred the attack range of a tower
var _enemies_in_range: Array = []

## Name of the tower type
var base_tower: String
## Tier number
var tier: String
## Branch number
var branch: String


var sell_cost: int

var _base_attack_radius: int
var _base_attack_type  # from global enum DAMAGE_TYPES
var _base_attack_damage: int

var _attack_speed: float
var _projectile_speed: float
var _miss_rate: float

var _crit_rate: float
var _crit_strike_multiplier: int

var _armor_reduction_flat: int
var _resistance_reduction_percentage: float

var _target_priority: int = Constants.TARGET_PRIORITY.FIRST

var last_hit_counter: int = 0

var _range_scale: float = 1


onready var _melon_sprite: Sprite = $BaseSprite

var _color: Color
onready var _range_shape: CollisionShape2D = $Range/CollisionShape
onready var _range_sprite: Sprite = $BaseRange

## Is the reload of a melon basic attack finished
var _ready_to_attack: bool = false
onready var projectile: PackedScene

## Timer to track the cool-down of a basic attacks
onready var _base_attack_timer: Timer = $BaseAttackTimer

## Single enemy the tower currently attacks
var _curr_enemy: Cat


## Fill all the tower data and begin the basick attacks reload
func _ready():
	_parse_tower_data()
	
	_range_sprite.scale = 2 * _base_attack_radius * Vector2(1, 1) / _range_sprite.texture.get_size()
	_range_sprite.modulate = _color
	_range_shape.shape.radius = _base_attack_radius
	
	_base_attack_timer.start()
	display_range(false)

func _get_tower_dict():
	var map: Dictionary
	if tier == "T1":
		map = Towers.T1_towers
	elif tier == "T2":
		map = Towers.T2_towers
	elif tier == "T3":
		map = Towers.T3_towers
	
	return map[base_tower][branch]

## Parse all the current melon data stored in a global dictionary
func _parse_tower_data():
	var data: Dictionary = _get_tower_dict()

	_melon_sprite.texture = load(data["sprite"])
	
	# TODO: base attack radius instead of scale
	_base_attack_radius = data["base_attack_radius"]
	_base_attack_type = data["base_attack_type"]
	_base_attack_damage = data["base_attack_damage"]
	
	_base_attack_timer.wait_time = 1.0 / data["attack_speed"]
	_projectile_speed = data["projectile_speed"]
	_miss_rate = data["miss_rate"]
	
	_crit_rate = data["crit_rate"]
	_crit_strike_multiplier = data["crit_strike_multiplier"]
	_armor_reduction_flat = data["armor_reduction_flat"]
	_resistance_reduction_percentage = data["resistance_reduction_percentage"]
	
	_color = data["color"]

func _physics_process(_delta):
	_select_enemy()
	_rotate_to()
	_perform_base_attack()

## Choose one single enemy out of all in tower range to attack with different targetings
## from global enum Constants.TARGET_PRIORITY:
## - FIRST - the first enemy entered melon vision
## - LAST - the last enemy entered melon vision
## - HIGHEST_LIFECOST - the enemy with the highest life cost
## - HIGHEST_ARMOR - the enemy with the highest physical armor
## - HIGHEST_RESISTENCE - the enemy with the highest magic resistance
## - LEAST_HP - the enemy with the least amount of current hp
## - CLOSEST - the enemy closest to the path ending
func _select_enemy():
	if _enemies_in_range.empty():
		_curr_enemy = null
		return

	var chosen_enemy: Cat
	
	if _target_priority == Constants.TARGET_PRIORITY.FIRST:
		chosen_enemy = _enemies_in_range[0]
	
	elif _target_priority == Constants.TARGET_PRIORITY.LAST:
		chosen_enemy = _enemies_in_range[-1]
	
	elif _target_priority == Constants.TARGET_PRIORITY.HIGHEST_LIFECOST:
		var max_lifecost := - INF
		for enemy in _enemies_in_range:
			if enemy._life_cost > max_lifecost:
				chosen_enemy = enemy
				max_lifecost = enemy._life_cost
				
	elif _target_priority == Constants.TARGET_PRIORITY.HIGHEST_ARMOR:
		var max_armor := - INF
		for enemy in _enemies_in_range:
			if enemy._physical_armor_flat > max_armor:
				chosen_enemy = enemy
				max_armor = enemy._physical_armor_flat
	
	elif _target_priority == Constants.TARGET_PRIORITY.HIGHEST_RESISTENCE:
		var max_resist := - INF
		for enemy in _enemies_in_range:
			if enemy._magical_resistance_percentage > max_resist:
				chosen_enemy = enemy
				max_resist = enemy._magical_resistance_percentage

	elif _target_priority == Constants.TARGET_PRIORITY.LEAST_HP:
		var min_hp := INF
		for enemy in _enemies_in_range:
			if enemy._hp < min_hp:
				chosen_enemy = enemy
				min_hp = enemy._hp

	elif _target_priority == Constants.TARGET_PRIORITY.CLOSEST:
		var max_passed := - INF
		for enemy in _enemies_in_range:
			if enemy.unit_offset > max_passed:
				chosen_enemy = enemy
				max_passed = enemy.unit_offset
	
	_curr_enemy = chosen_enemy

## Rotate the tower sprite to the position of a currently selected enemy
func _rotate_to():
	if _curr_enemy != null:
		_melon_sprite.look_at(_curr_enemy.get_global_transform().origin)

## Hit the curently selected enemy with a basic attack
func _perform_base_attack():
	if _curr_enemy != null and _ready_to_attack:
		var new_projectile: Projectile = projectile.instance()
		new_projectile._set_properties(_projectile_speed, _base_attack_damage, _miss_rate, _curr_enemy)
		new_projectile.position = position
		add_child(new_projectile)

		_ready_to_attack = false
		_base_attack_timer.start()

func _perform_active_ability():
	pass

## Save the enemy entered the tower range
func _on_Range_area_entered(area):
	var node = area.get_parent()
	if node.is_in_group("enemies"):
		_enemies_in_range.append(node)

## Delete the enemy exited the tower range
func _on_Range_area_exited(area):
	var node = area.get_parent()
	if node.is_in_group("enemies"):
		_enemies_in_range.erase(node)

## Set the visibility of a tower range sprite
func display_range(to_show):
	_range_sprite.visible = to_show

## Finish basic attack reload and make tower ready to shoot
func _on_BaseAttackTimer_timeout():
	_ready_to_attack = true
