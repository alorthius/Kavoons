extends PathFollow2D

## An interface for a cat
## 
## Describe the cat object following a prediscribed path.
class_name Cat

export(String) var base_name

## The number of lifes to remove if cat successfully reaches the path end
var _lifes_cost: int

## AMount of money the player earns on cats death
var _money_reward: int

var _hp: int

onready var _ui = $UI/Pos/OnClick
onready var _ui_pos = $UI/Pos

onready var _hp_bar = $UI/Pos/HP
onready var _curr_hp_ui = _ui.get_node("Stats/Left/HP/CurrHP")


onready var _tween: Tween = $Tween
var _hp_reduction_duration := 0.7

var _move_speed: int
var _physical_armor_flat: int
var _magical_resistance_percentage: float

onready var _sprite: Sprite = $Sprite
onready var _animation: AnimationPlayer = $AnimationPlayer

var _rotation_init := 270
var _rotation_final := 360
var _scale_init := 0.2 * Vector2.ONE
var _scale_final := Vector2.ONE
var _entrance_time := 0.5

onready var _hit_timer: Timer = $HitTimer
onready var _ui_timer: Timer = $UITimer

var _on_hit_color: Color = Color(0.8, 0.2, 0.2, 0.8)

## Attach the health bar to a cat and spawn it with a random vertical offset
func _ready():
	_parse_cat_data()
	_apply_cat_data()
	
	_hp_bar.max_value = _hp
	_hp_bar.value = _hp_bar.max_value
	_ui_pos.set_as_toplevel(true)

	v_offset = rand_range(-40, 0)
	
	_animation.play(base_name + "_walk")

## Move the cat on a path
func _physics_process(delta):
	set_offset(get_offset() + _move_speed * delta)
	
	if get_unit_offset() >= 1:  # reached the path end
		_reached_end()
	
	_ui_pos.set_position(position)

## Process the hit of the cat
func on_hit(dmg: int):
	_hit_timer.start()
	_sprite.set_modulate(_on_hit_color)
	_hp = _hp - dmg
	if _hp <= 0:
		_killed()
	_reduce_health()


func _reduce_health():
	_curr_hp_ui.text = str(_hp)
	
	assert(_tween.interpolate_property(_hp_bar, "value", _hp_bar.value, _hp, _hp_reduction_duration, Tween.TRANS_EXPO, Tween.EASE_OUT))
	assert(_tween.start())


func _on_HitTimer_timeout():
	_sprite.set_modulate(Color(1, 1, 1, 1))


func _killed():
#	_prep_to_free()
#	yield(_tween, "tween_all_completed")
	Events.emit_signal("update_money", _money_reward)
	_free()


func _reached_end():
	Events.emit_signal("update_lifes", - _lifes_cost)
	_free()


func _free():
	queue_free()


func _parse_cat_data():
	var data: Dictionary = Cats.cats[base_name]
	
	_lifes_cost = data["lifes_cost"]
	_hp = data["hp"]
	_money_reward = data["reward"]

	_move_speed = data["move_speed"]
	_physical_armor_flat = data["physical_armor_flat"]
	_magical_resistance_percentage = data["magical_resistance_percentage"]


func _apply_cat_data():
	_ui.get_node("Name").text = base_name
	
	var stats = _ui.get_node("Stats")
	var left = stats.get_node("Left")
	var right = stats.get_node("Right")
	
	left.get_node("HP/CurrHP").text = str(_hp)
	left.get_node("HP/MaxHP").text = str(_hp)
	
	left.get_node("LifesCost/Label").text = str(_lifes_cost)
	left.get_node("MoneyReward/Label").text = str(_money_reward)
	
	right.get_node("MoveSpeed/Label").text = str(_move_speed)
	right.get_node("PhysicalArmor/Label").text = str(_physical_armor_flat)
	right.get_node("MagicalResistance/Label").text = str(_magical_resistance_percentage)


func _on_AreaUI_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.pressed and event.button_index == BUTTON_LEFT:
		if not _ui.visible:
			_show_ui()
			_ui_timer.start()
		else:
			_hide_ui()

func _on_UITimer_timeout():
	_hide_ui()

func _show_ui():
	_ui.visible = true
	
	assert(_tween.interpolate_property(_ui, "rect_rotation", _rotation_init, _rotation_final, _entrance_time, Tween.TRANS_ELASTIC, Tween.EASE_OUT))
	assert(_tween.interpolate_property(_ui, "rect_scale", _scale_init, _scale_final, _entrance_time, Tween.TRANS_ELASTIC, Tween.EASE_OUT))
	assert(_tween.start())

func _hide_ui():
	assert(_tween.interpolate_property(_ui, "rect_rotation", _rotation_final, _rotation_init, _entrance_time, Tween.TRANS_ELASTIC, Tween.EASE_IN))
	assert(_tween.interpolate_property(_ui, "rect_scale", _scale_final, _scale_init, _entrance_time, Tween.TRANS_ELASTIC, Tween.EASE_IN))
	assert(_tween.start())
	
	yield(_tween, "tween_all_completed")
	_ui.visible = false

func _prep_to_free():
	if _ui.visible:
		_hide_ui()
	
	assert(_tween.interpolate_property(self, "scale", _scale_final, Vector2.ZERO, 0.5, Tween.TRANS_ELASTIC, Tween.EASE_IN))
	assert(_tween.start())
