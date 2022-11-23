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

var buy_cost: int
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

var _target_priority  # from global enum TARGET_PRIORITY

var last_hit_counter: int = 0

var _range_scale: float = 1
var _range_alpha: float = 0.6

## The next possible tower upgrade. Children define it in the [method _init()] function
onready var next_A: PackedScene
## The next possible tower upgrade. Children define it in the [method _init()] function
onready var next_B: PackedScene

#var passive_abilities: Array = []
#var active_abilities: Array = []

onready var _melon_sprite: Sprite = $BaseSprite

onready var _range_shape: CollisionShape2D = $Range/CollisionShape
onready var _range_sprite: Sprite = $BaseRange

## Is the reload of a melon basic attack finished
var _ready_to_attack: bool = false
## Timer to track the cool-down of a basic attacks
onready var _base_attack_timer: Timer = $BaseAttackTimer

## Single enemy the tower currently attacks
var _curr_enemy: Cat

## Fill all the tower data and begin the basick attacks reload
func _ready():
	_parse_tower_data()
	_base_attack_timer.start()

func _physics_process(_delta):
	_select_enemy()
	_rotate_to()
	_perform_base_attack()

## Choose one single enemy out of all in tower range to attack
func _select_enemy():
	# TODO: add different targetings
	if not _enemies_in_range.empty():
		_curr_enemy = _enemies_in_range[0]
	else:
		_curr_enemy = null

## Rotate the tower sprite to the position of a currently selected enemy
func _rotate_to():
	if _curr_enemy != null:
		_melon_sprite.look_at(_curr_enemy.get_global_transform().origin)

## Hit the curently selected enemy with a basic attack
func _perform_base_attack():
	if _curr_enemy != null and _ready_to_attack:
		_curr_enemy.on_hit(_base_attack_damage)
		_ready_to_attack = false
		_base_attack_timer.start()

func _perform_active_ability():
	pass

## Parse all the current melon data stored in a global dictionary
func _parse_tower_data():
	var data: Dictionary = Towers.towers_data[base_tower][tier]
	_melon_sprite.texture = load(data["sprite"])
	_range_scale = data["range_scale"]
	
	_range_shape.scale = Vector2(_range_scale, _range_scale)
	_range_sprite.scale = Vector2(_range_scale * 0.55, _range_scale * 0.55)  # bad sprite size, draw better later
	_range_sprite.modulate.a = _range_alpha
	
	_base_attack_timer.wait_time = 1.0 / data["attack_speed"]
	_base_attack_damage = data["base_attack_damage"]

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
