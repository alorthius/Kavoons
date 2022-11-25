extends Node


var towers_data: Dictionary = {
	"NinjaMelon": {
		"T1": {
			"sprite": "res://assets/towers/ninja_melon/T1.png",
			"buy_cost": 100,
			
			"base_attack_radius": 100,
			"base_attack_type": Constants.DAMAGE_TYPES.PHYSICAL,
			"base_attack_damage": 20,
			
			"attack_speed": 1,
			"projectile_speed": 5,
			"miss_rate": 0,
			
			"crit_rate": 0,
			"crit_strike_multiplier": 2,
			
			"armor_reduction_flat": 5,
			"resistence_reduction_percentage": 0,
			
			"range_scale": 20,  # TODO: use metrics and then calculate the scale factor in code
			
			"next": [ "res://assets/towers/ninja_melon/T3_LR.png", "res://assets/towers/ninja_melon/T3_RR.png" ],
		},

		"T2-A": {
			"sprite": "res://assets/towers/ninja_melon/T3_LR.png",
			"buy_cost": 100,
			
			"base_attack_radius": 100,
			"base_attack_type": Constants.DAMAGE_TYPES.PHYSICAL,
			"base_attack_damage": 20,
			
			"attack_speed": 1,
			"projectile_speed": 5,
			"miss_rate": 0,
			
			"crit_rate": 0,
			"crit_strike_multiplier": 2,
			
			"armor_reduction_flat": 5,
			"resistence_reduction_percentage": 0,
			
			"range_scale": 25,  # TODO: use metrics and then calculate the scale factor in code
			
			"next": [],
		},

		"T2-B": {
			"sprite": "res://assets/towers/ninja_melon/T3_RR.png",
			"buy_cost": 100,
			
			"base_attack_radius": 100,
			"base_attack_type": Constants.DAMAGE_TYPES.PHYSICAL,
			"base_attack_damage": 50,
			
			"attack_speed": 0.7,
			"projectile_speed": 5,
			"miss_rate": 0,
			
			"crit_rate": 0,
			"crit_strike_multiplier": 2,
			
			"armor_reduction_flat": 5,
			"resistence_reduction_percentage": 0,
			
			"range_scale": 15,  # TODO: use metrics and then calculate the scale factor in code
			
			"next": [],
		}
	}
}
