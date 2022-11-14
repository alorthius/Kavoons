extends Melon

onready var next_A: PackedScene = preload("res://src/scenes/towers/ninja_melon/NinjaT2-A.tscn")
onready var next_B: PackedScene = preload("res://src/scenes/towers/ninja_melon/NinjaT2-B.tscn")

func _init():
	_range_scale = Towers.towers_data["NinjaMelon"]["T1"]["range_scale"]

func _ready():
	pass
