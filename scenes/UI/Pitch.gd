extends HBoxContainer

const MIN_PITCH : float = 0.1
const MAX_PITCH : float = 4.0

var is_mouse_on_icon : bool = false
var is_mouse_on_pitch_bar : bool = false
var is_dragging_pitch_bar : bool = false

onready var icon = $PitchIcon
onready var pitch_bar = $CenterContainer/PitchBar
onready var background_music = get_node("/root/BackgroundMusic")


func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
		# if the mouse is on the icon and the user clicks the button
			if is_mouse_on_icon:
				icon.is_pitch_on = false if icon.is_pitch_on else true
			# if the user is not dragging, and it left clicks and hold on the audio bar, set the drag the audio bar to true
			if not is_dragging_pitch_bar and is_mouse_on_pitch_bar:
				is_dragging_pitch_bar = true
		# if the user clicks/unclicks, and is not draggin on the audio bar, set the drag audio bar to false
		if is_dragging_pitch_bar and not event.pressed:
			is_dragging_pitch_bar = false
		
	# if the user is dragging the audio bar, drag the bar
	if is_dragging_pitch_bar:
		_drag_music_bar()


func _drag_music_bar():
	# get the relative position of the audio bar when the mouse clicks
	var pitch_bar_x = pitch_bar.get_local_mouse_position().x
	# audio_bar x value divides audio bar x size, and times it by the max value to get current value
	pitch_bar.value = (pitch_bar_x / pitch_bar.rect_size.x) * pitch_bar.max_value


func _on_PitchBar_value_changed(value):
	if value == 0:
		background_music.set_pitch_scale(MIN_PITCH)
	if value != 0:
		background_music.set_pitch_scale((MAX_PITCH - MIN_PITCH) * value / pitch_bar.max_value + MIN_PITCH)


func _on_PitchBar_mouse_entered():
	is_mouse_on_pitch_bar = true


func _on_PitchBar_mouse_exited():
	is_mouse_on_pitch_bar = false


func _on_PitchIcon_mouse_entered():
	is_mouse_on_icon = true


func _on_PitchIcon_mouse_exited():
	is_mouse_on_icon = false


func _on_PitchIcon_turn_pitch_off():
	pitch_bar.value = 0


func _on_PitchIcon_turn_pitch_on():
	pitch_bar.value = 25

