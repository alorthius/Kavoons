extends Node2D

class_name Upgrader

onready var _melon: Melon = $Melon


func _ready():
	$UI/HUD.set_visible(false)
	_melon.connect("mouse_entered()", self, "on_hover")

func on_hover():
	print("!!!")
