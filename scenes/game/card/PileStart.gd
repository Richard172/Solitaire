class_name PileStart
extends Position2D

signal area_clicked(pile)

# check whether the mouse entered the area
var area_entered : bool = false

var pile_index : int

func _input(event):
	if event is InputEventMouseButton and event.get_button_index() == BUTTON_LEFT \
	 		and event.is_pressed() and area_entered:
		emit_signal("area_clicked", self)

func _on_Area2D_mouse_entered():
	area_entered = true


func _on_Area2D_mouse_exited():
	area_entered = false
