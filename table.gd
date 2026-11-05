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

func _ready() -> void:
	new_deck()
	
	var c1 = card.instantiate()
	add_child(c1)
	c1.position = $PlayerHand/Card1.global_position
	var card_data = deck.pop_back()
	c1.rank = card_data[0]
	c1.suit = card_data[1] 
	
	var c2 = card.instantiate()
	add_child(c2)
	c2.position = $PlayerHand/Card2.global_position
	card_data = deck.pop_back()
	c2.rank = card_data[0]
	c2.suit = card_data[1]
