extends Node2D

# warning-ignore:unused_class_variable
var waves: Dictionary = {
	1: {
		"prestart": 0,
		"duration": 20,
		"reward": 50,
		"Path1": {
			"enemies": [Cats.cat_1, Cats.cat_1, Cats.cat_1, Cats.cat_1, Cats.cat_1, Cats.cat_1, Cats.cat_1, Cats.cat_1],
			"spawns":  [2,          1,          4,          1,          2,          4,          1,          2,        ],
		},
		"Path2": {
			"enemies": [Cats.cat_2, Cats.cat_2],
			"spawns":  [10,         2         ],
		},
	},

	2: {
		"prestart": 3,
		"duration": 10,
		"reward": 70,
		"Path1": {
			"enemies": [Cats.cat_1, Cats.cat_2, Cats.cat_2, Cats.cat_2, Cats.cat_2, Cats.cat_1, Cats.cat_2],
			"spawns":  [1,          1,          0.5,        0.5,        0.5,        2,          1         ],
		},
		"Path2": {
			"enemies": [],
			"spawns":  [],
		},
	},
}
