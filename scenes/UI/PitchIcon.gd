extends TextureRect

var is_pitch_on : bool = true setget set_pitch

signal turn_pitch_off
signal turn_pitch_on


func set_pitch(value):
	is_pitch_on = value
	if not is_pitch_on:
		emit_signal("turn_pitch_off")
	else:
		emit_signal("turn_pitch_on")
