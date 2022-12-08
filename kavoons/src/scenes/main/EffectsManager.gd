extends Node

var damage_popup: Resource = preload("res://src/scenes/effects/Damage.tscn")


func _ready():
	assert(Events.connect("show_damage_dealt", self, "_spawn_damage_popup") == 0)

func _spawn_damage_popup(position: Vector2, damage: int, damage_type: int):
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
		if damage_type == Constants.DAMAGE_TYPES.PHYSICAL:
			color = Color(1, 0.574219, 0.574219)
		elif damage_type == Constants.DAMAGE_TYPES.MAGICAL:
			color = Color(0, 0.7, 1)
		elif damage_type == Constants.DAMAGE_TYPES.PURE:
			color = Color(0.8, 0.7, 1)
		
	popup.set_label(display_text)
	popup.set_color(color)
