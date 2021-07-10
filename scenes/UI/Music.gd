extends HBoxContainer

const MIN_VOLUME : float = 0.0
const MAX_VOLUME : float = 10.0

var is_mouse_on_icon : bool = false
var is_mouse_on_music_bar : bool = false
var is_dragging_music_bar : bool = false

onready var icon = $Icon
onready var music_bar = $CenterContainer/MusicBar
onready var background_music = get_node("/root/BackgroundMusic")


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
		# if the mouse is on the icon and the user clicks the button
			if is_mouse_on_icon:
				icon.is_volume_on = false if icon.is_volume_on else true
			# if the user is not dragging, and it left clicks and hold on the audio bar, set the drag the audio bar to true
			if not is_dragging_music_bar and is_mouse_on_music_bar:
				is_dragging_music_bar = true
		# if the user clicks/unclicks, and is not draggin on the audio bar, set the drag audio bar to false
		if is_dragging_music_bar and not event.pressed:
			is_dragging_music_bar = false
		
	# if the user is dragging the audio bar, drag the bar
	if is_dragging_music_bar:
		_drag_music_bar()


func _drag_music_bar():
	# get the relative position of the audio bar when the mouse clicks
	var music_bar_x = music_bar.get_local_mouse_position().x
	# audio_bar x value divides audio bar x size, and times it by the max value to get current value
	music_bar.value = (music_bar_x / music_bar.rect_size.x) * music_bar.max_value


func _on_MusicBar_value_changed(value):
	if value == 0:
		icon.is_volume_on = 0
		if background_music.is_playing():
			background_music._set_playing(false)
	if value != 0:
		icon.texture = icon.music_on_sprite
		if not background_music.is_playing():
			background_music._set_playing(true)
	
	background_music.set_volume_db((MAX_VOLUME - MIN_VOLUME) * value / music_bar.max_value + MIN_VOLUME)


func _on_MusicBar_mouse_entered():
	is_mouse_on_music_bar = true


func _on_MusicBar_mouse_exited():
	is_mouse_on_music_bar = false


func _on_Icon_mouse_entered():
	is_mouse_on_icon = true


func _on_Icon_mouse_exited():
	is_mouse_on_icon = false


func _on_Icon_turn_volume_off():
	icon.texture = icon.music_off_sprite
	music_bar.value = 0


func _on_Icon_turn_volume_on():
	icon.texture = icon.music_on_sprite
	music_bar.value = 25
