extends CharacterBody2D

@onready var game_ctrl
@onready var animation = $AnimatedSprite2D
var speed = 200
var gravity = 400 #900 normal
@export var jump_force := 620.0
var collided


func start_animation():
	animation.play("player_idle")

func movement(delta):
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
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().name == "TileMapLayer":
			return
		collided = collision.get_collider()
