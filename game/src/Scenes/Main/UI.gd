extends CanvasLayer


func set_tower_preview(tower_type, mouse_position):
	var drag_tower = load("res://src/Scenes/Towers/" + tower_type + ".tscn").instance()
	drag_tower.set_name("DragTower")
	drag_tower.modulate = Color("ad54ff3c")
	
	var control = Control.new()
	control.add_child(drag_tower, true)
	control.rect_position = mouse_position
	control.set_name("TowerPreview")
	add_child(control, true)
#	move_child(get_node("TowerPreview"), 0)


func update_tower_preview(new_position, color):
	get_node("TowerPreview").rect_position = new_position
	if get_node("TowerPreview").modulate != Color(color):
		get_node("TowerPreview").modulate = Color(color)
