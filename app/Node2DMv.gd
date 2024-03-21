extends Node2D

class_name Node2DMv

export var speed = 500

var move_position = Vector2.ZERO
var is_moving = false
var is_remove_on_stopping = false


func move_to(new_position, remove_on_finish = false):
	is_moving = true
	is_remove_on_stopping = remove_on_finish
	move_position = new_position


func _process(delta):
	if is_moving:
		var velocity = move_position - position
		var n_velocity = velocity.normalized()*speed*delta
		
		if velocity.length() > n_velocity.length():
			position = position + n_velocity
		else:
			position = move_position
			is_moving = false
			
			if is_remove_on_stopping:
				queue_free()

