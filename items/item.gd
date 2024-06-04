class_name Item
extends CharacterBody2D

signal picked_up(entity: Entity)


var non_pickup_timer: float = 0.0


func _process(delta):
	non_pickup_timer -= delta
	if non_pickup_timer <= 0:
		var entity = Global.get_closest_entity(global_position)
		if entity:
			var closest_distance = global_position.distance_to(entity.global_position)
			if closest_distance < 30:
				_picked_up(entity)
				picked_up.emit(entity)
		
		

func _on_body_entered(body: Node):
	if body is Entity:
		_picked_up(body)
		picked_up.emit(body)


func _picked_up(body: Entity):
	pass
