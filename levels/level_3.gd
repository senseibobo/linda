extends Node2D

@export var enemies: Node2D


func _ready():
	remove_child(enemies)


func activate_enemies():
	add_child(enemies)
	get_tree().call_group("enemy", "set_state", Entity.State.WALKING)
