extends Node

func _on_music_button_pressed() -> void:
	var music = Globals.music
	if !music:
		Globals.music = true
		Music.play()
		Music.autoplay = true
		
	elif music:
		Globals.music = false
		Music.stop()
		Music.autoplay = false
