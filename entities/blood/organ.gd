extends RigidBody2D


@export var textures: Array[Texture2D]

func _ready():
	$Sprite2D.texture = textures.pick_random()
	apply_central_impulse(Vector2.RIGHT.rotated(randf()*TAU)*100.0*randf())
	var tween = create_tween()
	tween.tween_interval(4.0)
	tween.tween_property(self, "scale", Vector2(), 0.3)
	tween.tween_callback(queue_free)
