extends Area2D

class_name Melon

var _enemies_in_range: Array = []

var base_tower: String
var tier: String

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

var _range_scale: float = 1
var _range_alpha: float = 0.6

onready var next_A: PackedScene
onready var next_B: PackedScene

#onready var base_sprite := $BaseSprite

#var passive_abilities: Array = []
#var active_abilities: Array = []

onready var melon_sprite: Sprite = $BaseSprite

onready var range_shape: CollisionShape2D = $Range/CollisionShape
onready var range_sprite: Sprite = $BaseRange

onready var base_attack_timer: Timer = $BaseAttackTimer
var _ready_to_attack: bool = false

var curr_enemy: Cat

signal replace_tower(old_tower, new_tower)


func _init():
	pass

func _ready():
	_parse_tower_data()
	base_attack_timer.start()

func _process(delta):
	pass

func _physics_process(delta):
	_select_enemy()
	_rotate_to()
	_perform_base_attack()

func _select_enemy():
	# TODO: add different targetings
	if not _enemies_in_range.empty():
		curr_enemy = _enemies_in_range[0]
	else:
		curr_enemy = null

func _rotate_to():
	if curr_enemy != null:
		melon_sprite.look_at(curr_enemy.get_global_transform().origin)

func _perform_base_attack():
	if curr_enemy != null and _ready_to_attack:
		print("Shoot!")
		curr_enemy.on_hit(base_attack_damage)
		_ready_to_attack = false
		base_attack_timer.start()

func perform_active_ability():
	pass

func sell():
	pass

func _parse_tower_data():
	var data: Dictionary = Towers.towers_data[base_tower][tier]
	melon_sprite.texture = load(data["sprite"])
	_range_scale = data["range_scale"]
	
	range_shape.scale = Vector2(_range_scale, _range_scale)
	range_sprite.scale = Vector2(_range_scale * 0.55, _range_scale * 0.55)  # bad sprite size, draw better later
	range_sprite.modulate.a = _range_alpha
	
	base_attack_timer.wait_time = 1.0 / data["attack_speed"]
	base_attack_damage = data["base_attack_damage"]
	

func _upgrade(upgrade: String):
	if upgrade == "Left":
		emit_signal("replace_tower", self, next_A.instance())
	elif upgrade == "Right":
		emit_signal("replace_tower", self, next_B.instance())


func _on_Range_area_entered(area):
	var node = area.get_parent()
	if node.is_in_group("enemies"):
		_enemies_in_range.append(node)


func _on_Range_area_exited(area):
	var node = area.get_parent()
	if node.is_in_group("enemies"):
		_enemies_in_range.erase(node)


func _display_range(to_show):
	range_sprite.visible = to_show


func _on_BaseAttackTimer_timeout():
	_ready_to_attack = true
