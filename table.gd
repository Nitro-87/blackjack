extends Node2D
@export var card: PackedScene

var suits = ["Purple", "Blue"]
var ranks = ["Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King"]
var deck = []
var player_hand = []
var dealer_hand = [] 
var pscore = 0
var dscore = 0 

func new_deck():
	deck.clear()
	var i = 0
	while i < 2:
		for suit in suits:
			for rank in ranks:
				deck.append([rank, suit])
		deck.shuffle()
		i+= 1
		
func deal_card():
	var card_data = deck.pop_back()
	var new_card = card.instantiate()
	new_card.rank = card_data[0]
	new_card.suit = card_data[1] 
	add_child(new_card)
	return new_card
	
func hand_value(hand) -> int:
	var total = 0
	var aces = 0
	for card in hand:
		if card.flipped:
			total+= card.card_value()
			if card.rank == "Ace":
				aces += 1
	
	while total > 21 and aces > 0:
		total -= 10
		aces -= 1
	return total

func _ready() -> void:
	new_deck()
	
	var new_card = deal_card()
	player_hand.append(new_card)
	new_card.position = $PlayerHand/Card1.global_position
	new_card.flip()
	
	new_card = deal_card()
	player_hand.append(new_card)
	new_card.position = $PlayerHand/Card2.global_position
	new_card.flip()
	
	new_card = deal_card()
	dealer_hand.append(new_card)
	new_card.position = $DealerHand/DCard1.global_position
	new_card.flip()
	
	new_card = deal_card()
	dealer_hand.append(new_card)
	new_card.position = $DealerHand/DCard2.global_position

func _process(delta: float) -> void:
	if player_hand == null:
		$PlayerHand/total.text = ("Score:" + str(0))
	else:
		$PlayerHand/total.text = ("Score:" + str(hand_value(player_hand)))
	
	if dealer_hand == null:
		$DealerHand/dtotal.text = ("Score:" + str(0))
	else:
		$DealerHand/dtotal.text = ("Score:" + str(hand_value(dealer_hand)))
		
