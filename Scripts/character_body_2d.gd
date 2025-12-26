extends CharacterBody2D

@onready var level = get_parent()
@onready var game_ctrl

@onready var player_anim = $AnimatedSprite2D
var speed
@onready var gravity = level.gravity
@onready var jump_force = level.player_jump_force
var collided


func start_animation():
	player_anim.play("player_idle")


func movement(delta):
	if !speed:
		speed = level.speed
	
	# JUMP logic
	if not is_on_floor():
		velocity.y += gravity * delta
		player_anims_manager("player_jump")
		
	else: 
		if Input.is_action_just_pressed("jump"):
			velocity.y = -jump_force
	
	# WALK logic
	var dir = Input.get_axis("ui_left", "ui_right")
	if dir == 0.0 and is_on_floor():
		player_anims_manager("player_idle")
		
	elif dir == -1:
		player_anim.flip_h = true
		if is_on_floor():
			if !walk_mode:
				player_anims_manager("player_walk")
			if walk_mode:
				player_anim_walking()
		
	elif dir == 1:
		player_anim.flip_h = false
		if is_on_floor():
			if !walk_mode:
				player_anims_manager("player_walk")
			if walk_mode:
				player_anim_walking()
		
	velocity.x = dir * speed

	move_and_slide()
	# Get collisions with objs aside from tilemap
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().name == "TileMapLayer":
			return
		collided = collision.get_collider()


## MANAGE PLAYER ANIMATION STAGES /--------------/
var walk_mode = false
func player_anims_manager(anim):
	if anim != "player_walk" and "player_walking" and "player_walkingVar":
		walk_mode = false
		if walk_anim_timer:
			walk_anim_timer.stop()
		
	if anim == "player_walk" and !walk_mode:
		player_anim_walking(anim)
		walk_mode = true
		
	if player_anim.animation == anim:
		return
	player_anim.play(anim)


func player_anim_walking(anim = null):
	if !walk_mode:
		# Wait walk animation to finish
		var frames = player_anim.sprite_frames
		var duration = frames.get_frame_count(anim) / frames.get_animation_speed(anim)
		await get_tree().create_timer(duration).timeout
	
		if anim != player_anim.animation:
			return
		# Walking animation loop
		player_anim.play("player_walking")
		
	if walk_mode:
		var anim_name = player_anim.animation
		var frames = player_anim.sprite_frames
		var duration = frames.get_frame_count(anim_name) / frames.get_animation_speed(anim_name)
		await walking_timer(duration)
		if !walk_mode:
			return
		
		if anim_name == "player_walking":
			anim = "player_walkingVar"
		elif anim_name == "player_walkingVar":
			anim = "player_walking"
		
		if player_anim.animation == anim:
			return
		if anim:
			player_anim.play(anim)


var walk_anim_timer: Timer = null
func walking_timer(duration: float) -> void:
	if walk_anim_timer == null:
		walk_anim_timer = Timer.new()
		walk_anim_timer.one_shot = true
		walk_anim_timer.name = "WalkAnimTimer"
		add_child(walk_anim_timer)

	if walk_anim_timer.is_stopped():
		walk_anim_timer.start(duration)

	await walk_anim_timer.timeout

## END /----------------------------/
