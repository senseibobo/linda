extends CanvasLayer


signal transitioned

var last_scene_path: String = "res://ui/main_menu.tscn"

@export var animation_player: AnimationPlayer


func transition_to(scene: PackedScene):
	last_scene_path = scene.resource_path
	animation_player.play("transition")
	await transitioned
	get_tree().change_scene_to_packed(scene)
