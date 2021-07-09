extends TextureButton

signal game_pause
signal game_unpause

onready var pause_panel = get_node("/root/Solitaire/PauseScreen")


func _ready():
	connect("game_pause", pause_panel, "_pause_game")
	connect("game_unpause", pause_panel, "_unpause_game")


func _on_Pause_pressed():
	if get_tree().paused == false:
		emit_signal("game_pause")
		get_tree().paused = true
	elif get_tree().paused == true:
		emit_signal("game_unpause")
		get_tree().paused = false
