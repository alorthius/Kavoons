extends Melon


func _init():
	base_tower = "NinjaMelon"
	tier = "T2-A"

	next_A = null
	next_B = null


func _ready():
	_parse_tower_data()

