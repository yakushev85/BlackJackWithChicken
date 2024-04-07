extends Node2D

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
	do_movement()
	

func set_heal_message(value):
	$HealLabel.text = value
	$HealLabel.show()
	do_movement()

func set_reward_message(value):
	$RewardLabel.text = value
	$RewardLabel.show()
	do_movement()

func do_movement():
	if $DamageLabel.is_visible_in_tree():
		animate_move($DamageLabel, is_moving_down)
	elif $HealLabel.is_visible_in_tree():
		animate_move($HealLabel, is_moving_down)
	elif $RewardLabel.is_visible_in_tree():
		animate_move($RewardLabel, is_moving_down)


func animate_move(a_label:Label, is_down=true):
	var new_position = a_label.rect_position
	
	if is_down:
		new_position.y = new_position.y + y_anim
	else:
		new_position.y = new_position.y - y_anim
	
	$Tween.interpolate_property(a_label, "rect_position", 
		a_label.rect_position, new_position, 1, 
		Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$Tween.start()


func _on_Tween_tween_all_completed():
	queue_free()
