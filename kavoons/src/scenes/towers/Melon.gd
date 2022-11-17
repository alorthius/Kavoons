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

var _range_scale: float = 1
var _range_alpha: float = 0.6

#onready var base_sprite := $BaseSprite

#var passive_abilities: Array = []
#var active_abilities: Array = []

var _upgr_bar_offset = Vector2(-85, -130)

onready var melon_sprite: Sprite = $BaseSprite

onready var range_shape: CollisionShape2D = $Range/CollisionShape
onready var range_sprite: Sprite = $BaseRange

onready var upgrade_ui: Control = $Upgrader/UI/HUD
onready var upgrade_focus: StaticBody2D = $FocusRegion

func _init():
	pass

func _ready():
	range_shape.scale = Vector2(_range_scale, _range_scale)
	range_sprite.scale = Vector2(_range_scale * 0.55, _range_scale * 0.55)  # bad sprite size, draw better later
	range_sprite.modulate.a = _range_alpha
	range_sprite.visible = false

	upgrade_ui.rect_position = position + _upgr_bar_offset
	upgrade_ui.visible = false
	
	upgrade_focus.position += _upgr_bar_offset

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

func level_up():
	pass


func _on_Range_area_entered(area):
	var node = area.get_parent()
	if node.is_in_group("enemies"):
		_enemies_in_range.append(node)


func _on_Range_area_exited(area):
	var node = area.get_parent()
	if node.is_in_group("enemies"):
		_enemies_in_range.erase(node)


func _on_FocusRegion_mouse_entered():
	range_sprite.set_visible(true)
	upgrade_ui.set_visible(true)


func _on_FocusRegion_mouse_exited():
	range_sprite.set_visible(false)
	upgrade_ui.set_visible(false)
