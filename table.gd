extends Node2D
@export var card: PackedScene

var suits = ["Purple", "Blue"]
var ranks = ["Ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "Jack", "Queen", "King"]
var deck = []
var player_hand = []
var dealer_hand = []
var player_score = 0
var dealer_score = 0
var dealer_hidden = null
var player_turn = false
var money = 100
var bet = 50

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
	player_turn = false
	for card in player_hand:
		var tween = create_tween()
		tween.tween_property(card, "position:x", card.position.x - 200, 0.75)
	var new_card = deal_card()
	player_hand.append(new_card)
	new_card.position = $PlayerHand/Card2.global_position
	await new_card.flip()
		
	player_score = hand_value(player_hand)
	if player_score > 21:
		$result.text = "Bust"
		round_over("d")
	else:
		player_turn = true

func dealer_hit():
	for card in dealer_hand:
		var tween = create_tween()
		tween.tween_property(card, "position:x", card.position.x - 200, 1.0)
	var new_card = deal_card()
	dealer_hand.append(new_card)
	new_card.position = $DealerHand/DCard2.global_position
	await new_card.flip()
	
func stand():
	player_turn = false
	await dealer_hidden.flip()
	while hand_value(dealer_hand) < 17:
		await get_tree().create_timer(0.5).timeout
		await dealer_hit()
		
	dealer_score = hand_value(dealer_hand)
	await get_tree().create_timer(0.5).timeout
	
	if dealer_score > 21:
		$result.text = "Dealer Busts"
		round_over("p")
	elif player_score > dealer_score:
		$result.text = "Player wins"
		round_over("p")
	elif dealer_score > player_score:
		$result.text = "Dealer Wins" 
		round_over("d")
	else:
		$result.text = "Push"
		round_over("t")
		
func round_over(winner):
	if winner == "p":
		money += 2 * bet
	elif winner == "t":
		money += bet
	elif winner == "b":
		money += 2.5 * bet
		
	if money <= 0:
		you_lose()
	else:
		$playAgain.show()
		
func clear_cards():
	for card in player_hand:
		card.queue_free()
	for card in dealer_hand:
		card.queue_free()
	player_hand.clear()
	dealer_hand.clear()
		
func new_round():
	$PlayerHand/betSlider.hide()
	new_deck()
	
	var new_card = deal_card()
	player_hand.append(new_card)
	new_card.position = $PlayerHand/Card1.global_position
	await new_card.flip()
	
	new_card = deal_card()
	player_hand.append(new_card)
	new_card.position = $PlayerHand/Card2.global_position
	await new_card.flip()
	
	new_card = deal_card()
	dealer_hand.append(new_card)
	new_card.position = $DealerHand/DCard1.global_position
	await new_card.flip()
	
	dealer_hidden = deal_card()
	dealer_hand.append(dealer_hidden)
	dealer_hidden.position = $DealerHand/DCard2.global_position
	await get_tree().create_timer(0.5).timeout
	
	if player_score == 21:
		blackjack()
	else:
		player_turn = true

func make_bet():
	$PlayerHand/betSlider.show()
	$PlayerHand/betSlider.max_value = money
	
func you_lose():
	await get_tree().create_timer(2.5).timeout
	for child in get_children():
		child.hide()
	$youLose.show()
	await get_tree().create_timer(2.5).timeout
	get_tree().quit()
	
func blackjack():
	await dealer_hidden.flip()
	if dealer_score != 21:
		round_over("b")
		$result.text = "Blackjack!"
	else:
		round_over("t")
		$result.text = "Push"

func _ready() -> void:
	await get_tree().create_timer(2.0).timeout
	$title.hide()
	$PlayerHand/money.show()
	make_bet()
	

func _input(event):
	if Input.is_action_just_pressed("stand") and player_turn:
		stand()
	if Input.is_action_just_pressed("hit") and player_turn:
		hit()
	if Input.is_action_just_pressed("hit") and $PlayerHand/betSlider.is_visible_in_tree():
		_on_bet_button_pressed()
	if Input.is_action_just_pressed("new_round") and $playAgain.is_visible_in_tree():
		_on_play_again_pressed()


func _process(delta: float) -> void:
	$PlayerHand/money.text = "$" + str(roundi(money))
	player_score = hand_value(player_hand)
	dealer_score = hand_value(dealer_hand)
	$PlayerHand/total.text = ("Score:" + str(player_score))
	$DealerHand/dtotal.text = ("Score:" + str(dealer_score))
	
	if player_turn:
		$PlayerHand/hit.show()
		$PlayerHand/stand.show()
	else:
		$PlayerHand/hit.hide()
		$PlayerHand/stand.hide()
	
	if player_hand.is_empty():
		$PlayerHand/total.hide()
	else:
		$PlayerHand/total.show()
	
	if dealer_hand.is_empty():
		$DealerHand/dtotal.hide()
	else:
		$DealerHand/dtotal.show()


func _on_play_again_pressed() -> void:
	player_turn = false
	clear_cards()
	$result.text = ""
	$playAgain.hide()
	make_bet()

func _on_hit_pressed() -> void:
	hit()

func _on_stand_pressed() -> void:
	stand()

func _on_bet_button_pressed() -> void:
	money -= bet
	new_round()

func _on_bet_slider_value_changed(value: float) -> void:
	bet = int(value)
	$PlayerHand/betSlider/betButton.text = "Bet $" + str(bet)
