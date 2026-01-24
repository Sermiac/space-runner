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
		if NODES["level_canvas"][0].value <= 0.0:
			print("YOU LOOSE")
			get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
			return
		var _p_pos = NODES["player"].global_position
		
		# OUT OF MAP
		"""
		if end:
			return
		if p_pos.y >= 420.0 and !end:
			NODES["level"].get_node("Camera2D").global_position = NODES["player"].get_node("Camera2D").global_position
			NODES["player"].get_node("Camera2D").enabled = false
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

func spawn_prop(data):
	var prop = data.prop
	var path = "res://Scenes/props/%s/%s.tscn" % [
		data.category,
		prop.name.split("_")[0]
	]

	var node = load(path).instantiate()
	node.position = prop.position
	node.name = prop.name

	if prop.has_meta("Direction"):
		node.new_direction = prop.get_meta("Direction")
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
	for category in NODES["props"].get_children():
		for prop in category.get_children():
			props_to_spawn.append({
				"category": category.name,
				"prop": prop
			})
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
	var bottle_vals = {"oxygen":40, "fuel":10}
	var bottle_name = area.name.split("_",1)[0]
	
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
	if NODES["level_canvas"][2].value <= 99:
		NODES["level_canvas"][4].text = "NOT ENOUGH FUEL!!"
		await get_tree().create_timer(2.0).timeout
		NODES["level_canvas"][4].text = ""
		
	elif NODES["level_canvas"][2].value >= 99:
		NODES["level_canvas"][4].text = "You Win!!"
		area.get_node("AnimatedSprite2D").play("start")
		await get_tree().create_timer(2.0).timeout
		area.get_node("AnimatedSprite2D").play("operation")
		await get_tree().create_timer(2.0).timeout # ESTO SE CAMBIA POR LA CINEMATICA
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/game.tscn")

func handle_enemy(area):
	area.player_collided()


func handle_terrain(area, body):
	if "bullet" in area.get_groups():
		area.terrain = body

# Player interactions /-----------/
func p_receive_damage():
	if NODES["player"].stats["status"] == "invulnerable":
		return
		
	NODES["player"].stats["life"] -= 1
	NODES["player"].receiving_dmg = true
	if NODES["player"].stats["life"] == 0:
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/game.tscn")
		
	NODES["level_canvas"][5].text = "Life: " + str(NODES["player"].stats["life"])
	NODES["player"].stats["status"] = "invulnerable"
	
	await get_tree().create_timer(1.5/SPEED).timeout
	NODES["player"].stats["status"] = "normal"
