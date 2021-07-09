extends HBoxContainer


onready var icon = $Icon
onready var audio_bar = $CenterContainer/AudioBar

var is_mouse_on_icon : bool = false
var is_mouse_on_audio_bar : bool = false
var is_dragging_audio_bar : bool = false


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
		# if the mouse is on the icon and the user clicks the button
			if is_mouse_on_icon:
				icon.is_volume_on = false if icon.is_volume_on else true
			# if the user is not dragging, and it left clicks and hold on the audio bar, set the drag the audio bar to true
			if not is_dragging_audio_bar and is_mouse_on_audio_bar:
				is_dragging_audio_bar = true
		# if the user clicks/unclicks, and is not draggin on the audio bar, set the drag audio bar to false
		if is_dragging_audio_bar and not event.pressed:
			is_dragging_audio_bar = false
		
	# if the user is dragging the audio bar, drag the bar
	if is_dragging_audio_bar:
		_drag_audio_bar()


func _drag_audio_bar():
	# get the relative position of the audio bar when the mouse clicks
	var audio_bar_x = audio_bar.get_local_mouse_position().x
	# audio_bar x value divides audio bar x size, and times it by the max value to get current value
	audio_bar.value = (audio_bar_x / audio_bar.rect_size.x) * audio_bar.max_value



func _on_AudioBar_value_changed(value):
	if value == 0:
		icon.is_volume_on = 0
	if value != 0:
		icon.texture = icon.audio_on_sprite


func _on_AudioBar_mouse_entered():
	is_mouse_on_audio_bar = true


func _on_AudioBar_mouse_exited():
	is_mouse_on_audio_bar = false


func _on_Icon_turn_volume_off():
	icon.texture = icon.audio_off_sprite
	audio_bar.value = 0


func _on_Icon_turn_volume_on():
	icon.texture = icon.audio_on_sprite
	audio_bar.value = 25


func _on_Icon_mouse_entered():
	is_mouse_on_icon = true


func _on_Icon_mouse_exited():
	is_mouse_on_icon = false
