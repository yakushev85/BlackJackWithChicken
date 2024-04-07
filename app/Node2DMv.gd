extends Node2D

class_name Node2DMv


func move_to(new_position, remove_on_finish = false):	
	var tween = get_node("Tween") as Tween
	
	tween.interpolate_property(
		self, "position", 
		self.position, new_position, 1, 
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		
	if remove_on_finish:
		tween.interpolate_callback(self, 1, "queue_free")
		
	tween.start()

