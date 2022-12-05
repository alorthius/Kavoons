extends Node


var T3_towers: Dictionary = {
	"NinjaMelon": {
		"1": {
			"scene": "",
			"sprite": "res://assets/towers/ninja_melon/T4_LR.png",

			"color": Color(1, 0.9, 0),
			"next": [],
		},
		"2": {
			"scene": "",
			"sprite": "res://assets/towers/ninja_melon/T4_RR.png",

			"color": Color(1, 0.4, 0.5),
			"next": [],
		},
	}
}

var T2_towers: Dictionary = {
	"NinjaMelon": {

		"1": {
			"scene": "res://src/scenes/towers/ninja_melon/NinjaT2-A.tscn",
			"sprite": "res://assets/towers/ninja_melon/T3_LR.png",
			
			"buy_cost": 100,
			
			"base_attack_radius": 500,
			"base_attack_type": Constants.DAMAGE_TYPES.PHYSICAL,
			"base_attack_damage": 20,
			
			"attack_speed": 1,
			"projectile_speed": 500,
			"miss_rate": 0,
			
			"crit_rate": 0,
			"crit_strike_multiplier": 2,
			
			"armor_reduction_flat": 5,
			"resistance_reduction_percentage": 0,

			"color": Color(1, 0.9, 0),
			"next": [T3_towers["NinjaMelon"]["1"]],
		},

		"2": {
			"scene": "res://src/scenes/towers/ninja_melon/NinjaT2-B.tscn",
			"sprite": "res://assets/towers/ninja_melon/T3_RR.png",
			
			"buy_cost": 100,
			
			"base_attack_radius": 150,
			"base_attack_type": Constants.DAMAGE_TYPES.PHYSICAL,
			"base_attack_damage": 50,
			
			"attack_speed": 0.7,
			"projectile_speed": 500,
			"miss_rate": 0,
			
			"crit_rate": 0,
			"crit_strike_multiplier": 2,
			
			"armor_reduction_flat": 5,
			"resistance_reduction_percentage": 0,

			"color": Color(1, 0.4, 0.5),
			"next": [T3_towers["NinjaMelon"]["2"]],
		},
	}
}

var T1_towers: Dictionary = {
	"NinjaMelon": {

		"0": {
			"scene": "res://src/scenes/towers/ninja_melon/NinjaT1.tscn",
			"sprite": "res://assets/towers/ninja_melon/T1.png",
			
			"buy_cost": 100,
			
			"base_attack_radius": 300,
			"base_attack_type": Constants.DAMAGE_TYPES.PHYSICAL,
			"base_attack_damage": 20,
			
			"attack_speed": 1,
			"projectile_speed": 500,
			"miss_rate": 0,
			
			"crit_rate": 0,
			"crit_strike_multiplier": 2,
			
			"armor_reduction_flat": 5,
			"resistance_reduction_percentage": 0,
			
			"color": Color(1, 0.9, 0),
			"next": [T2_towers["NinjaMelon"]["1"], T2_towers["NinjaMelon"]["2"]],
		},
	}
}
