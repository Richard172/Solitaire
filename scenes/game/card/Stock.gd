extends Position2D

signal area_clicked

var area_entered : bool = false
var has_card : bool = true setget change_modulate


func change_modulate(value):
	has_card = value
	if value == true:
		set_modulate(Color(1, 1, 1, 1))
	if value == false:
		set_modulate(Color(0.5, 0.5, 0.5, 0.5))


func _input(event):
	if event is InputEventMouseButton and event.get_button_index() == BUTTON_LEFT \
	 		and event.is_pressed() and area_entered:
		emit_signal("area_clicked")


func _on_ClickArea_mouse_entered():
	area_entered = true


func _on_ClickArea_mouse_exited():
	area_entered = false
