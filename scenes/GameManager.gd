extends Node

const STOCK_START_POSITION : Vector2 = Vector2(177, 290)
const TALON_START_POSITION : Vector2 = Vector2(177, 740)
const FOUNDATION_START_POSITION : Vector2 = Vector2 (1785, 250)
const FOUNDATION_Y_MARGIN : int = 250
const CARD_X_START_POSITION : int = 440
const CARD_Y_START_POSITION : int = 200
const CARD_X_MARGIN : int = 185
const CARD_Y_UNFLIPPED_MARGIN : int = 30
const CARD_Y_FLIPPED_MARGIN : int = 36

# all possible suits, and ranks. A deck of cards that hasn't been dealt
const SUITS : Array = ["Clubs", "Diamonds", "Spades", "Hearts"]
const RANKS : Array = ["A", "2", "3", "4", "5", "6", "7", "8", "9", "10", "J", "Q", "K"]
var deck : Array = Array()
var talon_pile : Array = Array()

var tableau : Array = [[], [], [], [], [], [], []]
var pile_start_array : Array = Array()

var foundation_scene_array : Array = Array()
var foundation_pile : Array = [[], [], [], []]

var card1 : Card = null
var card2 : Card = null

var initial_z_index : int = 0

var stock

var CardBack = preload("res://assets/Cards/cardBack_blue5.png")
var CardScene = preload("res://scenes/game/card/Card.tscn")
var PileStartScene = preload("res://scenes/game/card/PileStart.tscn")
var StockScene = preload("res://scenes/game/card/Stock.tscn")
var FoundationScene = preload("res://scenes/game/card/Foundation.tscn")

onready var GameScene : Node2D = get_node("/root/Solitaire/Game")
onready var tween : Tween = get_node("/root/Solitaire/Game/Tween")
# Called when the node enters the scene tree for the first time, which is at first
func _ready():
	# randomize the seed
	randomize()
	_fill_deck()
	_deal_deck_tableau()
	_set_pile_start()
	_set_stock()
	_set_foundation()


# fill the entire deck with 52 cards, called at the start of the game
func _fill_deck():
	# for each suit and rank, create a new variation of the card, and put it in deck
	for suit in SUITS:
		for rank in RANKS:
			var card = CardScene.instance()
			# set up the card class
			card.suit = suit
			card.rank = rank
			card.back = CardBack
			card.front = load("res://assets/Cards/card" + suit + rank + ".png")
			card.is_flipped = false
			
			# connect the card so that when the card is clicked, it will be selected
			card.connect("card_clicked", self, "_select_card")
			
			deck.push_back(card)
	
	# randomly suffle the deck
	deck.shuffle()


# deal the deck to tableau
func _deal_deck_tableau():
	# for each card needed in the piles, take it from the deck
	for pile_index in range(tableau.size()):
		for card_index in range(pile_index + 1):
			var card = deck.pop_back()
			# add card to the game scene
			GameScene.add_child(card)
			# introduce the card into the game scene, set their card index
			_set_card_index(card, pile_index, card_index)
			
			# if the card is most top card, then increase flipped card distance, flip the card
			# and set the card so it can be placed on top
			if card_index == pile_index:
				card.is_flipped = true
				card.can_be_placed_on_top = true
			
			card.global_position = STOCK_START_POSITION
			
			# change the card's x position
			_set_card_x_position(card, pile_index)
			
			
			card.global_position.y = CARD_Y_START_POSITION + card_index * CARD_Y_UNFLIPPED_MARGIN
			
			# push the card into tableau array
			tableau[pile_index].push_back(card)


# set up pile start scene for all 7 piles
func _set_pile_start():
	# for all 7 piles, initiate the scene
	for index in range(7):
		var start_scene = PileStartScene.instance()
		GameScene.add_child(start_scene)
		
		# change the scene pile index, x y global position, and z_index to -1
		start_scene.pile_index = index
		start_scene.global_position.x = CARD_X_START_POSITION + CARD_X_MARGIN * index
		start_scene.global_position.y = CARD_Y_START_POSITION
		start_scene.z_index = -1
		
		# connect the start scene, so when the user clicks on the area, run select pile start method
		start_scene.connect("area_clicked", self, "_select_pile_start")
		
		# append the 
		pile_start_array.append(start_scene)


