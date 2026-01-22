extends Node2D

var game_ctrl = find_parent("Game")
var speed = 0

signal level_ready(data)
@onready var nodes = {
	"player": $player,
	"level_canvas": $CanvasLayer.get_children(),
	"props": $props,
	"level": self
}

@export_category("Level Properties")
@export var gravity = 800
@export var player_jump_force = 700.0
@export var player_speed: float = 240.0
@export var oxygen_consumption: float = 3.4
@export var max_oxygen: float = 300.0
@export var initial_oxygen: float = 80.0

var loaded = false

func _ready():
	level_ready.emit(nodes)

func _physics_process(delta: float) -> void:
	if !loaded and game_ctrl:
		speed = game_ctrl.SPEED * player_speed
		loaded = true
	
