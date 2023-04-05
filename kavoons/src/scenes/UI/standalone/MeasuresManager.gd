extends VBoxContainer

## Manages the economy and life systems

onready var _economics: HBoxContainer = $Economy

onready var _lifes: HBoxContainer = $Lifes

func set_init_money(money: int):
	_economics.money_total = money
	_economics._update_label()

func set_init_lifes(lifes: int):
	_lifes._lifes_remain = lifes
	_lifes._update_label()