# set up the stock
func _set_stock():
	stock = StockScene.instance()
	GameScene.add_child(stock)
	
	stock.global_position = STOCK_START_POSITION
	stock.connect("area_clicked", self, "_reset_card_to_talon")


# set up the foundation in an array
func _set_foundation():
	for index in range(SUITS.size()):
		# create a instance of foundation, add to the game scene as a child
		var foundation = FoundationScene.instance()
		GameScene.add_child(foundation)
		# set up foundation's suit, and position, index
		foundation.suit = SUITS[index]
		foundation.global_position = FOUNDATION_START_POSITION
		foundation.global_position.y += index * FOUNDATION_Y_MARGIN
		foundation.suit_index = index
		# set up foundation's sprite
		foundation.set_sprite(SUITS[index])
		# connect the click signal
		foundation.connect("area_clicked", self, "_select_foundation")
		# append the foundation scene into an array
		foundation_scene_array.append(foundation)


# set the pile index, card index of the file
# set the z index to get the card rendering position right
func _set_card_index(card, pile_index, card_index):
	card.pile_index = pile_index
	card.card_index = card_index
	card.z_index = card_index


# if the last card is a flipped card
# the card y position is increased based on last card except the first card
func _set_card_y_position(card, pile_index, card_index):
	if card_index == 0:
		card.global_position.y = CARD_Y_START_POSITION
	elif card_index > 0:
		card.global_position.y = tableau[pile_index][card_index - 1].global_position.y + CARD_Y_FLIPPED_MARGIN
	
	# set the new card's index
	_set_card_index(card, pile_index, card_index)


# set the x position of the card, probably not use it much
func _set_card_x_position(card, pile_index):
	card.global_position.x = CARD_X_START_POSITION + pile_index * CARD_X_MARGIN


# check if the card1 and card2 are in different color
func _check_color_condition() -> bool :
	if (card1.suit == "Hearts" or card1.suit == "Diamonds") and \
			(card2.suit == "Spades" or card2.suit == "Clubs"):
		return true
	elif (card2.suit == "Hearts" or card2.suit == "Diamonds") and \
			(card1.suit == "Spades" or card1.suit == "Clubs"):
		return true
	else:
		return false


# check if card1 is one rank under card2
func _check_rank_condition() -> bool :
	var index : int = RANKS.find(card1.rank)
	if index == -1:
		print("Error in _check_rank_condition, index -1")
	if card1.rank == "K":
		return false
	elif RANKS[index + 1] == card2.rank:
		return true
	else:
		return false


# move the card's location to a new one, from card_1 to card_2
func _move_card(card_1, card_2):
	var pile_size = tableau[card_1.pile_index].size()
	
	var card_1_original_card_index = card_1.card_index
	var card_1_original_pile_index = card_1.pile_index
	
	# if the card is at the very back, enable the pile start scene's click area
	if card_1.card_index == 0:
		var click_area = pile_start_array[card_1_original_pile_index].get_node("ClickArea")
		click_area.get_node("Full").set_disabled(false)
	
	# if the card is not at the very back, flip the previous card
	# The previous card is now on top
	elif card_1.card_index > 0:
		var previous_card = tableau[card_1.pile_index][card_1.card_index - 1]
		
		if not previous_card.is_flipped:
			previous_card.is_flipped = true
		previous_card.can_be_placed_on_top = true
	
	# card 2 can no longer be placed on top
	card_2.can_be_placed_on_top = false
	
	# for each card under card 1 (including card 1)
	# remove the card at the card1 initial pile, initial index, set that card to a variable
	# change the y and x position of the removed card to the card 2 pile
	# append the removed card onto the card 2 pile
	for card_index in range(card_1_original_card_index, pile_size):
		var removed_card = tableau[card_1_original_pile_index][card_1_original_card_index]
		tableau[card_1_original_pile_index].remove(card_1_original_card_index)
		_set_card_y_position(removed_card, card_2.pile_index, tableau[card_2.pile_index].size())
		_set_card_x_position(removed_card, card_2.pile_index)
		tableau[card_2.pile_index].append(removed_card)


