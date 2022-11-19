extends Melon


func _init():
	next_A = preload("res://src/scenes/towers/ninja_melon/NinjaT2-A.tscn")
	next_B = preload("res://src/scenes/towers/ninja_melon/NinjaT2-B.tscn")
	_range_scale = Towers.towers_data["NinjaMelon"]["T1"]["range_scale"]

func _ready():
	pass
