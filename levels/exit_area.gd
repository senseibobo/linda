extends Area2D

@export var next_scene: PackedScene

func _on_body_entered(body):
	if body is Player:
		if body.target_item and Global.entities.size() == 1:
			Transition.transition_to(next_scene)
