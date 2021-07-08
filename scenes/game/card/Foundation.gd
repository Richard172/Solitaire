class_name Foundation
extends Position2D

signal area_clicked

var suit : String
var suit_index : int

var area_entered : bool = false


func _input(event):
	if event is InputEventMouseButton and event.get_button_index() == BUTTON_LEFT \
	 		and event.is_pressed() and area_entered:
		emit_signal("area_clicked", self)


func _on_ClickArea_mouse_entered():
	area_entered = true


func _on_ClickArea_mouse_exited():
	area_entered = false


# set the sprite of the foundation
func set_sprite(name : String):
	var texture_loaded = load("res://assets/Cards/card" + name + "A.png")
	var sprite = $Sprite
	sprite.texture = texture_loaded


func disable_click_area():
	var click_area = $ClickArea
	click_area.get_node("Full").set_disabled(true)


func enable_click_area():
	var click_area = $ClickArea
	click_area.get_node("Full").set_disabled(false)
