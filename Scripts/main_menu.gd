extends Node

var menu_song = preload("res://Assets/Music/Evolving through the cosmos.mp3")

func _ready() -> void:
	if Globals.music and Music.stream != menu_song:
		Music.stream = menu_song
		Music.play()
	print("Embedded window: ", Engine.is_embedded_in_editor())
	$background.play("default")

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/game.tscn")

func _on_exit_button_pressed() -> void:
	get_tree().quit()


func _on_options_button_pressed() -> void:
	if $options.visible:
		$options.visible = false
	else:
		$options.visible = true
