extends CharacterBody2D

@export var stats = {"life":3, "status":"normal"}

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
	player_anim.play("idle")

func _physics_process(delta: float) -> void:
	if !speed: # INIT
		speed = level.speed
		wlk_snd = game_ctrl.get_node("PlayerStream")
		const num = 205.46
		wlk_snd.pitch_scale = snapped(speed / num, 0.0001)
		#print(wlk_snd.pitch_scale)
		wlk_snd.stream = walk_sound
		
		player_anim.speed_scale = speed/240
		
	if stats["status"] == "death_damage":
		$AnimationPlayer.play("RESET")
		if not is_on_floor():
			velocity.y += gravity * delta
			move_and_slide()
		else:
			player_anims_manager("death_damage")
		return
		
	if stats["status"] == "death_oxygen":
		$AnimationPlayer.play("RESET")
		if not is_on_floor():
			velocity.y += gravity * delta
			move_and_slide()
		player_anims_manager("death_oxygen")
		return

	if stats["status"] == "win":
		self.visible = false
		$Camera2D.enabled = false
		return
	
	if receiving_dmg:
		receive_damage(delta)
	else:
		movement(delta)
	
	
	if stats["status"] == "normal":
		$AnimationPlayer.play("RESET")
	elif stats["status"] == "invulnerable" and stats["life"] != 0:
		$AnimationPlayer.play("damage")

# Player movement
func movement(delta):
	# JUMP logic
	if stats["life"] == 0:
		return
		
	if not is_on_floor():
		velocity.y += gravity * delta
		if velocity.y <= -100.0:
			player_anims_manager("jump")
			wlk_snd.stop()
		elif velocity.y >= 190.0:
			player_anims_manager("fall")
		
	else:
		if Input.is_action_just_pressed("jump"):
			velocity.y = -jump_force
			
	# WALK logic
	# SOUND
	if player_anim.animation.contains("walking") and (player_anim.frame in [5,11,17,23]):
		if wlk_snd.stream == walk_sound2:
			wlk_snd.stream = walk_sound
		else:
			wlk_snd.stream = walk_sound2
		wlk_snd.play()
	
	if player_anim.animation == "walk" and (player_anim.frame in [2]):
		if wlk_snd.stream == walk_sound2:
			wlk_snd.stream = walk_sound
		else:
			wlk_snd.stream = walk_sound2
		wlk_snd.play()
	
	# MOVEMENT
	var dir = Input.get_axis("left", "right")
	if dir == 0.0 and is_on_floor():
		player_anims_manager("idle")
		wlk_snd.stop()
		
	elif dir == -1:
		player_anim.flip_h = true
		if is_on_floor():
			if !walk_mode:
				player_anims_manager("walk")
			if walk_mode:
				player_anim_walking()
		
	elif dir == 1:
		player_anim.flip_h = false
		if is_on_floor():
			if !walk_mode:
				player_anims_manager("walk")
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
func receive_damage(delta):
	if receiving_dmg:
		if dmg_dir > 0:
			player_anim.flip_h = true
		else:
			player_anim.flip_h = false
		
		velocity.x = dmg_dir * 400
		if is_on_floor():
			velocity.y = -400
		else:
			velocity.y += gravity * delta
		
		player_anims_manager("damage")
		
		move_and_slide()
		
		await get_tree().create_timer(0.10).timeout
		if is_on_floor():
			receiving_dmg = false
			dmg_dir = 0
			
			if stats["life"] == 0:
				stats["status"] = "death_damage"
				
			else:
				await get_tree().create_timer(0.75).timeout
				if stats["status"] == "invulnerable":
					stats["status"] = "normal"


## MANAGE PLAYER ANIMATION STAGES /--------------/
var walk_mode = false
func player_anims_manager(anim):
	if anim == "walk" and !walk_mode:
		player_anim_walking(anim)
		
	if player_anim.animation == anim:
		return
	player_anim.play(anim)

## Walking anims  /-----------------------/
func player_anim_walking(anim = null):
	if !walk_mode:
		if player_anim.animation == anim:
			await player_anim.animation_finished
	
		if anim != player_anim.animation:
			return
		# Walking animation loop
		player_anim.play("walking")
		walk_mode = true

## END /----------------------------/

# Animation Signals /------------/
func _on_animated_sprite_2d_animation_changed() -> void:
	if player_anim.animation != "walking":
		walk_mode = false
		
	if player_anim.animation == "death_damage":
		player_anim.position.y = 12
	if player_anim.animation == "death_oxygen":
		if !player_anim.flip_h:
			player_anim.position.x = 45
		else:
			player_anim.position.x = -45


func wait_frame(frame):
	while frame != player_anim.frame:
		await player_anim.frame_changed

# END /---------------/
