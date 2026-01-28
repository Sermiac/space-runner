extends Node

var game_speed
var new_direction
var speed
var wait = 4.0
var time = 0.0
var terrain

func _ready() -> void:
	speed = 5.0 * game_speed
	if new_direction == "izquierda":
		speed *= -1
	elif new_direction == "derecha":
		speed *= 1
	self.connect("body_entered", Callable(find_parent("Game"), "player_entered_area").bind(self))
		

func _physics_process(delta: float) -> void:
	movement(delta)
	if terrain and terrain.name == "TileMapLayer":
		die()

func movement(delta):
	self.position.x += speed * 80 * delta
	time += delta
	if time >= wait:
		die()
		time = 0.0

func kill():
	find_parent("Game").p_receive_damage()

func player_collided():
	kill()

func die():
	self.call_deferred("queue_free")