# reset the talon cards, used for _select_card
func _reset_talon():
	for index in range(min(talon_pile.size(), 3)):
		# define the card to be the first 3 card in talon, add the card to game scene
		var card = talon_pile[index]
		GameScene.add_child(card)
		
		card.pile_index = -1
		# set the z index to arrange the rendering order
		card.z_index = 3 - index
		
		# set the global position of the card from front to bottom, flip the card
		card.global_position = TALON_START_POSITION + Vector2(0, 2 * 36) - Vector2(0, index * 36)
		card.is_flipped = true
		
		if index == 0:
			card.clickable = true
		elif index != 0:
			card.clickable = false


# move the card from talon to card2 location
func _move_card_from_talon(card_1, card_2):
	# set the card from talon to be at the top, the second card moved to is no longer at top
	card_1.can_be_placed_on_top = true
	card_2.can_be_placed_on_top = false
	
	# remove the card from the talon pile
	var talon_index = talon_pile.find(card_1)
	talon_pile.remove(talon_index)
	
	# remove the talon's first and second index card from the game scene at max
	for index in range(min(talon_pile.size(), 2)):
		GameScene.remove_child(talon_pile[index])
	
	# reset the talon
	_reset_talon()
	
	# set the x, y position of card 1
	_set_card_y_position(card1, card2.pile_index, tableau[card2.pile_index].size())
	_set_card_x_position(card1, card2.pile_index)
	
	tableau[card2.pile_index].append(card1)


# check the card condition for the foundation
func _check_foundation_card_condition() -> bool:
	var index : int = RANKS.find(card2.rank)
	if index == -1:
		print("Error in _check_foundation_card_condition(), index -1")
	if card2.rank == "K":
		return false
	elif RANKS[index + 1] == card1.rank and card1.suit == card2.suit:
		return true
	else:
		return false


# move the card from talon to foudation, but with card in foundation
func _move_card_to_foundation_from_talon_with_card():
	
	# the suit index is the card2's card index
	var suit_index = card2.card_index
	
	card1.can_be_placed_on_top = true
	# set the card pile index to -2, and its card index to the suit index
	card1.pile_index = -2
	card1.card_index = suit_index
	if not foundation_pile[suit_index].empty():
		# remove the card from the talon pile
		var talon_index = talon_pile.find(card1)
		talon_pile.remove(talon_index)
		
		# remove the talon's first and second index card from the game scene at max
		for index in range(min(talon_pile.size(), 2)):
			GameScene.remove_child(talon_pile[index])
		# reset the talon
		_reset_talon()
		
		# set the card position to be on top of the foundation
		card1.global_position = card2.global_position
		# foundation pile adds one card
		foundation_pile[suit_index].append(card1)
		
		# game scene remove card 2
		GameScene.remove_child(card2)
	else:
		print("error in _move_card_to_foundation_from_talon_with_card()")


# move the card from tableau to foundation, but with card in foundation
func _move_card_to_foundation_from_tableau_with_card():
	# the suit index is the card2's card index
	var suit_index = card2.card_index
	
	if not foundation_pile[suit_index].empty():
		print(1)
		# if the card is at the very back, enable the pile start scene's click area
		if card1.card_index == 0:
			var click_area = pile_start_array[card1.pile_index].get_node("ClickArea")
			click_area.get_node("Full").set_disabled(false)
		# if the card is not at the very back, flip the previous card
		# The previous card is now on top
		elif card1.card_index > 0:
			var previous_card = tableau[card1.pile_index][card1.card_index - 1]
			
			if not previous_card.is_flipped:
				previous_card.is_flipped = true
			previous_card.can_be_placed_on_top = true
			
		# remove card1 from tableau
		tableau[card1.pile_index].remove(card1.card_index)
		
		# set the card position to be on top of the foundation
		card1.global_position = card2.global_position
		
		# foundation pile adds one card
		foundation_pile[suit_index].append(card1)
		
		# set the card pile index to -2, and its card index to the suit index
		card1.pile_index = -2
		card1.card_index = suit_index
		
		# remove card2
		GameScene.remove_child(card2)
	else:
		print("error in _move_card_to_foundation_from_talon_with_card()")


