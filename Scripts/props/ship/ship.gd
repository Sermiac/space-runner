extends Node

@onready var ship = $visuals/AnimatedSprite2D
@onready var smoke1 = $smoke1
@onready var smoke2 = $smoke2
@onready var anim_player = $AnimationPlayer

func _ready() -> void:
	ship.play("idle")
	smoke1.play("default")
	smoke2.play("default")
	
	# Update ship position to animation (NOT USED)
	"""
	var anim = anim_player.get_animation("movement")
	var track_idx = anim.find_track(NodePath("visuals:position"), Animation.TYPE_VALUE)
	var key_count = anim.track_get_key_count(track_idx)
	
	for k in range(key_count):
		var new_value = anim.track_get_key_value(track_idx, k) + $visuals.position
		anim.track_set_key_value(track_idx, k, new_value)
	"""

func win_animation():
	$visuals/Camera2D.enabled = true
	
	ship.play("start")
	
	await wait_frame(37-6)
	smoke1.play("active")
	print("smoke1")
	
	await wait_frame(53-6)
	ship.play("operation")
	print("operation")
	
	await wait_frame(67-6)
	anim_player.play("movement")
	print("movement")
	
	await wait_frame(69-6)
	smoke2.play("active")
	print("smoke2")
	
	await wait_frame(73-6)
	smoke1.play("default")
	
	await wait_frame(81-6)
	smoke2.play("default")
	
	await anim_player.animation_finished
	await get_tree().create_timer(2.0).timeout
	
	return true

var total_frames = 0
func wait_frame(frame):
	while frame != total_frames:
		await ship.frame_changed

func _on_animated_sprite_2d_frame_changed() -> void:
	total_frames += 1
	print(total_frames)
