extends Area2D

## An interface for a tower
## 
## Store all the tower properties. Manage the enemies targeting and aim.
## Define the tower attack range and track the enemies enterred it. Hit the enemies.
class_name Melon

## Array of all the enemies enterred the attack range of a tower
var _enemies_in_range: Array = []

## Name of the tower type
export(String) var base_tower
## Tier number
export(int) var tier
## Branch number
export(int) var branch


var total_money: int = 0

var _base_attack_radius: int
var _base_attack_type  # from global enum DamageTypes
var _base_attack_damage: int

var _attack_speed: float
var _projectile_speed: float
var _miss_rate: float

var _crit_rate: float
var _crit_strike_multiplier: float
var _is_crit: bool = false

var _armor_reduction_flat: int
var _resistance_reduction_percentage: float

var _target_priority: int = Constants.TargetPriority.FIRST

#var last_hit_counter: int = 0


onready var _melon_sprite: Sprite = $BaseSprite
onready var _ui: CanvasLayer = $UI

var _color: Color
onready var _range_shape: CollisionShape2D = $Range/CollisionShape

## Is the reload of a melon basic attack finished
var _ready_to_attack: bool = false
var _projectile: Resource

## Timer to track the cool-down of a basic attacks
onready var _base_attack_timer: Timer = $BaseAttackTimer

## Single enemy the tower currently attacks
var _curr_enemy: Cat


## Fill all the tower data and preprocess melon fields
func _ready():
	_parse_tower_data()
	
	_range_shape.shape.radius = _base_attack_radius  # the shape should always be a Circle
	
	_base_attack_timer.wait_time = 1.0 / _attack_speed
	_base_attack_timer.start()
	
	_ui.offset = position
	_ui.set_upgrades(Towers.get_tower_dict(tier, base_tower, branch), _base_attack_radius, _color, int(0.7 * total_money), _target_priority)

## Parse all the current melon data stored in a global dictionary
func _parse_tower_data():
	var data: Dictionary = Towers.get_tower_dict(tier, base_tower, branch)

	_melon_sprite.texture = load(data["sprite"])
	_projectile = load(data["projectile"])
	
	_base_attack_radius = data["base_attack_radius"]
	_base_attack_type = data["base_attack_type"]
	_base_attack_damage = data["base_attack_damage"]
	
	_attack_speed = data["attack_speed"]
	
	_projectile_speed = data["projectile_speed"]
	_miss_rate = data["miss_rate"]
	
	_crit_rate = data["crit_rate"]
	_crit_strike_multiplier = data["crit_strike_multiplier"]
	_armor_reduction_flat = data["armor_reduction_flat"]
	_resistance_reduction_percentage = data["resistance_reduction_percentage"]
	
	_color = data["color"]
	
	total_money += data["cost"]

func _physics_process(_delta):
	_clear_invalid_enemies()
	_select_enemy()
	_rotate_to()
	_perform_base_attack()

## Choose one single enemy out of all in tower range to attack with different targetings
## from global enum Constants.TargetPriority:
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
	
	if _target_priority == Constants.TargetPriority.FIRST:
		chosen_enemy = _enemies_in_range[0]
	
	elif _target_priority == Constants.TargetPriority.LAST:
		chosen_enemy = _enemies_in_range[-1]
	
	elif _target_priority == Constants.TargetPriority.HIGHEST_LIFECOST:
		var max_lifecost := - INF
		for enemy in _enemies_in_range:
			if enemy._lifes_cost > max_lifecost:
				chosen_enemy = enemy
				max_lifecost = enemy._lifes_cost
				
	elif _target_priority == Constants.TargetPriority.HIGHEST_ARMOR:
		var max_armor := - INF
		for enemy in _enemies_in_range:
			if enemy._physical_armor_flat > max_armor:
				chosen_enemy = enemy
				max_armor = enemy._physical_armor_flat
	
	elif _target_priority == Constants.TargetPriority.HIGHEST_RESISTENCE:
		var max_resist := - INF
		for enemy in _enemies_in_range:
			if enemy._magical_resistance_percentage > max_resist:
				chosen_enemy = enemy
				max_resist = enemy._magical_resistance_percentage

	elif _target_priority == Constants.TargetPriority.LEAST_HP:
		var min_hp := INF
		for enemy in _enemies_in_range:
			if enemy._hp < min_hp:
				chosen_enemy = enemy
				min_hp = enemy._hp

	elif _target_priority == Constants.TargetPriority.CLOSEST:
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

func _clear_invalid_enemies():
	for enemy in _enemies_in_range:
		if not is_instance_valid(_curr_enemy):
			_enemies_in_range.erase(_curr_enemy)

func _is_miss():
	if rand_range(0, 1) < _miss_rate:
		return true
	return false

func _calculate_damage():
	var damage: float
	if is_instance_valid(_curr_enemy):
		if _base_attack_type == Constants.DamageTypes.PHYSICAL:
			damage = _base_attack_damage - (_curr_enemy._physical_armor_flat - _armor_reduction_flat)
		elif _base_attack_type == Constants.DamageTypes.MAGICAL:
			damage = _base_attack_damage * (1 - _curr_enemy._magical_resistance_percentage + _resistance_reduction_percentage)
		elif _base_attack_type == Constants.DamageTypes.PURE:
			damage = _base_attack_damage
	
	if rand_range(0, 1) < _crit_rate:
		damage *= _crit_strike_multiplier
		_is_crit = true

	return int(damage)

## Hit the curently selected enemy with a basic attack
func _perform_base_attack():
	if is_instance_valid(_curr_enemy) and _ready_to_attack:
		var damage = 0
		if not _is_miss():
			damage = _calculate_damage()
		
		var new_projectile: Projectile = _projectile.instance()
		new_projectile._set_properties(_projectile_speed, damage, _base_attack_type, _is_crit, _curr_enemy)
		new_projectile.position = position
		add_child(new_projectile)

		_ready_to_attack = false
		_is_crit = false
		_base_attack_timer.start()

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

## Finish basic attack reload and make tower ready to shoot
func _on_BaseAttackTimer_timeout():
	_ready_to_attack = true
