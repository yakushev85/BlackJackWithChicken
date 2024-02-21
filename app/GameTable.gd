extends Node2D

export (PackedScene) var card_item_type
export (PackedScene) var player_bid_item_type
export (PackedScene) var chicken_bid_item_type
export (PackedScene) var message_hint_type

export var max_bid_value = 5

export var card_offset = 20
export var bid_offset = 40

var ALL_PREVAL = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
var ALL_SYM = ["1", "2", "c", "s"]

var deck_of_cardids = []
var player_cards = []
var chicken_cards = []

var all_bids = []

var chicken_bid_value = 0
var player_bid_value = 0

var is_first_turn = true
var is_not_doubled = true
var is_locked = false

var player_grains = 30
var chicken_eggs = 30
var player_won_eggs = 0

func _ready():
	randomize()
	$ControlsUI/SayBox.visible = false
	init_round()

func init_round():
	is_locked = false
	is_first_turn = true
	init_deck()
	init_cards()
	init_player_bids()
	init_chicken_bids()
	update_values()
	show_allbuttons()


func show_allbuttons():
	$ControlsUI/AllButtons.show()
	$ControlsUI/AllButtons/BidButton.show()


func update_values():
	$ControlsUI/ChickenEggsLabel.text = str(chicken_eggs)
	$ControlsUI/PlayerGrainsLabel.text = str(player_grains)
	$ControlsUI/PlayerEggsLabel.text = str(player_won_eggs)
	

func show_message(msg_text):
	$ControlsUI/SayBox.set_message(msg_text)
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
		card.position = Vector2(card_index*card_offset, -600)
	else:
		card.position.x = card_index*card_offset
		
	card_holder.add_child(card)
	
	if will_move:
		card.move_to(Vector2(card_index*card_offset, 0))
		
	return card


func init_cards():
	for i in range(2):
		chicken_cards.append(add_card($ChickenCardHolder, i, get_card_from_deck()))
		player_cards.append(add_card($PlayerCardHolder, i, get_card_from_deck()))
		player_cards[i].set_bstatus(false)
	
	chicken_cards[0].set_bstatus(false)


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

func add_bid(bid_holder, bid_index, bit_type):
	var bid_item = bit_type.instance()
	bid_item.position.x = bid_index*bid_offset
	bid_holder.add_child(bid_item)
	all_bids.append(bid_item)


func init_player_bids():
	player_bid_value = 0
	add_bid($PlayerBidHolder, 0, player_bid_item_type)
	player_grains = player_grains - 1
	player_bid_value = player_bid_value + 1

	
func init_chicken_bids():
	chicken_bid_value = 0
	add_bid($ChickenBidHolder, 0, chicken_bid_item_type)
	chicken_eggs = chicken_eggs - 1
	chicken_bid_value = chicken_bid_value + 1


func chicken_win_round():
	is_locked = true
	chicken_eggs = chicken_eggs + chicken_bid_value
	show_message_hint($ControlsUI/ChickenEggs, chicken_bid_value)
	chicken_bid_value = 0
	player_bid_value = 0
	
	for ibid in all_bids:
		ibid.queue_free()
	
	all_bids = []
	
	show_message("I win this round!!")
	$TimersGroup/FinishRoundTimer.start()
	

func player_win_round():
	is_locked = true
	player_won_eggs = player_won_eggs + chicken_bid_value
	show_message_hint($ControlsUI/PlayerEggs, chicken_bid_value, false)
	player_grains = player_grains + player_bid_value
	show_message_hint($ControlsUI/PlayerGrains, player_bid_value, false)
	chicken_bid_value = 0
	player_bid_value = 0
	
	for ibid in all_bids:
		ibid.queue_free()
	
	all_bids = []
	
	show_message("You win this round!!")
	$TimersGroup/FinishRoundTimer.start()


func chicken_turn():
	is_locked = true
	chicken_cards[chicken_cards.size() - 1].set_bstatus(false)
	var player_card_sum = get_cards_sum(player_cards)
	var chicken_card_sum = get_cards_sum(chicken_cards)
	
	while chicken_card_sum > 0 and chicken_card_sum < player_card_sum:
		chicken_cards.append(add_card($ChickenCardHolder, chicken_cards.size(), get_card_from_deck()))
		chicken_cards[chicken_cards.size()-1].set_bstatus(false)
		chicken_card_sum = get_cards_sum(chicken_cards)
		
	if chicken_card_sum < 0:
		player_win_round()
	else:
		chicken_win_round()


func _on_MessageTimer_timeout():
	$ControlsUI/SayBox.visible = false


func _on_FinishRoundTimer_timeout():
	for icard in player_cards:
		icard.queue_free()
	
	player_cards = []
	
	for icard in chicken_cards:
		icard.queue_free()
		
	chicken_cards = []
	
	init_round()


func _on_BidButton_pressed():
	if player_bid_value < max_bid_value and is_first_turn:
		add_bid($PlayerBidHolder, player_bid_value, player_bid_item_type)
		player_grains = player_grains - 1
		show_message_hint($ControlsUI/PlayerGrains, -1, false)
		player_bid_value = player_bid_value + 1
		add_bid($ChickenBidHolder, chicken_bid_value, chicken_bid_item_type)
		chicken_eggs = chicken_eggs - 1
		show_message_hint($ControlsUI/ChickenEggs, -1)
		chicken_bid_value = chicken_bid_value + 1
		update_values()
		print("added bids ", player_bid_value, " : ", chicken_bid_value)
		return


func _on_DoubleButton_pressed():
	if is_not_doubled and player_grains - player_bid_value > 0 and chicken_eggs - chicken_bid_value > 0:
		add_bid($PlayerBidHolder, player_bid_value, player_bid_item_type)
		player_grains = player_grains - player_bid_value
		show_message_hint($ControlsUI/PlayerGrains, -player_bid_value, false)
		player_bid_value = 2*player_bid_value
		add_bid($ChickenBidHolder, chicken_bid_value, chicken_bid_item_type)
		chicken_eggs = chicken_eggs - chicken_bid_value
		show_message_hint($ControlsUI/ChickenEggs, -chicken_bid_value)
		chicken_bid_value = 2*chicken_bid_value
		print("added bids ", player_bid_value, " : ", chicken_bid_value)
		is_not_doubled = false
		player_cards.append(add_card($PlayerCardHolder, player_cards.size(), get_card_from_deck(), true))
		player_cards[player_cards.size()-1].set_bstatus(false)
		chicken_turn()
		return


func _on_HitButton_pressed():
	if get_cards_sum(player_cards) > 0:
		is_first_turn = false
		$ControlsUI/AllButtons/BidButton.hide()
		player_cards.append(add_card($PlayerCardHolder, player_cards.size(), get_card_from_deck(), true))
		player_cards[player_cards.size()-1].set_bstatus(false)
		
		if get_cards_sum(player_cards) < 0:
			chicken_win_round()


func _on_StandButton_pressed():
	chicken_turn()


func show_message_hint(pobject, hvalue, vorientation=true):
	var grain_hint = message_hint_type.instance()
	grain_hint.position = pobject.position
	grain_hint.set_orientation_drop(vorientation)
	
	$MessageHintHolder.add_child(grain_hint)
	
	if hvalue >= 0:
		grain_hint.set_heal_message("+" + str(hvalue))
	else:
		grain_hint.set_damage_message(str(hvalue))
