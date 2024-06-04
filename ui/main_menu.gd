extends Control

@export var main: VBoxContainer
@export var options: VBoxContainer


func _on_play_pressed():
	Transition.transition_to(preload("res://levels/level_1.tscn"))


func _on_options_pressed():
	options.visible = true
	main.visible = false


func _on_quit_pressed():
	get_tree().quit()


func _on_options_back_pressed():
	options.visible = false
	main.visible = true
