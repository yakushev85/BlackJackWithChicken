extends Node2D


func move_to(new_position, remove_on_finish = false):	
	var tween = create_tween()
	
	tween.tween_property(self, "position", new_position, 1)
		
	if remove_on_finish:
		tween.tween_callback(self.queue_free)
		
	tween.play()
