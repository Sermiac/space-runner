extends Control

@onready var levels = $MarginContainer/GridContainer
@onready var game_ctrl = get_parent()


func _ready() -> void:
	create_levels_list()
		

func create_levels_list():
	var dir = DirAccess.open("res://Scenes/levels/")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if not dir.current_is_dir():
				create_level_button(file_name)
			file_name = dir.get_next()
			
		dir.list_dir_end()

func create_level_button(btn_name: StringName):
	var btn = Button.new()
	btn.text = btn_name.replace(".tscn", "").replace("le" , "Le").replace("_", " ")
	btn.add_theme_font_size_override("font_size", 40)
	btn.pressed.connect(on_level_button_pressed.bind(btn.text))
	levels.add_child(btn)

func on_level_button_pressed(btn_name: StringName):
	btn_name = btn_name.replace(" ", "_")
	var level = "res://Scenes/levels/%s.tscn" % btn_name.to_lower()
	var level_scene = load(level).instantiate()
	game_ctrl.add_child(level_scene)
	game_ctrl.level_selected(btn_name)
	#game_ctrl.level = btn_name
	self.call_deferred("queue_free")
