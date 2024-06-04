extends Node2D


@export var blood_textures: Array[Texture2D]

func _ready():
	$Blood.texture = blood_textures.pick_random()
	var tween = create_tween()
	var c = 0.2+randf()*0.35
	tween.tween_property(self, "modulate", Color(c,c,c,0.8), 13.0+randf()*5.0)
	