# move the card from foundation to tableau
func _move_card_to_tableau_from_foundation():
	# if the foundation pile has more than two cards, get the last card
	if foundation_pile[card1.card_index].size() > 1:
		var last_card_index
		last_card_index = foundation_pile[card1.card_index].size() - 2
	
		var last_card = foundation_pile[card1.card_index][last_card_index]
		GameScene.add_child(last_card)
	else:
		foundation_scene_array[card1.card_index].enable_click_area()
	
	# card 2 can't be placed on top now
	card2.can_be_placed_on_top = false
	
	# foundation pile remove card1
	foundation_pile[card1.card_index].pop_back()
	
	# set the x, y position of the card
	_set_card_y_position(card1, card2.pile_index, tableau[card2.pile_index].size())
	_set_card_x_position(card1, card2.pile_index)
	
	# tableau includes card1
	tableau[card2.pile_index].append(card1)


# when the card get clicked, this function runs, select the cards
func _select_card(card):
	# if there's no card1, select card1 if pile index is not from talon or not from foundation
	if card1 == null and card.pile_index != -1 and card.pile_index != -2:
		# change the card1 and below card's color
		card1 = card
		# disable all the card area below card1
		_change_pile_card_color(card1)
	# if the card1 is from talon
	elif card1 == null and (card.pile_index == -1 or card.pile_index == -2):
		card1 = card
		_change_card_color(card1)
	# if the first card selected is from talon, and the second card is in foundation
	elif card1.pile_index == -1 and card.pile_index == -2:
		card2 = card
		if _check_foundation_card_condition():
			_move_card_to_foundation_from_talon_with_card()
		
		_change_back_card_color(card1)
		card1 = null
		card2 = null
	# if the first card selected is from tableau, and the second card is in foundation
	elif card1.pile_index != -1 and card1.pile_index != -2 and card.pile_index == -2 and card.can_be_placed_on_top:
		card2 = card
		if _check_foundation_card_condition():
			_move_card_to_foundation_from_tableau_with_card()
			_change_back_card_color(card1)
		else:
			_change_back_pile_card_color(card1)
		card1 = null
		card2 = null
	# if the first card selected is from the talon, and the second card isn't in foundation
	elif card1.pile_index == -1 and card1.pile_index != -2 and card.can_be_placed_on_top:
		card2 = card
		if _check_color_condition() and _check_rank_condition():
			_move_card_from_talon(card1, card2)
		_change_back_card_color(card1)
		
		card1 = null
		card2 = null
	# if the user's first card is from talon, but the second card can't be placed on top
	elif card1.pile_index == -1 and not card.can_be_placed_on_top:
		_change_back_card_color(card1)
		card1 = null
	# if the user's first card is from foundation, and the second card is in tableau
	elif card1.pile_index == -2 and card.pile_index != -1 and card.pile_index != -2 and card.can_be_placed_on_top:
		card2 = card
		if _check_color_condition() and _check_rank_condition():
			_move_card_to_tableau_from_foundation()
		_change_back_card_color(card1)
		card1 = null
		card2 = null
	# if the user's first card is from foundation, but the second card isn't in tableau
	elif card1.pile_index == -2:
		_change_back_card_color(card1)
		card1 = null
	# if the user click on the same card pile again, reset the user's click
	elif card1.pile_index == card.pile_index:
		_change_back_pile_card_color(card1)
		card1 = null
	# if there's card1, but no card2, and the new card can be put on top by another card
	# then set the card2 to be the new card
	elif card2 == null and card.can_be_placed_on_top:
		card2 = card
		# check if card1 and card2 are in different color
		# check if card1 is one rank less than card2
		# if they are, then move the card, else don't move the card
		if _check_color_condition() and _check_rank_condition():
			# move card1 to card2 location
			_move_card(card1, card2)
		# change the card color back
		_change_back_pile_card_color(card1)
		
		# reset card1 and card2
		card1 = null
		card2 = null
	# if there's no card2, but card2 can't be placed on top
	elif card2 == null and not card.can_be_placed_on_top:
		# if card2 can't be put on top, print it
		_change_back_card_color(card1)
		card1 = null
	else:
		# otherwise, print an error message
		print("error in _select_card")


