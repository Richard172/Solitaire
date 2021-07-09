extends Label

# how much seconds in 1 minute or 1 hour
const ONE_MINUTE : int = 60
const ONE_HOUR : int = 3600

var paused : bool = false
var time_text : String

onready var time: float = 0.0


func _process(delta):
	if not paused:
		time += delta
	else:
		print("The timer is now paused")
	
	_show_timer()
	

func _show_timer():
	var hours : int = time / ONE_HOUR
	var minutes : int = fmod(time / 60, 60)
	var seconds : int = fmod(time, ONE_MINUTE)
	
	var text = "%02d:%02d:%02d"
	time_text = text % [hours, minutes, seconds]
	set_text(time_text)


func reset_timer():
	time = 0.0
