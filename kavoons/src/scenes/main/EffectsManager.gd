extends Node

var damage_popup: Resource = preload("res://src/scenes/effects/Damage.tscn")


func _ready():
	Events.connect("show_damage_dealt", self, "_spawn_damage_popup")

func _spawn_damage_popup(position: Vector2, damage: int):
	var popup = damage_popup.instance()
	var display_text: String
	if damage == 0:
		display_text = "miss"
	else:
		display_text = String(damage)
	
	popup._label.text = display_text
