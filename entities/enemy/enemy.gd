class_name Enemy
extends Entity


enum Behavior {
	GREEDY,
	HATEFUL
}

@export var behavior: Behavior = Behavior.GREEDY	
@onready var nav_agent: NavigationAgent2D = %NavigationAgent2D
@export var base_weapons_scenes: Array[PackedScene]
var hateful_target: Entity
var hateful_target_choice_cooldown: float = 0.0


func _ready():
	super()
	for base_weapon_scene in base_weapons_scenes:	
		add_weapon(base_weapon_scene.instantiate())
	


func _process_walking(delta):
	match behavior:
		Behavior.GREEDY: _process_walking_greedy(delta)
		Behavior.HATEFUL: _process_walking_hateful(delta)


func _process_walking_hateful(delta):
	hateful_target_choice_cooldown -= delta
	if not hateful_target or hateful_target_choice_cooldown <= 0:
		hateful_target_choice_cooldown = 3.0
		_choose_random_hateful_target()
	if is_instance_valid(hateful_target):
		_process_chase_target(hateful_target, delta)


func _choose_random_hateful_target():
	if Global.player:
		if randi()%4 == 0:
			hateful_target = Global.player
			return
	if Global.entities.size() > 1:
		while true:
			hateful_target = Global.entities.pick_random()
			if hateful_target != self: break


func _process_chase_target(target: Entity, delta):
	var angle: float = \
		(target.weapons_node.global_position - weapons_node.global_position).angle()
	update_weapons_node_position(angle)
	
	nav_agent.target_position = target.global_position
	var next_pos: Vector2 = nav_agent.get_next_path_position()
	var dir: Vector2 = (next_pos - global_position).normalized()
	move_dir(dir, delta)	
	trigger_weapons_attacks()


func _process_walking_greedy(delta):
	if Global.target == self:
		pass
	elif Global.target:
		_process_chase_target(Global.target, delta)
	elif Global.target_item:
		nav_agent.target_position = Global.target_item.global_position
		var next_pos: Vector2 = nav_agent.get_next_path_position()
		var dir: Vector2 = (next_pos - global_position).normalized()
		move_dir(dir, delta)
		
		for entity: Entity in Global.entities:
			if entity == self: continue
			if entity.global_position.distance_to(global_position) < 50:
				trigger_weapons_attacks()
