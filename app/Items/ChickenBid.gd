extends Node2D

export var speed = 500

var move_position = Vector2.ZERO
var is_moving = false


func move_to(new_position):
	is_moving = true
	move_position = new_position


func _process(delta):
	if is_moving:
		var velocity = move_position - position
		
		if velocity.length() > 1:
			position = position + velocity.normalized()*speed*delta 
		else:
			position = move_position
			is_moving = false
