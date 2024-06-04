class_name StickWeapon
extends Weapon

@export var damage: int = 1

@export var animation_player: AnimationPlayer
@onready var hitbox: Area2D = %Hitbox


func on_attack(entity: Entity):
	animation_player.play("attack")


func process_ai(delta, entity: Entity):
	if Global.target:
		if Global.target.weapons_node.global_position.distance_to(entity.weapons_node.global_position) < 40.0:
			on_attack(entity)


func hit():
	for hitbox in hitbox.get_overlapping_areas():
		var entity: Entity = hitbox.owner
		if entity == owner: continue
		var dir = (owner.weapons_node.position-owner.base_weapons_node_position)\
		/owner.weapons_node_spacing
		entity.hit(dir * 200.0 * damage)
