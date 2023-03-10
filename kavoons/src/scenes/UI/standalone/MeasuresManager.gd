extends VBoxContainer

## Manages the economy and life systems

onready var _economics: HBoxContainer = $Economy

onready var _lifes: HBoxContainer = $Lifes

func set_init_money(money: int):
	_economics._update_money(money)

func set_init_lifes(lifes: int):
	_lifes._update_lifes(lifes)
