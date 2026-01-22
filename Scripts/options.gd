extends Node

func _ready() -> void:
	if !Engine.is_embedded_in_editor():
		$MarginContainer2/HBoxContainer/mode_button.disabled = false

func _on_music_button_pressed() -> void:
	var music = Globals.music
	if !music:
		Globals.music = true
		Music.play()
		Music.autoplay = true
		$music_mode.text = "ON"
		
	elif music:
		Globals.music = false
		Music.stop()
		Music.autoplay = false
		$music_mode.text = "OFF"


func _on_mode_button_pressed() -> void:
	var current_mode = DisplayServer.window_get_mode()
	if current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
		$window_mode.text = "Window"
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		$window_mode.text = "Fullscreen"
