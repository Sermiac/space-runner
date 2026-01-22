extends CharacterBody2D

var stats = {"life":3, "status":"normal"}

@onready var level = get_parent()
@onready var game_ctrl
var wlk_snd

@onready var player_anim = $AnimatedSprite2D

# Physics
var speed
@onready var gravity = level.gravity
@onready var jump_force = level.player_jump_force
var collided

var walk_sound = preload("res://Assets/Sounds/player/walking/walk1.mp3")
var walk_sound2 = preload("res://Assets/Sounds/player/walking/walk2.mp3")

func start_animation():
	player_anim.play("player_idle")

func _physics_process(delta: float) -> void:
	if !speed:
		speed = level.speed
		wlk_snd = game_ctrl.get_node("PlayerStream")
		const num = 205.46
		wlk_snd.pitch_scale = snapped(speed / num, 0.0001)
		print(wlk_snd.pitch_scale)
		wlk_snd.stream = walk_sound
		
		player_anim.speed_scale = speed/240

	movement(delta)
	receive_damage()
	
	if stats["status"] == "normal":
		$AnimationPlayer.play("RESET")
	elif stats["status"] == "invulnerable":
		$AnimationPlayer.play("damage")

# Player movement
func movement(delta):
	# JUMP logic
	if not is_on_floor():
		velocity.y += gravity * delta
		if receiving_dmg or stats["status"] == "invulnerable":
			return
		if velocity.y <= 0.0:
			player_anims_manager("player_jump")
			wlk_snd.stop()
		else:
			player_anims_manager("player_fall")
		
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = -jump_force
			
	# WALK logic
	# SOUND
	if player_anim.animation.contains("walking") and (player_anim.frame in [4, 10]):
		if wlk_snd.stream == walk_sound2:
			wlk_snd.stream = walk_sound
		else:
			wlk_snd.stream = walk_sound2
		wlk_snd.play()
	
	if player_anim.animation == "player_walk" and (player_anim.frame in [2]):
		if wlk_snd.stream == walk_sound2:
			wlk_snd.stream = walk_sound
		else:
			wlk_snd.stream = walk_sound2
		wlk_snd.play()
	
	# MOVEMENT
	var dir = Input.get_axis("ui_left", "ui_right")
	if dir == 0.0 and is_on_floor():
		player_anims_manager("player_idle")
		wlk_snd.stop()
		
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
	# NOT USED AT THE MOMENT
	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		if collision.get_collider().name == "TileMapLayer":
			return
		collided = collision.get_collider()
# END /-------------------------------------/

var receiving_dmg
var dmg_dir = 0
func receive_damage():
	if receiving_dmg:
		if dmg_dir == 0:
			if player_anim.flip_h == false:
				dmg_dir = 1
			elif player_anim.flip_h == true:
				dmg_dir = -1
		
		velocity.x = -dmg_dir * 450
		velocity.y = -400
		
		player_anims_manager("player_damage")
		
		move_and_slide()
		await get_tree().create_timer(0.20).timeout
		
		receiving_dmg = false
		
	elif stats["status"] == "invulnerable":
		velocity.x = -dmg_dir * 400
		move_and_slide()
		await get_tree().create_timer(0.75).timeout
		dmg_dir = 0


## MANAGE PLAYER ANIMATION STAGES /--------------/
var walk_mode = false
func player_anims_manager(anim):
	if anim != "player_walk" and "player_walking" and "player_walkingVar":
		walk_mode = false
		if walk_anim_timer:
			walk_anim_timer.stop()
		
	if anim == "player_walk" and !walk_mode:
		player_anim_walking(anim)
		
	if player_anim.animation == anim:
		return
	player_anim.play(anim)

## Walking anims  /-----------------------/
func player_anim_walking(anim = null):
	if !walk_mode:
		# Wait walk animation to finish
		var frames = player_anim.sprite_frames
		var duration = frames.get_frame_count(anim) / frames.get_animation_speed(anim)
		# CORRECTING CALCULATION BY 0.01
		await get_tree().create_timer((duration-0.01)/(speed/240)).timeout
	
		if anim != player_anim.animation:
			return
		# Walking animation loop
		player_anim.play("player_walking")
		walk_mode = true
		
	if walk_mode:
		var anim_name = player_anim.animation
		var frames = player_anim.sprite_frames
		var duration = frames.get_frame_count(anim_name) / frames.get_animation_speed(anim_name)
		await walking_timer(duration/(speed/240))
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
