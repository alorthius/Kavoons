extends Node2D

class_name Upgrader

func _ready():
	pass

func _physics_process(delta):
	pass
#	if Input.is_action_just_pressed("level_up", true):
#		if (self.get_child_count() >= 1):
#			print("leveled_up\n")
#			print(self.get_child(0))
#			var new_tower = self.get_child(0).get_next_tier()
#			self.get_child(0).queue_free()
#			self.add_child(new_tower, true)
#
#			new_tower.position = Vector2(500, 500)
#			new_tower.base_sprite.scale.x = 5
#			new_tower.base_sprite.scale.y = 5

func level_up():
	pass
