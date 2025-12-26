extends Node2D

var game_ctrl
var speed = 0
var player_jump_force = 650.0

@export var gravity = 900
@export var new_game_speed: float
@export var oxygen_consumption: float
@export var max_oxygen: float = 100.0

var loaded = false

func _physics_process(delta: float) -> void:
	if !loaded and game_ctrl:
		if new_game_speed:
			game_ctrl.SPEED = new_game_speed
		speed = game_ctrl.SPEED * 80
		loaded = true
