extends Node

var damage_popup: Resource = preload("res://src/scenes/effects/Damage.tscn")


func _ready():
	assert(Events.connect("show_damage_dealt", self, "_spawn_damage_popup") == 0)

func _spawn_damage_popup(position: Vector2, damage: int):
	var popup = damage_popup.instance()
	add_child(popup, true)
	
	popup.position = position

	var display_text: String
	if damage == 0:
		display_text = "miss"
	else:
		display_text = String(damage)
	popup.set_label(display_text)
