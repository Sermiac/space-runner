extends Node

# Controls game speed
@export var SPEED = 1.0
# Level stats
var p_init
var ba_init
var oxygen_consumption

func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	
	
var end
func _physics_process(delta: float) -> void:
	if NODES:
		if NODES["level_canvas"][0].value <= 0.0:
			print("YOU LOOSE")
			get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
			return
		var p_pos = NODES["player"].global_position
		var ba_pos = NODES["background"].global_position
		
		# OUT OF MAP
		"""
		if end:
			return
		if p_pos.y >= 420.0 and !end:
			NODES["level"].get_node("Camera2D").global_position = NODES["player"].get_node("Camera2D").global_position
			NODES["player"].get_node("Camera2D").enabled = false
			end = true
		"""
		# BACKGROUND MOVEMENT
		NODES["background"].global_position.x = (p_pos.x - p_init.x) + ba_init.x
		NODES["background"].global_position.y = (p_pos.y - p_init.y) / 2 + ba_init.y
		# Oxygen consumption
		NODES["level_canvas"][0].value -= oxygen_consumption * delta


var NODES = {}
func level_selected(data):
	NODES = data
	# set NODES properties
	NODES["level"].game_ctrl = self
	NODES["player"].game_ctrl = self
	NODES["player"].start_animation()
	NODES["level_canvas"][0].max_value = NODES["level"].max_oxygen
	# get node properties
	p_init = NODES["player"].global_position
	ba_init = NODES["background"].position
	NODES["background"].global_position = (p_init - p_init) + ba_init
	oxygen_consumption = NODES["level"].oxygen_consumption

	init_props()


func init_props():
	NODES["props"].visible = false
	for category in NODES["props"].get_children():
		for prop in category.get_children():
			var path = "res://Scenes/props/%s/%s.tscn" % [category.name, prop.name.split("_")[0]]
			var node = load(path).instantiate()
			node.position = prop.position
			node.name = prop.name
			if prop.has_meta("Direction"):
				node.new_direction = prop.get_meta("Direction")
			if node is Area2D:
				node.connect("body_entered", Callable(self, "player_entered_area").bind(node))
			if node.is_in_group("enemy"):
				node.game_speed = SPEED
			NODES["level"].add_child(node)


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
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/game.tscn")

func handle_enemy(area):
	area.player_collided()


func handle_terrain(area, body):
	if "bullet" in area.get_groups():
		area.terrain = body

# Player interactions /-----------/
func p_receive_damage():
	print(NODES["player"].stats["status"])
	if NODES["player"].stats["status"] == "invulnerable":
		return
		
	NODES["player"].stats["life"] -= 1
	NODES["player"].receiving_dmg = true
	if NODES["player"].stats["life"] == 0:
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/game.tscn")
		
	NODES["level_canvas"][5].text = "Life: " + str(NODES["player"].stats["life"])
	NODES["player"].stats["status"] = "invulnerable"
	
	await get_tree().create_timer(2.0).timeout
	NODES["player"].stats["status"] = "normal"
