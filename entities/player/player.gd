class_name Player
extends Entity

const STICK_SCENE: PackedScene = preload("res://entities/weapons/stick.tscn")
@export var age: String = "young"

@export var health_nodes: Array[TextureRect]

func _ready():
	super()
	Global.player = self
	sprite.play(age)
	for i in 1:
		add_weapon(STICK_SCENE.instantiate())
		await get_tree().create_timer(0.04).timeout


func _process_walking(delta):
	_process_weapons()
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	move_dir(input_vector.normalized(), delta)


func _process_sliding(delta):
	_process_weapons()
	super(delta)


func _process_weapons():
	var weapons_angle = (get_local_mouse_position() - base_weapons_node_position).angle()
	update_weapons_node_position(weapons_angle)
	if Input.is_action_pressed("attack"):
		trigger_weapons_attacks()


func get_stunned(stun_time: float):
	super(stun_time)
	_update_health()


func _update_health():
	var missing_health = max_health - health
	for node: TextureRect in health_nodes:
		missing_health -= 1
		node.visible = missing_health <= 0


func death():
	super()
	Death.start()
