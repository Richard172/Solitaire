extends Label

const label_text : String = "MOVES: "
var counter : int = 0 setget increment_counter


func _ready():
	text = label_text + "0"


func increment_counter(value):
	counter = value
	text = label_text + str(counter)


func reset_counter():
	self.counter = 0
