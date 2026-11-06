extends Node2D
@export var card: PackedScene

var suits = ["Purple", "Blue"]
var ranks = ["Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King"]
var deck = []
var player_hand = []
var dealer_hand = [] 
var dealer_hidden = null
var player_turn = true

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
	
func hit():
	for card in player_hand:
		var tween = create_tween()
		tween.tween_property(card, "position:x", card.position.x - 200, 0.75)
	var new_card = deal_card()
	player_hand.append(new_card)
	new_card.position = $PlayerHand/Card2.global_position
	new_card.flip()

func dealer_hit():
	for card in dealer_hand:
		var tween = create_tween()
		tween.tween_property(card, "position:x", card.position.x - 200, 1.0)
	var new_card = deal_card()
	dealer_hand.append(new_card)
	new_card.position = $DealerHand/DCard2.global_position
	new_card.flip()
	
func stand():
	player_turn = false
	dealer_hidden.flip()
	await get_tree().create_timer(1.5).timeout
	while hand_value(dealer_hand) < 17:
		dealer_hit()
		await get_tree().create_timer(1.0).timeout
	

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
	
	dealer_hidden = deal_card()
	dealer_hand.append(dealer_hidden)
	dealer_hidden.position = $DealerHand/DCard2.global_position

func _input(event):
	if Input.is_action_just_pressed("stand") and player_turn:
		stand()
	if Input.is_action_just_pressed("hit") and player_turn:
		hit()

func _process(delta: float) -> void:
	if player_hand == null:
		$PlayerHand/total.text = ("Score:" + str(0))
	else:
		$PlayerHand/total.text = ("Score:" + str(hand_value(player_hand)))
	
	if dealer_hand == null:
		$DealerHand/dtotal.text = ("Score:" + str(0))
	else:
		$DealerHand/dtotal.text = ("Score:" + str(hand_value(dealer_hand)))
