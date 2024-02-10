extends Node2D

export (PackedScene) var card_item_type
export (PackedScene) var player_bid_item_type
export (PackedScene) var chicken_bid_item_type

var ALL_PREVAL = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
var ALL_SYM = ["1", "2", "c", "s"]

var deck_of_cardids = []
var player_cards = []
var chicken_cards = []

var chicken_bid_value = 0
var player_bid_value = 0

func _ready():
	randomize()
	init_deck()
	init_cards()
	init_player_bids()
	init_chicken_bids()
	print(deck_of_cardids)
	print(player_bid_value, ", ", chicken_bid_value)


func init_deck():
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
	# for debug set bstatus
	card.set_bstatus(false)
	return card


func init_cards():
	for i in range(2):
		chicken_cards.append(add_card($ChickenCardHolder, i, get_card_from_deck()))
		player_cards.append(add_card($PlayerCardHolder, i, get_card_from_deck()))


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


func init_player_bids():
	player_bid_value = 0
	add_bid($PlayerBidHolder, 0, player_bid_item_type)
	player_bid_value = player_bid_value + 1

	
func init_chicken_bids():
	chicken_bid_value = 0
	add_bid($ChickenBidHolder, 0, chicken_bid_item_type)
	chicken_bid_value = chicken_bid_value + 1


func _input(event):	
	if event is InputEventMouseButton and not (event as InputEventMouseButton).is_pressed():
		#(event.position.x, event.position.y)
		var bidRectPosition = $ControlsUI/PlayerGrainsPanel.rect_global_position
		var bidRectSize = $ControlsUI/PlayerGrainsPanel.rect_size
	
		if player_bid_value < 5:
			if (event.position.x >= bidRectPosition.x) and (event.position.y >= bidRectPosition.y) and (event.position.x <= bidRectPosition.x+bidRectSize.x) and (event.position.y <= bidRectPosition.y+bidRectSize.y):
				add_bid($PlayerBidHolder, player_bid_value, player_bid_item_type)
				player_bid_value = player_bid_value + 1
				add_bid($ChickenBidHolder, chicken_bid_value, chicken_bid_item_type)
				chicken_bid_value = chicken_bid_value + 1
				print("added bids ", player_bid_value, " : ", chicken_bid_value)
				return
		
		if get_cards_sum(player_cards) >= 0:
			player_cards.append(add_card($PlayerCardHolder, player_cards.size(), get_card_from_deck()))
