class_name GameCamera
extends Camera2D

@export var target: Node2D
@export var top_border: float = 100
@export var bottom_border: float = 100
@export_range(0,160,1) var position_change_amount: float = 60
@export var top_limit: float = -200
@export var bottom_limit: float = 200

var shake_noise := FastNoiseLite.new()

var shake_frequency: float = 0.0
var shake_strength: float = 0.0
var shake_time: float = 1.0
var shake_timer: float = 0.0
var shake_pos: float = 0.0
var shake_origin: Vector2 = Vector2()


func _ready():
	Global.camera = self


func _process(delta):
	if process_callback == CAMERA2D_PROCESS_IDLE: 
		_process_shake(delta)
	if is_instance_valid(target):
		if target.global_position.y > global_position.y + bottom_border:
			if global_position.y + position_change_amount < bottom_limit:
				global_position.y += position_change_amount
		if target.global_position.y < global_position.y - top_border:
			if global_position.y - position_change_amount > top_limit:
				global_position.y -= position_change_amount


func _physics_process(delta):
	if process_callback == CAMERA2D_PROCESS_PHYSICS: 
		_process_shake(delta)


func shake_screen(strength: float, frequency: float, time: float, origin: Vector2):
	shake_strength = strength
	shake_frequency = frequency
	shake_time = time
	shake_timer = time
	shake_origin = origin


func _process_shake(delta):
	shake_timer = move_toward(shake_timer, 0, delta)
	shake_pos += shake_frequency*delta
	var t: float = shake_timer/shake_time
	var ss = shake_strength * 5.0/(pow(1.0+abs(global_position.y - shake_origin.y), 1.4))
	offset.x = round((shake_noise.get_noise_2d(shake_pos, 0.0))*ss)*t
	offset.y = round((shake_noise.get_noise_2d(0.0, shake_pos))*ss)*t
