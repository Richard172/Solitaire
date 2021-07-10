extends TextureButton

signal game_pause
signal game_unpause

var pause_icon : Texture = preload("res://assets/Icons/pause.png")
var resume_icon : Texture = preload("res://assets/Icons/forward.png")

onready var pause_panel = get_node("/root/Solitaire/PauseScreen")
onready var PauseSound : AudioStreamPlayer = get_node("/root/Switch")


func _ready():
	connect("game_pause", pause_panel, "_pause_game")
	connect("game_unpause", pause_panel, "_unpause_game")


func _on_Pause_pressed():
	PauseSound._set_playing(true)
	if get_tree().paused == false:
		emit_signal("game_pause")
		get_tree().paused = true
		set_normal_texture(resume_icon)
	elif get_tree().paused == true:
		emit_signal("game_unpause")
		get_tree().paused = false
		set_normal_texture(pause_icon)
