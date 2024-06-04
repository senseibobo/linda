extends CanvasLayer


signal transitioned

var last_scene_path: String = "res://ui/main_menu.tscn"

@export var animation_player: AnimationPlayer


func transition_to(scene: PackedScene):
	last_scene_path = scene.resource_path
	var tween = create_tween()
	tween.tween_method(set_audio_volume, 1.0, 0.0, 1.0)
	tween.tween_method(set_audio_volume, 0.0, 1.0, 1.0)
	animation_player.play("transition")
	await transitioned
	get_tree().change_scene_to_packed(scene)


func set_audio_volume(volume: float):
	AudioServer.set_bus_volume_db(0, linear_to_db(volume))
