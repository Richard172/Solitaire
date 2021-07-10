extends TextureButton

onready var GameManager = get_node("/root/GameManager")
onready var RestartSound : AudioStreamPlayer = get_node("/root/Restart")


func _on_Restart_pressed():
	RestartSound._set_playing(true)
	GameManager._restart_game()
