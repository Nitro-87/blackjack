extends Node2D

var rank = null
var suit = null

func card_value() -> int:
	if rank in ["Jack", "Queen", "King"]:
		return 10
	elif rank == "Ace":
		return 11
	else:
		return int(rank)
		
func card_number() -> int:
	match rank:
		"Ace": return 1
		"Jack": return 11
		"Queen": return 12
		"King": return 13
		_: return int(rank)
		
func card_texture() -> String:
	var value = card_number()
	
	if suit == "Purple":
		value =  value*2
	elif suit == "Blue":
		value =  value*2-1
	return "res://godot-blackjack-main/Cards/sprite_" + str(value) + ".png"

func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	var new_texture = load(card_texture())
	$Sprite2D.texture = new_texture