# called by the call back function to move cards onto empty pile
func _move_card_to_empty_pile(pile):
	var pile_size = tableau[card1.pile_index].size()
	
	# disable the pile's clickable area
	pile.get_node("ClickArea").get_node("Full").set_disabled(true)
	
	var card_1_original_card_index = card1.card_index
	var card_1_original_pile_index = card1.pile_index
	
	# if card1 is the first card, enable the pile start scene
	if card1.card_index == 0:
		var click_area = pile_start_array[card_1_original_pile_index].get_node("ClickArea")
		click_area.get_node("Full").set_disabled(false)
	# if the card is not at the very back and the card isn't flipped, flip the previous card
	# The previous card is now on top
	elif card_1_original_card_index > 0:
		var previous_card = tableau[card_1_original_pile_index][card_1_original_card_index - 1]
		
		if not previous_card.is_flipped:
			previous_card.is_flipped = true
		previous_card.can_be_placed_on_top = true
	
	
	# for each card under card 1 (including card 1)
	# remove the card at the card1 initial pile, initial index, set that card to a variable
	# change the y and x position of the removed card to the pile
	# append the removed card onto the pile
	for card_index in range(card_1_original_card_index, pile_size):
		var removed_card = tableau[card_1_original_pile_index][card_1_original_card_index]
		tableau[card_1_original_pile_index].remove(card_1_original_card_index)
		_set_card_y_position(removed_card, pile.pile_index, tableau[pile.pile_index].size())
		_set_card_x_position(removed_card, pile.pile_index)
		tableau[pile.pile_index].append(removed_card)


# move the card from talon to empty pile
func _move_card_to_empty_pile_from_talon(pile):
	# disable the pile area
	pile.get_node("ClickArea").get_node("Full").set_disabled(true)
	# card 1 is now on top
	card1.can_be_placed_on_top = true
	
	# remove the card from the talon pile
	var talon_index = talon_pile.find(card1)
	talon_pile.remove(talon_index)
	
	# remove the talon's first and second index card from the game scene at max
	for index in range(min(talon_pile.size(), 2)):
		GameScene.remove_child(talon_pile[index])
	
	# reset the talon
	_reset_talon()
	
	# set the x, y position of card 1
	_set_card_y_position(card1, pile.pile_index, tableau[pile.pile_index].size())
	_set_card_x_position(card1, pile.pile_index)
	
	tableau[pile.pile_index].append(card1)


# move the card from foundation to empty pile
func _move_card_to_empty_pile_from_foundation(pile):
	# disable the pile area
	pile.get_node("ClickArea").get_node("Full").set_disabled(true)
	# if the foundation pile has more than two cards, get the last card
	if foundation_pile[card1.card_index].size() > 1:
		var last_card_index
		last_card_index = foundation_pile[card1.card_index].size() - 2
	
		var last_card = foundation_pile[card1.card_index][last_card_index]
		GameScene.add_child(last_card)
	else:
		foundation_scene_array[card1.card_index].enable_click_area()
	
	# foundation pile remove card1
	foundation_pile[card1.card_index].pop_back()
	
	# set the x, y position of the card
	_set_card_y_position(card1, pile.pile_index, tableau[pile.pile_index].size())
	_set_card_x_position(card1, pile.pile_index)
	
	# tableau includes card1
	tableau[pile.pile_index].append(card1)


