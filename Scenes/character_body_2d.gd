extends CharacterBody2D

var speed = 200
var gravity = 900

func _physics_process(delta):
	velocity.y += gravity * delta

	var dir = Input.get_axis("ui_left", "ui_right")
	velocity.x = dir * speed

	move_and_slide()
