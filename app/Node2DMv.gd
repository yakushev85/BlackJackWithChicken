extends Node2D

class_name Node2DMv

var is_moving = false
var is_remove_on_stopping = false


func move_to(new_position, remove_on_finish = false):
	is_moving = true
	is_remove_on_stopping = remove_on_finish
	
	var tween = get_node("Tween") as Tween
	tween.interpolate_property(
		self, "position", 
		self.position, new_position, 1, 
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()


func _process(delta):
	var tween = get_node("Tween") as Tween
	
	if is_moving and not tween.is_active():
		is_moving = false
		if is_remove_on_stopping:
			queue_free()

