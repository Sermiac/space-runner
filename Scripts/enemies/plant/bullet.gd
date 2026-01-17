extends Node

var game_speed
enum Directions {izquierda,derecha}
var DIRECTION
var speed
var wait
var time = 0.0
var terrain

func _ready() -> void:
	speed = 5.0 * game_speed
	if DIRECTION == Directions.izquierda:
		speed *= -1
	elif DIRECTION == Directions.derecha:
		speed *= 1
	self.connect("body_entered", Callable(find_parent("Game"), "player_entered_area").bind(self))
		

func _physics_process(delta: float) -> void:
	movement(delta)
	if terrain and terrain.name == "TileMapLayer":
		die()

func movement(delta):
	self.position.x += speed * 40 * delta
	time += delta
	if time >= wait:
		die()
		time = 0.0

func die():
	self.call_deferred("queue_free")