# describes what happens when the user click on the pile start scene
func _select_pile_start(pile):
	# if card1 is null, says that a first card has to be selected
	if card1 == null and card2 == null:
		print("The first card hasn't been selected")
	# if card1 is not selected and card2 is selected, return an error message
	elif card1 == null and card2 != null:
		print("Error in _select pile start, card2 is not null, but card1 is")
	# if card1 is from talon, and card2 is not selected, and rank is K
	elif card1.pile_index == -1 and card2 == null:
		if card1.rank == "K":
			# move the card to the empty pile from talon
			_move_card_to_empty_pile_from_talon(pile)
		_change_back_card_color(card1)
		card1 = null
	# if card1 is from foundation, and card2 is not selected
	elif card1.pile_index == -2 and card2 == null:
		if card1.rank == "K":
			_move_card_to_empty_pile_from_foundation(pile)
		_change_back_card_color(card1)
		card1 = null
	# if the first card is selected in tableau, but the second card isn't, run this
	# card1 can only be put on pile if the rank is K
	elif card1.pile_index != -1 and card1.pile_index != -2 and card2 == null and card1.rank == "K":
		# move the card to the empty pile
		_move_card_to_empty_pile(pile)
		# change the card color back to its original
		_change_back_pile_card_color(card1)
		# reset card1
		card1 = null
	elif card1 != null and card2 == null:
		# change the card color back to its original
		_change_back_pile_card_color(card1)
		# reset card1
		card1 = null
		print("The card is not K")
	else:
		print("Error in _select_pile_start")


# move the card from talon to foundation
func _move_card_to_foundation_from_talon(foundation : Foundation) -> void:
	# -2 pile index means the card is in foundation
	card1.pile_index = -2
	card1.card_index = foundation.suit_index
	card1.can_be_placed_on_top = true
	if foundation_pile[foundation.suit_index].empty():
		foundation.disable_click_area()
		
		# remove the card from the talon pile
		var talon_index = talon_pile.find(card1)
		talon_pile.remove(talon_index)
		
		# remove the talon's first and second index card from the game scene at max
		for index in range(min(talon_pile.size(), 2)):
			GameScene.remove_child(talon_pile[index])
		# reset the talon
		_reset_talon()
		# set the card position to be on top of the foundation
		card1.global_position = foundation.global_position
		# foundation pile adds one card
		foundation_pile[foundation.suit_index].append(card1)
	else:
		print("Error in _move_card_to_foundation_from_talon")


# move the card from tableau to foundation
func _move_card_to_foundation_from_tableau(foundation: Foundation) -> void:
	if foundation_pile[foundation.suit_index].empty():
		# disable foundation's click area
		foundation.disable_click_area()
		# if the card is at the very back, enable the pile start scene's click area
		if card1.card_index == 0:
			var click_area = pile_start_array[card1.pile_index].get_node("ClickArea")
			click_area.get_node("Full").set_disabled(false)
		# if the card is not at the very back, flip the previous card
		# The previous card is now on top
		elif card1.card_index > 0:
			var previous_card = tableau[card1.pile_index][card1.card_index - 1]
			
			if not previous_card.is_flipped:
				previous_card.is_flipped = true
			previous_card.can_be_placed_on_top = true
		# remove card1 from tableau
		tableau[card1.pile_index].remove(card1.card_index)
		# set card1 position to be foundation's position
		card1.global_position = foundation.global_position
		# append card1 onto foundation
		foundation_pile[foundation.suit_index].append(card1)
		# set card1's pile index and card index to foundation's
		card1.pile_index = -2
		card1.card_index = foundation.suit_index
	else:
		print("Error in _move_card_to_foundation_from_talon")


func _check_foundation_start_card(foundation) -> bool:
	return card1.rank == "A" and card1.suit == foundation.suit


# describes what happens when the user clicks on the foundation
func _select_foundation(foundation):
	# if both cards are not selected
	if card1 == null and card2 == null:
		pass
	# card1 is not selected, but card2 is, should be a impossible case
	elif card1 == null and card2 != null:
		print("Error in _select foundation, card2 is not null, but card1 is")
	# if card1 is from talon, but card2 is not
	elif card1.pile_index == -1 and card2 == null:
		
		if _check_foundation_start_card(foundation):
			# move the card from talon to foundation, change the card color back, set card to null
			_move_card_to_foundation_from_talon(foundation)
		_change_back_card_color(card1)
		card1 = null
	# if card1 is not from talon, but from tableau instead, there's no card2
	elif card1.pile_index != -1 and card1.pile_index != -2 and card2 == null:
		# if card1 is at top of the tableau, move the card to foundation
		# and disable the card color
		# else disable the pile card color
		if card1.can_be_placed_on_top:
			if _check_foundation_start_card(foundation):
				_move_card_to_foundation_from_tableau(foundation)
			_change_back_card_color(card1)
		else:
			_change_back_pile_card_color(card1)
		card1 = null
	# if card1 is from foundation, cancel the selection
	elif card1.pile_index == -2:
		_change_back_card_color(card1)
		card1 = null


