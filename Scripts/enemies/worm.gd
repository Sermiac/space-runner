extends Node

var active = false
var game_speed

func _ready() -> void:
	$AnimationPlayer.speed_scale = 1.0 * game_speed


# ATTACK LOGIC /----------------------/
func activate():
	active = true
	$activate.call_deferred("set_disabled", true)
	$kill.call_deferred("set_disabled", false)
	
	$AnimationPlayer.play("active")
	await $AnimationPlayer.animation_finished
	
	await get_tree().create_timer(0.5/game_speed).timeout
	deactivate()

func deactivate():
	$AnimationPlayer.play("deactive")
	
	await $AnimationPlayer.animation_finished
	$kill.call_deferred("set_disabled", true)
	
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
