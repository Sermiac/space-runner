extends Node2D

var game_ctrl
var speed = 0

@export_category("Level Properties")
@export var gravity = 900
@export var player_jump_force = 650.0
@export var player_speed: float = 120.0
@export var oxygen_consumption: float
@export var max_oxygen: float = 100.0

var loaded = false

func _physics_process(delta: float) -> void:
	if !loaded and game_ctrl:
		speed = game_ctrl.SPEED * player_speed
		loaded = true
