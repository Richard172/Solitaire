extends Label

# how much seconds in 1 minute or 1 hour
const ONE_MINUTE : int = 60
const ONE_HOUR : int = 3600

var paused : bool = false

onready var time: float = 0.0


func _process(delta):
	if not paused:
		time += delta
	else:
		print("The timer is now paused")
	
	_show_timer()
	

func _show_timer():
	var hours : int = time / 60
	var minutes : int = fmod(time, ONE_HOUR) / 60
	var seconds : int = fmod(time, ONE_MINUTE)
	
	var text = "%02d:%02d:%02d"
	set_text(text % [hours, minutes, seconds])


func reset_timer():
	time = 0.0
