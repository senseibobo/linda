extends Node2D


func activate_enemies():
	get_tree().call_group("enemy", "set_state", Entity.State.WALKING)
