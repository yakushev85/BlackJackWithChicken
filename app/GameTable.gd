extends Node2D

export (PackedScene) var card_item_type
export (PackedScene) var player_bid_item_type
export (PackedScene) var chicken_bid_item_type
export (PackedScene) var message_hint_type

export var max_bid_value = 5

export var card_offset = 20
export var bid_offset = 40

export var rooster_apear_time = 1.0
export var rooster_disapear_time = 1.0

export var rat_apear_percent = 20
export var chick_apear_percent = 20

var ALL_PREVAL = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
var ALL_SYM = ["1", "2", "c", "s"]

var deck_of_cardids = []
var player_cards = []
var chicken_cards = []

var all_bids = []

var do_array = []

var chicken_bid_value = 0
var player_bid_value = 0

var is_first_turn = true
var is_not_doubled = true
var is_bidding = false

var player_grains = 40
var chicken_eggs = 30
var player_won_eggs = 0

func _ready():
	randomize()
	$ControlsUI/SayBox.hide()
	$ControlsUI/AllButtons.hide()
	
	$ControlsUI/PlayerGrainsLabel.text = str(player_grains)
	$ControlsUI/ChickenEggsLabel.text = str(chicken_eggs)
	
	init_round()
	
	$BgMusicPlayer.play()
	$PlayerLossAudioPlayer.play()
	

func init_round():
	show_message("Let's play, human!")
	is_first_turn = true
	is_not_doubled = true
	init_deck()
	
	do_array = ["player_card:2", "chicken_card:2", "player_bid:2", "chicken_bid:2", "show_buttons:1", "check_rat:1"]
	exec_do_array()


func exec_do_array():
	var exec_el = do_array.pop_front()
	
	if exec_el == null:
		return
	
	var exec_el_params = str(exec_el).split(":")
	var func_exec = exec_el_params[0]
	var func_timeout = int(exec_el_params[1])
	
	call("do_" + func_exec)
	
	$TimersGroup/GameStepTimer.wait_time = func_timeout
	$TimersGroup/GameStepTimer.start()


# **************************
# start section for do funcs
# **************************
func do_player_bid():
	is_bidding = true
	
	add_bid($PlayerBidHolder, player_bid_value, player_bid_item_type, -300)
	player_grains = player_grains - 1
	show_message_hint($ControlsUI/PlayerGrains, -1, false)
	player_bid_value = player_bid_value + 1
	update_values()
	
	if player_bid_value == max_bid_value:
		$ControlsUI/AllButtons/BidButton.hide()
	

func do_chicken_bid():
	add_bid($ChickenBidHolder, chicken_bid_value, chicken_bid_item_type)
	chicken_eggs = chicken_eggs - 1
	show_message_hint($ControlsUI/ChickenEggs, -1)
	chicken_bid_value = chicken_bid_value + 1
	update_values()
	
	is_bidding = false
	
func do_player_card():
	player_cards.append(add_card($PlayerCardHolder, player_cards.size(), get_card_from_deck(), true))
	player_cards[player_cards.size()-1].set_bstatus(false)


func do_chicken_card():
	chicken_cards.append(add_card($ChickenCardHolder, chicken_cards.size(), get_card_from_deck(), true))
	chicken_cards[chicken_cards.size()-1].set_bstatus(false)
	

func do_chicken_turn():
	var player_card_sum = get_cards_sum(player_cards)
	var chicken_card_sum = get_cards_sum(chicken_cards)
	
	if chicken_card_sum < 0:
		player_win_round()
	elif chicken_card_sum < player_card_sum or (chicken_card_sum == player_card_sum and player_card_sum <= 11):
		do_array.append("chicken_card:2")
		do_array.append("chicken_turn:1")
	elif chicken_card_sum == player_card_sum:
		draw_round()
	else:
		chicken_win_round()
		
		
func do_show_buttons():
	$ControlsUI/AllButtons.show()
	
	if is_first_turn:
		$ControlsUI/AllButtons/BidButton.show()
	else:
		$ControlsUI/AllButtons/BidButton.hide()
		
	if is_not_doubled:
		$ControlsUI/AllButtons/DoubleButton.show()
	else:
		$ControlsUI/AllButtons/DoubleButton.hide()


func do_check_rat():
	if randi() % 100 <= rat_apear_percent:
		show_rat()
		

func do_chick():
	if randi() % 100 <= chick_apear_percent:
		show_chick()
# **************************
# end section for do funcs
# ************************** 


func update_values():
	$ControlsUI/ChickenEggsLabel.text = str(chicken_eggs)
	$ControlsUI/PlayerGrainsLabel.text = str(player_grains)
	$ControlsUI/PlayerEggsLabel.text = str(player_won_eggs)
	

func show_message(msg_text):
	$ControlsUI/SayBox.set_message(msg_text)
	show_rooster(true)

