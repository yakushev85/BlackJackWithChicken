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
		var n_velocity = velocity.normalized()*speed*delta
		
		if velocity.length() > n_velocity.length():
			position = position + n_velocity
		else:
			position = move_position
			is_moving = false
