extends CanvasLayer


func _on_animation_player_animation_finished(anim_name):
	Transition.transition_to(load(Transition.last_scene_path))
	await Transition.transitioned
	$Grayscale.material.set("shader_parameter/t",0.0)


func start():
	$AnimationPlayer.play("death")
