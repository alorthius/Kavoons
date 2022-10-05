extends MelonT1

class_name NinjaT1

func _init():
	print("NinjaT1 init\n")

func _ready():
	print("Ninja T1 ready\n")

func get_next_tier():
	var next = load("res://src/scenes/towers/ninja_melon/NinjaT2.tscn").instance()
	return next
