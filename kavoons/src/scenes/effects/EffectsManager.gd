extends Node

var damage_popup: Resource = preload("res://src/scenes/effects/FloatingText.tscn")


func _ready():
	assert(Events.connect("show_damage_dealt", self, "_spawn_damage_popup") == 0)


func _spawn_damage_popup(position: Vector2, damage: int, damage_type: int, is_crit: bool):
	var popup = damage_popup.instance()
	add_child(popup, true)
	
	popup.position = position

	var display_text: String
	var color: Color

	if damage == 0:
		display_text = "miss"
		color = Color(1, 1, 1, 1)
	else:
		display_text = String(damage)
		if damage_type == Constants.DamageTypes.PHYSICAL:
			color = Color(1, 0.6, 0.5)
		elif damage_type == Constants.DamageTypes.MAGICAL:
			color = Color(0, 0.7, 1)
		elif damage_type == Constants.DamageTypes.PURE:
			color = Color(0.8, 0.7, 1)
	
	if is_crit:
		popup.set_scale_pair(Vector2(1, 1), Vector2(1.5, 1.5))
		color = Color(1, 0.4, 0.4)
		
	popup.set_label(display_text)
	popup.set_color(color)
	
	popup.animate()
