extends Node2D

## Load the game

func _ready():
	var game_scene = load("res://src/scenes/main/GameScene.tscn").instance()
	add_child(game_scene)
