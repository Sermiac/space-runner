extends Node

var game_speed
@onready var BulletScene = preload("res://Scenes/props/enemy/plant/bullet.tscn")

@onready var sprite_anim = $AnimatedSprite2D
@onready var sensor = $Area2D/Activate

var new_direction

func _ready() -> void:
	if new_direction == "izquierda":
		sprite_anim.flip_h = false
		sensor.position.x = -175
	elif new_direction == "derecha":
		sprite_anim.flip_h = true
		sensor.position.x = 175
	
	var anim = "idle_" + str(new_direction)
	sprite_anim.play(anim)


func shoot():
	var bullet = BulletScene.instantiate()
	bullet.global_position = self.global_position + Vector2(0, 35)
	bullet.new_direction = new_direction
	bullet.game_speed = game_speed
	get_parent().add_child(bullet)

func anims_manager(anim):
	if sprite_anim.animation == anim:
		return
	sprite_anim.play(anim)


func kill():
	find_parent("Game").p_receive_damage()

func player_collided():
	kill()

# Attack logic /------/
func _on_animated_sprite_2d_frame_changed() -> void:
	if sprite_anim.animation.contains("attack"):
		if sprite_anim.frame in [15, 23]:
			shoot()

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		var anim = "attack_" + str(new_direction)
		anims_manager(anim)
		$AnimationPlayer.play("attack")
		sensor.call_deferred("set_disabled", true)
	elif !body.is_in_group("player"):
		var anim = "idle_" + new_direction
		anims_manager(anim)

func _on_animated_sprite_2d_animation_finished() -> void:
	if sprite_anim.animation.contains("attack"):
		sensor.call_deferred("set_disabled", false)
# End /--------/
