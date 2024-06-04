class_name Entity
extends CharacterBody2D

signal died

enum State {
	IDLE,
	WALKING,
	SLIDING,
	STUNNED
}

@export var start_state: State = State.IDLE
@export var max_movement_speed: float = 80
@export var acceleration: float = 400.0
@export var deceleration: float = 1000.0
@export var base_attack_speed: float = 0.5
@export var max_health: int = 5
@export var stun_drag: float = 1000.0
@export var slide_drag: float = 4.0

@export var hit_sound_player: AudioStreamPlayer2D
@export var talking_sound_player: AudioStreamPlayer2D
@export var death_sound_player: AudioStreamPlayer2D

@export var sounds_on_hit: Array[AudioStream]
@export var sounds_on_stun: Array[AudioStream]
@export var sounds_on_death: Array[AudioStream]
@export var sounds_talking: Array[AudioStream]
@export var sounds_idle: Array[AudioStream]

@onready var health: int = max_health
@onready var stars: GPUParticles2D = %Stars
@onready var sprite: AnimatedSprite2D = %Sprite

var sound_timer: float = 5.0

var state: State = State.WALKING
var target_item: TargetItem
var stun_time_left: float = 0.0
var attack_cooldown: float = 0.0
var weapons: Array[Weapon]
var weapons_node: Node2D
var weapons_spacing: float = 5
var weapons_node_spacing: float = 10.0
var base_weapons_node_position := Vector2(0,-12)
var old_sprite_position: Vector2


func _ready():
	sound_timer = 2.0 + randf()*12
	base_attack_speed *= 0.85+randf()*0.3
	set_state(start_state)
	_add_weapons_node()
	await Global.get_tree().process_frame
	await Global.get_tree().process_frame
	set_state(start_state)


func _enter_tree():
	Global.add_entity(self)


func _exit_tree():
	Global.remove_entity(self)


func _process(delta):
	_process_sounds(delta)
	attack_cooldown -= delta


func _process_sounds(delta):
	sound_timer -= delta
	if sound_timer <= 0:
		match state:
			State.IDLE: _play_idle_sound()
			State.WALKING: _play_talking_sound()
		sound_timer += 1.0+10.0*randf()


func _physics_process(delta):
	_physics_process_state(delta)


func _physics_process_state(delta):
	match state:
		State.WALKING: _process_walking(delta)
		State.SLIDING: _process_sliding(delta)
		State.STUNNED: _process_stunned(delta)


func set_state(new_state: State):
	var old_state: State = state
	state = new_state
	if state == State.WALKING:
		print("play" + str(name))
		sprite.play()
	else:
		sprite.frame = 1
		sprite.pause()
	if state != State.STUNNED:
		stars.visible = false
	if state == State.SLIDING:
		if sprite.position != Vector2():
			old_sprite_position = sprite.position
		sprite.rotation = [-1,1].pick_random() * PI/2
		sprite.position = Vector2()
		sprite.flip_v = bool(randi()%2)
	elif old_state == State.SLIDING:
		if not sprite.get_parent() == self: return
		sprite.rotation = 0
		sprite.position = old_sprite_position
		sprite.flip_v = false
	# process state change here


func hit(knockback: Vector2):
	_play_hit_sound()
	if randi()%4 == 0:
		var blood = preload("res://entities/blood/blood.tscn").instantiate()
		get_tree().current_scene.add_child(blood)
		blood.global_position = global_position
	velocity += knockback
	set_state(State.SLIDING)
	Global.camera.shake_screen(30,50,0.5, global_position)


func add_weapon(weapon: Weapon):
	weapons.append(weapon)
	weapons_node.add_child(weapon)
	weapon.owner = self
	update_weapons_positions()


func remove_weapon(weapon: Weapon):
	weapons.erase(weapon)
	weapons_node.remove_child(weapon)
	update_weapons_positions()


func hide_weapons():
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(weapons_node, "scale", Vector2(), 0.3)


func show_weapons():
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
	tween.tween_property(weapons_node, "scale", Vector2(1,1), 0.3)


func update_weapons_positions():
	if weapons.size() == 0: return
	if weapons.size()%2 == 0:
		var cp = weapons_spacing/2.0
		for i in range(0,weapons.size(),2):
			weapons[i].position.x = cp
			weapons[i+1].position.x = -cp
			cp += weapons_spacing
	else:
		weapons[0].position.x = 0
		var cp = weapons_spacing
		for i in range(1,weapons.size(),2):
			weapons[i].position.x = cp
			weapons[i+1].position.x = -cp
			cp += weapons_spacing
	
	for i in range(weapons.size()):
		pass


