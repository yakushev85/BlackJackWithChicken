extends Node2D

export (PackedScene) var card_item_type
export (PackedScene) var player_bid_item_type
export (PackedScene) var chicken_bid_item_type

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


func add_card(card_holder, card_index, card_id):
	var card = card_item_type.instance()
	card.position.x = card_index*20
	card.set_cardid(card_id)
	card_holder.add_child(card)
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
	bid_item.position.x = bid_index*20
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


func _input(event):	
	if not is_locked and event is InputEventMouseButton and not (event as InputEventMouseButton).is_pressed():
		#(event.position.x, event.position.y)
		var bidRectPosition = $ControlsUI/PlayerGrainsPanel.rect_global_position
		var bidRectSize = $ControlsUI/PlayerGrainsPanel.rect_size
	
		if (event.position.x >= bidRectPosition.x) and (event.position.y >= bidRectPosition.y) and (event.position.x <= bidRectPosition.x+bidRectSize.x) and (event.position.y <= bidRectPosition.y+bidRectSize.y):
			if player_bid_value < 5 and is_first_turn:
				add_bid($PlayerBidHolder, player_bid_value, player_bid_item_type)
				player_grains = player_grains - 1
				player_bid_value = player_bid_value + 1
				add_bid($ChickenBidHolder, chicken_bid_value, chicken_bid_item_type)
				chicken_eggs = chicken_eggs - 1
				chicken_bid_value = chicken_bid_value + 1
				update_values()
				print("added bids ", player_bid_value, " : ", chicken_bid_value)
				return
			elif not is_first_turn and is_not_doubled and player_grains - player_bid_value > 0 and chicken_eggs - chicken_bid_value > 0:
				add_bid($PlayerBidHolder, player_bid_value, player_bid_item_type)
				player_grains = player_grains - player_bid_value
				player_bid_value = 2*player_bid_value
				add_bid($ChickenBidHolder, chicken_bid_value, chicken_bid_item_type)
				chicken_eggs = chicken_eggs - chicken_bid_value
				chicken_bid_value = 2*chicken_bid_value
				print("added bids ", player_bid_value, " : ", chicken_bid_value)
				is_not_doubled = false
				player_cards.append(add_card($PlayerCardHolder, player_cards.size(), get_card_from_deck()))
				player_cards[player_cards.size()-1].set_bstatus(false)
				chicken_turn()
				return
				
		var chickenRectPosition = $ControlsUI/ChickenAvatarPanel.rect_global_position
		var chickenRectSize = $ControlsUI/ChickenAvatarPanel.rect_size
	
		if (event.position.x >= chickenRectPosition.x) and (event.position.y >= chickenRectPosition.y) and (event.position.x <= chickenRectPosition.x+chickenRectSize.x) and (event.position.y <= chickenRectPosition.y+chickenRectSize.y):
			chicken_turn()
			return
		
		if get_cards_sum(player_cards) > 0:
			is_first_turn = false
			player_cards.append(add_card($PlayerCardHolder, player_cards.size(), get_card_from_deck()))
			player_cards[player_cards.size()-1].set_bstatus(false)
			
			if get_cards_sum(player_cards) < 0:
				chicken_win_round()


func chicken_win_round():
	is_locked = true
	chicken_eggs = chicken_eggs + chicken_bid_value
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
	player_grains = player_grains + player_bid_value
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