# change a pile of card color
func _change_pile_card_color(card):
	var pile_size = tableau[card.pile_index].size()
	
	for card_index in range(card.card_index, pile_size):
		var new_card = tableau[card.pile_index][card_index]
		_change_card_color(new_card)


# change the color of the card
func _change_card_color(card):
	card.set_modulate(Color(0.5, 0.5, 0.5, 1))


# change back a pile of card color
func _change_back_pile_card_color(card):
	var pile_size = tableau[card.pile_index].size()
	
	for card_index in range(card.card_index, pile_size):
		var new_card = tableau[card.pile_index][card_index]
		_change_back_card_color(new_card)


# change the color of the card back
func _change_back_card_color(card):
	card.set_modulate(Color(1, 1, 1, 1))


# reset the deck by shuffle the cards in talon pile into deck
func _reset_deck():
	deck = talon_pile.duplicate()
	talon_pile.clear()
	stock.has_card = true


# reset the card each time stock is clicked
func _reset_card_to_talon():
	
	# remove at max 3 cards from the game scene
	for index in range(min(talon_pile.size(), 3)):
		if GameScene.is_a_parent_of(talon_pile[index]):
			GameScene.remove_child(talon_pile[index])
	
	# if all the cards from stock are used up
	if deck.empty() and talon_pile.empty():
		print("There are no more cards in the stock")
	# if deck is empty, but talon pile isn't empty, reset the deck
	elif deck.empty() and !talon_pile.empty():
		_reset_deck()
	else:
		# if a card is selected and then press reset, that card gets removed
		if card1 != null:
			_change_back_card_color(card1)
			card1 = null
		# pop maximum of 3 cards from the deck, set their pile index to -1
		# append them in the front of the talon pile
		var deck_size = deck.size()
		
		for index in range(min(deck.size(), 3)):
			var card = deck.pop_back()
			GameScene.add_child(card)
			
			card.pile_index = -1
			# set the z index to arrange the rendering order
			card.z_index = index
			
			# set the global position of the card from front to bottom, flip the card
			card.global_position = STOCK_START_POSITION
			
			var card_global_position = TALON_START_POSITION + Vector2(0, index * 36)
			
			tween.interpolate_property(card, "global_position",
					card.global_position, card_global_position, 0.10,
					Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
			tween.start()
			
			card.is_flipped = true
			
			# if the card is at the very front, enable it to be clickable, else not
			if index == min(deck_size, 3) - 1:
				card.clickable = true
			elif index != min(deck_size, 3) - 1:
				card.clickable = false
			
			talon_pile.push_front(card)
	
	# if the deck is empty, set the has card property of stock to false
	if deck.empty():
		stock.has_card = false


# delete the entire deck of cards
func _delete_deck():
	for card in deck:
		card.queue_free()
	deck = Array()


func _delete_talon():
	for card in talon_pile:
		card.queue_free()
	talon_pile = Array()


func _delete_stock():
	stock.queue_free()


func _delete_tableau():
	for pile in tableau:
		for card in pile:
			card.queue_free()
	tableau = [[], [], [], [], [], [], []]
	
	for pile_start in pile_start_array:
		pile_start.queue_free()
	pile_start_array = Array()


func _delete_foundation():
	for foundation in foundation_pile:
		for card in foundation:
			card.queue_free()
	foundation_pile = [[], [], [], []]
	
	for foundation_scene in foundation_scene_array:
		foundation_scene.queue_free()
	foundation_scene_array = Array()


func _restart_game():
	_delete_deck()
	_delete_talon()
	_delete_stock()
	_delete_tableau()
	_delete_foundation()
	
	_fill_deck()
	_deal_deck_tableau()
	_set_pile_start()
	_set_stock()
	_set_foundation()
