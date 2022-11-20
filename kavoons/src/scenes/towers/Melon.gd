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

signal replace_tower(old_tower, new_tower)


func _init():
	pass

func _ready():
	pass

func _process(delta):
	pass

func _physics_process(delta):
	rotate_to()

func set_sprite():
	pass

func rotate_to():
	if _enemies_in_range.size() > 0:
		var enemy_position = _enemies_in_range[0].get_global_transform().origin
		melon_sprite.look_at(enemy_position)

func perform_base_attack():
	pass

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
	range_sprite.visible = false
	

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
