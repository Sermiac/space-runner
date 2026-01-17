extends Node

var game_speed
@onready var BulletScene = preload("res://Scenes/props/enemy/plant/bullet.tscn")
enum Directions { izquierda, derecha }
@export var DIRECTION: Directions
var wait
var time

var new_direction

func _ready() -> void:
	wait = 5.0 / game_speed
	time = wait - 1.0
	if new_direction == "izquierda":
		DIRECTION = Directions.izquierda
	elif new_direction == "derecha":
		DIRECTION = Directions.derecha
		
	if DIRECTION == Directions.izquierda:
		$Sprite2D.flip_h = true
	elif DIRECTION == Directions.derecha:
		$Sprite2D.flip_h = false

func _physics_process(delta: float) -> void:
	shoot(delta)

func shoot(delta):
	time += delta
	if time >= wait:
		var bullet = BulletScene.instantiate()
		bullet.global_position = self.global_position
		bullet.DIRECTION = DIRECTION
		bullet.wait = wait
		bullet.game_speed = game_speed
		get_parent().add_child(bullet)
		time = 0.0
