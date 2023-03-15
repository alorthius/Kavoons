extends Node2D

# warning-ignore:unused_class_variable
var waves: Dictionary = {
	1: {
		"duration": 20,
		"reward": 50,
		
		"prestart_enable": 5,
		"prestart_reward": 0,

		"Path1": {
			"enemies": [Cats.cat_1, Cats.cat_1, Cats.cat_1, Cats.cat_1, Cats.cat_1, Cats.cat_1, Cats.cat_1, Cats.cat_1],
			"spawns":  [2,          1,          4,          1,          2,          4,          1,          2,        ],
			"label": "9 x Cat1",
		},
		"Path2": {
			"enemies": [Cats.cat_2, Cats.cat_2],
			"spawns":  [10,         2         ],
			"label": "2 x Cat2",
		},
	},

	2: {
		"duration": 10,
		"reward": 70,
		
		"prestart_enable": 0,
		"prestart_reward": 0,
		
		"Path1": {
			"enemies": [Cats.cat_1, Cats.cat_2, Cats.cat_2, Cats.cat_2, Cats.cat_2, Cats.cat_1, Cats.cat_2],
			"spawns":  [1,          1,          0.5,        0.5,        0.5,        2,          1         ],
			"label": "2 x Cat1\n5 x Cat2",
		},
		"Path2": {
			"enemies": [Cats.cat_2, Cats.cat_2],
			"spawns":  [10,         2         ],
			"label": "2 x Cat2",
		},
	},
}
