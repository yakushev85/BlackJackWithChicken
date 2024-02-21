extends Node2D

export var y_speed = 100
export var y_anim = 200
var is_moving_down = true

func _ready():
	$DamageLabel.hide()
	$HealLabel.hide()
	$RewardLabel.hide()


func set_y_anim(v):
	y_anim = v


func set_orientation_drop(v):
	is_moving_down = v


func set_damage_message(value):
	$DamageLabel.text = value
	$DamageLabel.show()
	

func set_heal_message(value):
	$HealLabel.text = value
	$HealLabel.show()

func set_reward_message(value):
	$RewardLabel.text = value
	$RewardLabel.show()

func _process(delta):
	if $DamageLabel.is_visible_in_tree():
		animate_move($DamageLabel, y_speed*delta, is_moving_down)
	elif $HealLabel.is_visible_in_tree():
		animate_move($HealLabel, y_speed*delta, is_moving_down)
	elif $RewardLabel.is_visible_in_tree():
		animate_move($RewardLabel, y_speed*delta, is_moving_down)


func animate_move(a_label:Label, delta_y, is_down=true):
	if is_down:
		a_label.rect_position.y += delta_y
		
		if a_label.rect_position.y > y_anim:
			queue_free()
	else:
		a_label.rect_position.y -= delta_y
		
		if a_label.rect_position.y < -1*y_anim:
			queue_free()
