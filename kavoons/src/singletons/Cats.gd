extends Node


# warning-ignore:unused_class_variable
var cats: Dictionary = {
	"Cat1": {
		"lifes_cost": 2,
		"hp": 70,
		"reward": 5,
		
		"move_speed": 100,
		"physical_armor_flat": 0,
		"magical_resistance_percentage": 0
	},
	
	"Cat2": {
		"lifes_cost": 1,
		"hp": 50,
		"reward": 3,
		
		"move_speed": 200,
		"physical_armor_flat": 0,
		"magical_resistance_percentage": 0
	},
	
	"Cat3": {
		"lifes_cost": 3,
		"hp": 100,
		"reward": 10,
		
		"move_speed": 50,
		"physical_armor_flat": 0,
		"magical_resistance_percentage": 0
	},
}

# Preload all the cats

# warning-ignore:unused_class_variable
var cat_1: PackedScene = preload("res://src/scenes/enemies/Cat1.tscn")
# warning-ignore:unused_class_variable
var cat_2: PackedScene = preload("res://src/scenes/enemies/Cat2.tscn")
# warning-ignore:unused_class_variable
var cat_3: PackedScene = preload("res://src/scenes/enemies/Cat3.tscn")
