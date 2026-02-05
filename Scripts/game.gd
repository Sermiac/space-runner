extends Node

# Load screen
@onready var load_screen = $CanvasLayer/LoadingScreen
@onready var load_bar = $CanvasLayer/LoadingScreen/ProgressBar
# Controls game speed
@export var SPEED = 1.0
# Level stats
var oxygen_consumption

func _on_exit_button_pressed() -> void:
	get_tree().call_deferred("change_scene_to_file", "res://Scenes/main_menu.tscn")


var end
var playing
func _physics_process(delta: float) -> void:
	if playing:
		if NODES["player"].stats["status"].contains("death"):
			print("YOU LOSE")
			playing = false
			await get_tree().create_timer(4.0).timeout
			get_tree().call_deferred("change_scene_to_file", "res://Scenes/game.tscn")
			return
		if NODES["level_canvas"][0].value <= 0.0:
			print("YOU LOSE")
			NODES["player"].stats["status"] = "death_oxygen"
			playing = false
			await get_tree().create_timer(4.0).timeout
			get_tree().call_deferred("change_scene_to_file", "res://Scenes/game.tscn")
			return
			
		var _p_pos = NODES["player"].global_position
		
		# OUT OF MAP
		"""
		if end:
			return
		if p_pos.y >= 420.0 and !end:
			NODES["level"].get_node("Camera2D").global_position = NODES["player"].get_node("Camera2D").global_position
			NODES["player"].get_node("Camera2D").enabled = false
			NODES["level"].get_node("Camera2D").enabled = true
			end = true
		"""
		# Oxygen consumption
		NODES["level_canvas"][0].value -= (oxygen_consumption * delta) * SPEED

# LOAD LEVEL /-----------------------------------/
func _process(_delta):
	if playing:
		return
	if current_prop >= props_to_spawn.size():
		if load_screen.visible and NODES.size() != 0:
			finish_props()
		return

	for i in 1:
		if current_prop >= props_to_spawn.size():
			finish_props()
			return

		spawn_prop(props_to_spawn[current_prop])
		current_prop += 1
		load_bar.value = current_prop

func spawn_prop(dummy):

	var node = dummy.prop_scene.instantiate()
	node.global_position = dummy.global_position
	node.name = dummy.name

	if "new_direction" in node:
		node.new_direction = "derecha" if dummy.direction == 0 else "izquierda"
	if node is Area2D:
		node.body_entered.connect(player_entered_area.bind(node))
	if node.is_in_group("enemy"):
		node.game_speed = SPEED
	if node.is_in_group("bottle"):
		node.get_node("AnimationPlayer").play("move")

	NODES["level"].add_child(node)

func finish_props():
	NODES["props"].queue_free()
	playing = true
	
	if Globals.music:
		Music.stream = preload("res://Assets/Music/Evolving Harmony.mp3")
		Music.play()
	
	get_tree().paused = false
	NODES["level_canvas"][5].text = "Life: " + str(NODES["player"].stats["life"])
	
	await get_tree().create_timer(0.2).timeout
	load_screen.hide()


var NODES = {}
func level_selected(data):
	get_tree().paused = true
	
	NODES = data
	load_bar.max_value = NODES.size()
	# set NODES properties
	NODES["level"].game_ctrl = self
	NODES["player"].game_ctrl = self
	NODES["player"].start_animation()
	NODES["level_canvas"][0].max_value = NODES["level"].max_oxygen
	NODES["level_canvas"][0].value = NODES["level"].initial_oxygen
	# get node properties
	oxygen_consumption = NODES["level"].oxygen_consumption

	prepare_props()


var props_to_spawn := []
var current_prop := 0
func prepare_props():
	NODES["props"].visible = false
	props_to_spawn = NODES["props"].get_children()
# END /-----------------------------------------/


# HANDDLE COLLISSIONS /-----------------------/
func player_entered_area(body, area):
	handle_terrain(area, body)
	if body.name != "player":
		return
	
	if area.is_in_group("bottle"):
		handle_bottle(area)
	elif area.is_in_group("enemy"):
		handle_enemy(area)
	elif area.is_in_group("ship"):
		handle_ship(area)

func handle_bottle(area):
	if NODES["player"].stats["status"].contains("death"):
		return

	var bottle_vals = {"oxygen":40, "fuel":10}
	var bottle_name = "oxygen" if area.name.contains("oxygen") else "fuel"
	
	var num
	for obj_indx in range(NODES["level_canvas"].size()):
		var search = bottle_name + "_" + "bar"
		if NODES["level_canvas"][obj_indx].name == search:
			num = obj_indx
			
	NODES["level_canvas"][num].value += bottle_vals[bottle_name]
	$AudioStreamPlayer.stream = load("res://Assets/Sounds/bottles/%s.mp3" % bottle_name)
	$AudioStreamPlayer.play()
	area.call_deferred("queue_free")
	
func handle_ship(area):
	# Lose
	if NODES["level_canvas"][2].value <= 99:
		NODES["level_canvas"][4].text = "NOT ENOUGH FUEL!!"
		await get_tree().create_timer(2.0).timeout
		NODES["level_canvas"][4].text = ""
	
	# Win
	elif NODES["level_canvas"][2].value >= 99:
		NODES["player"].stats["status"] = "win"
		NODES["level_canvas"][4].text = "You Win!!"
		playing = false
		
		await area.win_animation()
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/game.tscn")

func handle_enemy(area):
	var dir = (NODES["player"].global_position - area.global_position).normalized()
	area.player_collided()
	NODES["player"].dmg_dir = 1 if dir.x >= 0 else -1


func handle_terrain(area, body):
	if "bullet" in area.get_groups():
		area.terrain = body

# Player interactions /-----------/
func p_receive_damage():
	if NODES["player"].stats["status"] != "normal":
		return
	if NODES["player"].stats["life"] == 0:
		return
		
	NODES["player"].stats["life"] -= 1
	NODES["player"].receiving_dmg = true
	if NODES["player"].stats["life"] == 0:
		NODES["player"].stats["status"] = "death_damage"
		
	NODES["level_canvas"][5].text = "Life: " + str(NODES["player"].stats["life"])
	NODES["player"].stats["status"] = "invulnerable"
