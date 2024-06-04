class_name TargetItem
extends Item


func _ready():
	Global.target_item = self


func _physics_process(delta):
	velocity = velocity.move_toward(Vector2(), delta*1000.0)
	var collision = move_and_collide(velocity * delta)
	if collision:
		velocity = velocity.bounce(collision.get_normal())


func launch(from: Vector2, dir: Vector2):
	reparent(get_tree().current_scene)
	non_pickup_timer = 2.0
	global_position = from
	process_mode = Node.PROCESS_MODE_INHERIT
	collision_layer = 8
	collision_mask = 9
	#visible = true
	velocity = dir*300.0


func _picked_up(entity: Entity):
	process_mode = Node.PROCESS_MODE_DISABLED
	#visible = false
	entity.target_item = self
	collision_layer = 0
	collision_mask = 0
	reparent(entity)
	position = Vector2(0,-20)
	Global.target = entity
	z_index = 1
	#queue_free()
	
