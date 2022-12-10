extends HBoxContainer

var _lifes_remain: int = 0

onready var _label: Label = $Label


func _ready():
	assert(Events.connect("update_lifes", self, "_update_lifes") == 0)

func _update_lifes(delta: int):
	_lifes_remain += delta
	if _lifes_remain <= 0:
		#TODO
		print("GAME OVER UR DED")
	_update_label()
	
func _update_label():
	_label.text = String(_lifes_remain)
