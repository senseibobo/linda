extends Enemy


func _ready():
	super()
	sprite.play(str(randi()%3+1))
