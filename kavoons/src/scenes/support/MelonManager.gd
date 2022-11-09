extends Node2D

class_name MelonManager

var curr_melon: Melon
var curr_upgrader: Upgrader
var upgrades_queue: Array

func fill(melon: Melon):
	curr_melon = melon

func fill_queue(melon: Melon):
	pass
#	upgrades_queue.push_front()

func sell():
	pass

func info():
	pass

func updrade():
	pass
