extends Node2D
@export var card: PackedScene

var suits = ["Purple", "Blue"]
var ranks = ["Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King"]
var deck = []
var player_hand = []
var dealer_hand = [] 

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

func _ready() -> void:
	new_deck()
	
	deal_card().position = $PlayerHand/Card1.global_position
	deal_card().position = $PlayerHand/Card2.global_position
	
	deal_card().position = $DealerHand/DCard1.global_position
	deal_card().position = $DealerHand/DCard2.global_position
	
	
