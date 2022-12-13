extends Node

# warning-ignore:unused_class_variable
var T3: Dictionary = {
	"NinjaMelon": {
		0: {
			"scene": "",
			"sprite": "res://assets/towers/ninja_melon/T4_LR.png",

			"color": Color(1, 0.9, 0),
			"next": [],
		},
		1: {
			"scene": "",
			"sprite": "res://assets/towers/ninja_melon/T4_RR.png",

			"color": Color(1, 0.4, 0.5),
			"next": [],
		},
		2: {
			"scene": "",
			"sprite": "res://assets/towers/ninja_melon/T4_LR.png",

			"color": Color(1, 0.9, 0),
			"next": [],
		},
		3: {
			"scene": "",
			"sprite": "res://assets/towers/ninja_melon/T4_RR.png",

			"color": Color(1, 0.4, 0.5),
			"next": [],
		},
	}
}

var T2: Dictionary = {
	"NinjaMelon": {

		0: {
			"scene": "res://src/scenes/towers/ninja_melon/NinjaT2-A.tscn",
			"projectile": "res://src/scenes/projectiles/melons/Kunai.tscn",
			"sprite": "res://assets/towers/ninja_melon/T3_LR.png",
			
			"cost": 150,
			
			"base_attack_radius": 350,
			"base_attack_type": Constants.DamageTypes.PHYSICAL,
			"base_attack_damage": 20,
			
			"attack_speed": 2.5,
			"projectile_speed": 500,
			"miss_rate": 0.3,
			
			"crit_rate": 0,
			"crit_strike_multiplier": 2,
			
			"armor_reduction_flat": 5,
			"resistance_reduction_percentage": 0,

			"color": Color(1, 0.9, 0),
			"next": [],
#			"next": [T3["NinjaMelon"][0], T3["NinjaMelon"][1]],
		},

		1: {
			"scene": "res://src/scenes/towers/ninja_melon/NinjaT2-B.tscn",
			"projectile": "res://src/scenes/projectiles/melons/Kunai.tscn",
			"sprite": "res://assets/towers/ninja_melon/T3_RR.png",
			
			"cost": 200,
			
			"base_attack_radius": 150,
			"base_attack_type": Constants.DamageTypes.PHYSICAL,
			"base_attack_damage": 50,
			
			"attack_speed": 1,
			"projectile_speed": 500,
			"miss_rate": 0,
			
			"crit_rate": 0.5,
			"crit_strike_multiplier": 2,
			
			"armor_reduction_flat": 5,
			"resistance_reduction_percentage": 0,

			"color": Color(1, 0.4, 0.5),
			"next": [],
#			"next": [T3["NinjaMelon"][2], T3["NinjaMelon"][3]],
		},
	}
}

# warning-ignore:unused_class_variable
var T1: Dictionary = {
	"NinjaMelon": {

		0: {
			"scene": "res://src/scenes/towers/ninja_melon/NinjaT1.tscn",
			"projectile": "res://src/scenes/projectiles/melons/Kunai.tscn",
			"sprite": "res://assets/towers/ninja_melon/T1.png",
			
			"cost": 100,
			
			"base_attack_radius": 300,
			"base_attack_type": Constants.DamageTypes.PHYSICAL,
			"base_attack_damage": 20,
			
			"attack_speed": 1.5,
			"projectile_speed": 500,
			"miss_rate": 0,
			
			"crit_rate": 0.5,
			"crit_strike_multiplier": 1.5,
			
			"armor_reduction_flat": 5,
			"resistance_reduction_percentage": 0,
			
			"color": Color(0.5, 1, 0.8),
			"next": [T2["NinjaMelon"][0],
					 T2["NinjaMelon"][1]],
		},
	},
}

func get_tower_dict(tier: int, base_tower: String, branch: int):
	var map: Dictionary
	if tier == 1:
		map = T1
	elif tier == 2:
		map = T2
	elif tier == 3:
		map = T3
	
	return map[base_tower][branch]

func get_T1_attr(base_tower: String, attr: String):
	return Towers.T1[base_tower][0][attr]
