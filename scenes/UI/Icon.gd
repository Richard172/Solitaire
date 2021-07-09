extends TextureRect

const audio_off_sprite = preload("res://assets/Icons/audioOff.png")
const audio_on_sprite = preload("res://assets/Icons/audioOn.png")

var is_volume_on : bool = true setget set_volume

signal turn_volume_off
signal turn_volume_on


func set_volume(value):
	is_volume_on = value
	if not is_volume_on:
		emit_signal("turn_volume_off")
	else:
		
		emit_signal("turn_volume_on")