func show_rooster(is_message_shown=false):
	# RoosterSprite: x0 = -150, x1 = 55
	
	$RoosterTween.interpolate_property(
		$RoosterSprite, "position", 
		$RoosterSprite.position, Vector2(55, $RoosterSprite.position.y),
		rooster_apear_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	if is_message_shown:
		$RoosterTween.interpolate_callback(self, rooster_apear_time, "make_message")
	$RoosterTween.start()

func hide_rooster():
	$RoosterTween.interpolate_property(
		$RoosterSprite, "position", 
		$RoosterSprite.position, Vector2(-150, $RoosterSprite.position.y),
		rooster_disapear_time, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$RoosterTween.start()

func make_message(): 
	$ControlsUI/SayBox.visible = true
	$TimersGroup/MessageTimer.start()


func init_deck():
	deck_of_cardids = []
	for preval in ALL_PREVAL:
		for sym in ALL_SYM:
			deck_of_cardids.append(preval + ":" + sym)


func get_card_from_deck():
	var nextCardIndex = randi() % deck_of_cardids.size()
	var nextCard = deck_of_cardids[nextCardIndex]
	deck_of_cardids.remove(nextCardIndex)
	return nextCard


func add_card(card_holder, card_index, card_id, will_move = false):
	var card = card_item_type.instance()
	card.set_cardid(card_id)
	
	if will_move:
		card.position = Vector2(card_index*card_offset-600, 0)
	else:
		card.position.x = card_index*card_offset
		
	card_holder.add_child(card)
	
	if will_move:
		card.move_to(Vector2(card_index*card_offset, 0))
		
	return card


func get_cards_sum(acards):
	var asum = [0, ]
	
	for icard in acards:
		var card_val = icard.get_card_val()
		for i in range(asum.size()):
			asum[i] = asum[i] + card_val
			
		if card_val == 11:
			var tsum = []
			for i in range(asum.size()):
				tsum.append(asum[i] - 10)
			asum.append_array(tsum)
	
	var rsum = -1
	
	for i in range(asum.size()):
		if (asum[i] > rsum) and (asum[i] <= 21):
			rsum = asum[i]
	
	return rsum


func add_bid(bid_holder, bid_index, bit_type, start_x=500, start_y=0):
	var bid_item = bit_type.instance()
	bid_item.position.x = start_x
	bid_item.position.y = start_y
	bid_holder.add_child(bid_item)
	all_bids.append(bid_item)
	bid_item.move_to(Vector2(bid_index*bid_offset, 0))


func chicken_win_round():
	$PlayerLossAudioPlayer.play()
	
	for player_bid_obj in $PlayerBidHolder.get_children():
		player_bid_obj.move_to(Vector2(-263,-410), true)
	
	for chicken_bid_obj in $ChickenBidHolder.get_children():
		chicken_bid_obj.move_to(Vector2(550, 0), true)
	
	chicken_eggs = chicken_eggs + chicken_bid_value
	show_message_hint($ControlsUI/ChickenEggs, chicken_bid_value)
	chicken_bid_value = 0
	player_bid_value = 0
	update_values()
	
	show_message("I win this round! Tasty grains!!")
	$TimersGroup/FinishRoundTimer.start()


func draw_round():
	$PlayerLossAudioPlayer.play()
	
	for player_bid_obj in $PlayerBidHolder.get_children():
		player_bid_obj.move_to(Vector2(-325, 0), true)
	
	for chicken_bid_obj in $ChickenBidHolder.get_children():
		chicken_bid_obj.move_to(Vector2(550, 0), true)
	
	player_grains = player_grains + player_bid_value
	show_message_hint($ControlsUI/PlayerGrains, player_bid_value, false)
	chicken_eggs = chicken_eggs + chicken_bid_value
	show_message_hint($ControlsUI/ChickenEggs, chicken_bid_value)
	chicken_bid_value = 0
	player_bid_value = 0
	update_values()
	
	show_message("Draw!!")
	$TimersGroup/FinishRoundTimer.start()


func player_win_round():
	$PlayerWinAudioPlayer.play()
	
	for player_bid_obj in $PlayerBidHolder.get_children():
		player_bid_obj.move_to(Vector2(-325, 0), true)
	
	for chicken_bid_obj in $ChickenBidHolder.get_children():
		chicken_bid_obj.move_to(Vector2(550, 450), true)
	
	player_won_eggs = player_won_eggs + chicken_bid_value
	show_message_hint($ControlsUI/PlayerEggs, chicken_bid_value, false)
	player_grains = player_grains + player_bid_value
	show_message_hint($ControlsUI/PlayerGrains, player_bid_value, false)
	chicken_bid_value = 0
	player_bid_value = 0
	update_values()
	
	show_message("You win this round! Eh, no grains.")
	$TimersGroup/FinishRoundTimer.start()


func _on_MessageTimer_timeout():
	$ControlsUI/SayBox.visible = false
	hide_rooster()


func _on_FinishRoundTimer_timeout():
	all_bids = []
	
	for icard in player_cards:
		icard.queue_free()
	
	player_cards = []
	
	for icard in chicken_cards:
		icard.queue_free()
		
	chicken_cards = []
	
	init_round()
	
	if player_grains <= 0 or chicken_eggs <= 0:
		Global.game_data.player_eggs = player_won_eggs
		Global.game_data.player_grains = player_grains
		Global.game_data.chicken_eggs = chicken_eggs
		get_tree().change_scene("res://FinishScreen.tscn")
	

func _on_BidButton_pressed():
	if is_bidding:
		return
	
	if player_bid_value < max_bid_value and is_first_turn and player_grains > 0 and chicken_eggs > 0:
		do_array.append_array(["player_bid:1", "chicken_bid:2"])
		exec_do_array()
		


func _on_DoubleButton_pressed():
	if is_not_doubled and player_grains - player_bid_value >= 0 and chicken_eggs - chicken_bid_value >= 0:
		is_not_doubled = false
		$ControlsUI/AllButtons.hide()
		
		for i in range(player_bid_value):
			do_array.append_array(["player_bid:1", "chicken_bid:1"])
		
		do_array.append_array(["player_card:2", "chicken_turn:2"])
		exec_do_array()


func _on_HitButton_pressed():
	if get_cards_sum(player_cards) > 0:
		is_first_turn = false
		$ControlsUI/AllButtons.hide()
		do_player_card()
		
		if get_cards_sum(player_cards) < 0:
			chicken_win_round()
		else:
			do_show_buttons()
			do_chick()


func _on_StandButton_pressed():
	$ControlsUI/AllButtons.hide()
	do_array = ["chicken_turn:1"]
	exec_do_array()


func show_message_hint(pobject, hvalue, vorientation=true):
	var grain_hint = message_hint_type.instance()
	grain_hint.position = pobject.position
	grain_hint.set_orientation_drop(vorientation)
	
	$MessageHintHolder.add_child(grain_hint)
	
	if hvalue > 0:
		grain_hint.set_reward_message("+" + str(hvalue))
	elif hvalue < 0:
		grain_hint.set_damage_message(str(hvalue))


func _on_GameStepTimer_timeout():
	exec_do_array()


func show_rat():
	var new_rat_pos = Vector2($PlayerBidHolder.position.x - 10 + randi() % 50, $PlayerBidHolder.position.y + 35)
	$RatTween.interpolate_property(
		$RatSprite, "position", 
		$RatSprite.position, new_rat_pos,
		1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$RatTween.start()
	$TimersGroup/RatTimer.start()


func hide_rat():
	var new_rat_pos = Vector2($PlayerBidHolder.position.x, 800)
	$RatTween.interpolate_property(
		$RatSprite, "position", 
		$RatSprite.position, new_rat_pos,
		1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$RatTween.start()


func show_chick():
	var chick_index = 0
	
	if $ChickenBidHolder.get_child_count() == 0:
		return
	elif $ChickenBidHolder.get_child_count() > 1:
		chick_index = randi() % $ChickenBidHolder.get_child_count()
	
	var selected_egg = $ChickenBidHolder.get_child(chick_index) as Node2D
	var chick_position = selected_egg.global_position
	selected_egg.queue_free()
	$ChickSprite.position = chick_position
	$TimersGroup/ChickTimer.start()
	

func hide_chick():
	chicken_bid_value = chicken_bid_value - 1
		
	var new_chick_pos = Vector2($ChickSprite.position.x, -100)
	$ChickTween.interpolate_property(
		$ChickSprite, "position", 
		$ChickSprite.position, new_chick_pos,
		1, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	$ChickTween.start()
	$ChickSprite/ChickAnimationPlayer.play("Walk")


func _input(event):
	if event is InputEventMouseButton and not (event as InputEventMouseButton).is_pressed():
		var distance_to_rat = (event.position as Vector2).distance_to($RatSprite.position)
		if distance_to_rat < 30:
			$TimersGroup/RatTimer.stop()
			hide_rat()
			
		var distance_to_chick = (event.position as Vector2).distance_to($ChickSprite.position)
		if distance_to_chick < 30:
			$TimersGroup/ChickTimer.stop()
			hide_chick()
			player_won_eggs = player_won_eggs + 1
			show_message_hint($ControlsUI/PlayerEggs, 1, false)
		
		
func _on_RatTimer_timeout():
	if $PlayerBidHolder.get_child_count() > 0 and $PlayerBidHolder.get_child_count() >= player_bid_value:
		$PlayerBidHolder.get_child(player_bid_value - 1).queue_free()
		player_bid_value = player_bid_value - 1
	
	hide_rat()
	

func _on_ChickTimer_timeout():
	hide_chick()

