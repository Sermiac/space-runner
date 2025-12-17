extends CharacterBody2D

@onready var game_ctrl
@onready var animation = $AnimatedSprite2D
var speed = 200
var gravity = 900
@export var jump_force := 500.0


func _ready() -> void:
	animation.play("player_idle")

func _physics_process(delta):
	speed = game_ctrl.SPEED * 80
	
	if not is_on_floor():
		animation.play("player_jump")
		velocity.y += gravity * delta
		
	else: 
		animation.play("player_idle")
		if Input.is_action_just_pressed("jump"):
			velocity.y = -jump_force
	
	velocity.x = speed

	move_and_slide()
