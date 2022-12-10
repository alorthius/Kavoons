extends Control

onready var _economics: HBoxContainer = $UI/HUD/Economy

func set_init_money(money: int):
	_economics.money_total = money
	_economics._update_label()
