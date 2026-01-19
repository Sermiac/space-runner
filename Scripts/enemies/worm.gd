extends Node

var active = false
var game_speed

func _ready() -> void:
	$AnimatedSprite2D.play("worm_idle")
	$AnimationPlayer.speed_scale = 1.0 * game_speed


# ATTACK LOGIC /----------------------/
func activate():
	$AnimatedSprite2D.flip_h = get_parent().get_node("player/AnimatedSprite2D").flip_h
	active = true
	$activate.call_deferred("set_disabled", true)
	$kill.call_deferred("set_disabled", false)
	
	$AnimationPlayer.play("active")
	$AnimatedSprite2D.play("worm_out")
	await $AnimationPlayer.animation_finished
	$AnimatedSprite2D.play("worm_idle_out")
	
	await get_tree().create_timer(3.5/game_speed).timeout
	deactivate()

func deactivate():
	$AnimationPlayer.play("deactive")
	$AnimatedSprite2D.play("worm_in")
	
	await $AnimationPlayer.animation_finished
	$kill.call_deferred("set_disabled", true)
	$AnimatedSprite2D.play("worm_idle")
	
	await get_tree().create_timer(2.0/game_speed).timeout
	active = false
	$activate.call_deferred("set_disabled", false)
	
# END /---------------------/


func kill():
	find_parent("Game").p_receive_damage()

func player_collided():
	if active:
		kill()
	else:
		activate()
