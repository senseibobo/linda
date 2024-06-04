class_name BreadGrandma
extends Enemy


func _ready():
	super()
	sprite.play(["1","2","3"].pick_random())
	#add_weapon(preload("res://entities/weapons/bread.tscn").instantiate())
