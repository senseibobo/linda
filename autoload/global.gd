extends Node

signal enemies_cleared

var player: Player
var target: Node2D
var target_item: TargetItem
var camera: GameCamera
var entities: Array[Entity] = []
var random_sound_timer = 0.0


func get_closest_entity(pos):
	if entities.size() == 0: return null
	var closest = entities[0]
	var closest_distance: float = pos.distance_to(closest.global_position)
	for entity: Entity in entities:
		var distance: float = pos.distance_to(entity.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest = entity
	return closest


func add_entity(entity: Entity):
	entities.append(entity)


func remove_entity(entity: Entity):
	entities.erase(entity)
	for e: Entity in entities:
		if e is Enemy:
			return
	enemies_cleared.emit()


func play_sound(sound: AudioStream):
	var player = AudioStreamPlayer.new()
	player.stream = sound
	get_tree().current_scene.add_child(player)
	player.play()
	player.finished.connect(player.queue_free)
