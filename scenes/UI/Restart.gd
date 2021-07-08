extends TextureButton

onready var GameManager = get_node("/root/GameManager")


func _on_Restart_pressed():
	GameManager._restart_game()