func trigger_weapons_attacks():
	if attack_cooldown <= 0:
		attack_cooldown = base_attack_speed
		for weapon: Weapon in weapons:
			weapon.on_attack(self)
			await get_tree().create_timer(0.02, false).timeout


func update_weapons_node_position(new_angle_rad: float):
	weapons_node.position = Vector2.RIGHT.rotated(new_angle_rad) * weapons_node_spacing \
		+ base_weapons_node_position
	weapons_node.rotation = new_angle_rad + PI/2


func _add_weapons_node():
	weapons_node = Node2D.new()
	weapons_node.position = base_weapons_node_position
	add_child(weapons_node)
	weapons_node.owner = self


func _process_walking(delta):
	pass


func move_dir(dir: Vector2, delta):
	if abs(dir.x) > 0.1:
		sprite.scale.x = sign(dir.x)
	var change: float = acceleration if dir.dot(velocity) > 0 else deceleration
	velocity = velocity.move_toward(dir*max_movement_speed, change*delta)
	move_and_slide()
	if state == State.WALKING:
		if velocity.length() > 1.0:
			sprite.play()
		else:
			sprite.pause()
			sprite.frame = 1


func _process_sliding(delta):
	if self is Player:
		print("P")
	velocity = velocity.lerp(Vector2(), slide_drag*delta)
	if velocity.length_squared() < 1000.0:
		set_state(State.WALKING)
	var collision = move_and_collide(velocity*delta)
	check_for_stun_collision(collision)


func check_for_stun_collision(collision: KinematicCollision2D):
	if not collision: return
	#var collision: KinematicCollision2D = get_slide_collision(i)
	var collider = collision.get_collider()
	if velocity.dot(collision.get_normal()) < -130:
		var stun_duration = 0.5 + min(velocity.length()/300.0, 0.6)
		get_stunned(stun_duration)
		velocity = velocity.bounce(collision.get_normal())
		if collider is Entity:
			#collider.get_stunned(stun_duration)
			collider.set_state(State.SLIDING)
			collider.velocity = -velocity/1.4
			velocity /= 1.4


func _play_stun_sound():
	if sounds_on_stun.size() <= 0: return
	hit_sound_player.stream = sounds_on_stun.pick_random()
	hit_sound_player.play(0.0)


func _play_hit_sound():
	if sounds_on_hit.size() <= 0: return
	hit_sound_player.stream = sounds_on_hit.pick_random()
	hit_sound_player.play(0.0)


func _play_talking_sound():
	if sounds_talking.size() <= 0: return
	talking_sound_player.stream = sounds_talking.pick_random()
	talking_sound_player.play(0.0)


func _play_idle_sound():
	if sounds_idle.size() <= 0: return
	talking_sound_player.stream = sounds_idle.pick_random()
	talking_sound_player.play(0.0)


func _play_death_sound():
	if sounds_on_death.size() <= 0: return
	var dp = death_sound_player.duplicate()
	get_tree().current_scene.add_child(dp)
	dp.global_position = death_sound_player.global_position
	dp.stream = sounds_on_death.pick_random()
	dp.play(0.0)


func get_stunned(time: float):
	_play_stun_sound()
	if randi()%4 == 0:
		var organ = preload("res://entities/blood/organ.tscn").instantiate()
		get_tree().current_scene.add_child(organ)
		organ.global_position = global_position
	health -= 1
	if health <= 0:
		death()
	if target_item:
		Global.target = null
		target_item.launch(global_position, Vector2.RIGHT.rotated(randf()*TAU))
		target_item = null
	Global.camera.shake_screen(40,30,1,global_position)
	set_state(State.STUNNED)
	stars.visible = true
	stun_time_left = velocity.length()/200.0


func _process_stunned(delta):
	velocity = velocity.move_toward(Vector2(), stun_drag*delta)
	var collision: KinematicCollision2D = move_and_collide(velocity*delta)
	check_for_stun_collision(collision)
	stun_time_left -= delta
	if stun_time_left <= 0:
		set_state(State.WALKING)


func death():
	died.emit()
	_play_death_sound()
	var gp = sprite.global_position
	sprite.reparent(get_tree().current_scene)
	sprite.global_rotation = [-1,1].pick_random() * PI/2
	sprite.global_position = gp
	sprite.global_position += Vector2(0,12)
	print(gp)
	queue_free()
