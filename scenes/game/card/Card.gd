class_name Card
extends Position2D

# check if the card is clicked
signal card_clicked(card)

var suit : String
var rank : String
var front : Texture
var back : Texture
# it's true if the card is front, else false
# the card is unflipped by default
var is_flipped : bool = false setget flip_card

# whether the card allow other cards to be put on top
var can_be_placed_on_top : bool = false setget set_placed_on_top

# whether the card is clickable
var clickable : bool = true

# index of the card in the tableau
var pile_index : int
var card_index : int

var card_entered : bool = false


# if the card is flipped, change the texture to back, enable the clicking
# if the card is unflipped, change the texture to front, disable the clicking
func flip_card(value):
	is_flipped = value
	if value == true:
		$Sprite.texture = front
		$ClickArea.get_node("Full").set_disabled(false)
	elif value == false:
		$Sprite.texture = back
		$ClickArea.get_node("Full").set_disabled(true)


func set_placed_on_top(value):
	can_be_placed_on_top = value
	if value == true:
		set_to_full_click_area()
	if value == false:
		set_to_top_click_area()


func _ready():
	pass


func _input(event):
	# if the event is a mouse event, and it's left mouse button event, and it's pressed
	# and if the card is flipped, and if the card_entered is true
	# emit signal area clicked
	if event is InputEventMouseButton and event.get_button_index() == BUTTON_LEFT and event.is_pressed():
		if is_flipped and card_entered and clickable:
			emit_signal("card_clicked", self)


func set_to_full_click_area():
	$ClickArea.get_node("Full").set_disabled(false)
	$ClickArea.get_node("Top").set_disabled(true)


func set_to_top_click_area():
	$ClickArea.get_node("Full").set_disabled(true)
	$ClickArea.get_node("Top").set_disabled(false)


func _on_ClickArea_mouse_entered():
	card_entered = true


func _on_ClickArea_mouse_exited():
	card_entered = false
