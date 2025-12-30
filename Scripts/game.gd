extends Node

var level
# Controls game speed
@export var SPEED = 2.0
# Level Nodes
var level_canvas
var tile_map
var background
var player
var p_init
var ba_init
var oxygen
var fuel
var props
var oxygen_consumption

func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	
	
var end
func _physics_process(delta: float) -> void:
	if level:
		if level_canvas[0].value <= 0.0:
			print("YOU LOOSE")
			get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
			return
		var p_pos = player.global_position
		var ba_pos = background.global_position
		# PLAYER MOVEMENT
		player.movement(delta)
		"""
		if end:
			return
		if p_pos.y >= 420.0 and !end:
			level.get_node("Camera2D").global_position = player.get_node("Camera2D").global_position
			player.get_node("Camera2D").enabled = false
			end = true
		"""
		# BACKGROUND MOVEMENT
		background.global_position.x = (p_pos.x - p_init.x) + ba_init.x
		background.global_position.y = (p_pos.y - p_init.y) / 2 + ba_init.y


# Todo el codigo en comillas es codigo de generacion automatica de terreno
"""
var active_platforms = []
func create_tile_platforms():
	var added_tiles = []
	# Create
	var ref_last_cell_x = last_cell_x
	ref_last_cell_x += 1
	for i in range(randi_range(1,10)):
		var new_cell = Vector2i(ref_last_cell_x + i, -5)
		tile_map.set_cell(new_cell, 2, Vector2i(2,0))
		active_platforms.append(new_cell)
		added_tiles.append(new_cell)
		
	# Update
	tile_map.set_cells_terrain_connect(added_tiles, 0, 0)
"""

func level_selected(btn_name):
	btn_name = btn_name.to_lower()
	# set nodes
	tile_map = get_node("%s/floor/TileMapLayer" % btn_name)
	background = get_node("%s/Parallax2D/Sprite2D" % btn_name)
	player = get_node("%s/player" % btn_name)
	level_canvas = get_node("%s/CanvasLayer" % btn_name).get_children()
	oxygen = get_node("%s/oxygen" % btn_name)
	fuel = get_node("%s/fuel" % btn_name)
	props = get_node("%s/props" % btn_name)
	level = get_node("%s" % btn_name)
	# set nodes properties
	level.game_ctrl = self
	player.game_ctrl = self
	player.start_animation()
	level_canvas[0].max_value = level.max_oxygen
	# get node properties
	p_init = player.global_position
	ba_init = background.position
	background.global_position = (p_init - p_init) + ba_init
	oxygen_consumption = level.oxygen_consumption

	"""
	init_tiles()
	"""
	init_props()
	
	spd_controller(SPEED)
	$Timer.start()
	$Timer2.start()

func init_props():
	props.visible = false
	for prop in props.get_children():
		var original_node = NodePath(prop.name.split("_")[0])
		var copy = level.get_node(original_node).duplicate()
		copy.position = prop.position
		copy.name = prop.name
		copy.connect("body_entered", Callable(self, "player_entered_area").bind(copy))
		level.add_child(copy)


"""
var floor_y = 3
var floor_x = 20
var last_cell_x
func init_tiles():
	for i in range(floor_x):
		for j in range(floor_y):
			tile_map.set_cell(Vector2i(i - 10, -1 - j), 2, Vector2i(1,0))
	var cells = tile_map.get_used_cells()
	tile_map.set_cells_terrain_connect(cells, 0, 0)
	tile_map.set_cell(cells[0], 2, Vector2i(0,0))
	tile_map.set_cell(cells[-1], 2, Vector2i(2,0))
	last_cell_x = tile_map.get_used_cells()[-1].x


func update_tiles():
	last_cell_x += 1
	var added_cells = []
	var old_cells = []
	var cells = tile_map.get_used_cells()
	# Create
	for i in range(floor_y):
		var new_cell = Vector2i(last_cell_x,-1 - i)
		added_cells.append(new_cell)
		tile_map.set_cell(new_cell, 2, Vector2i(2,0))
		
	# Delete
	var found = false
	for cell in cells:
		if found:
			break
		elif cell.y == -1:
			old_cells.append(cell)
			found = true
	for j in range(floor_y - 1):
		old_cells.append(old_cells[0] - Vector2i(0,j+1))
	for cell in old_cells:
		tile_map.set_cell(cell, -1)
		
	# Update
	tile_map.set_cells_terrain_connect(added_cells, 0, 0)
"""

func spd_controller(speed):
	$Timer.wait_time = 1 / (1.13 * speed)
	$Timer2.wait_time = 1 / (0.125 * speed)


# Clocks
func _on_timer_timeout() -> void:
	level_canvas[0].value -= oxygen_consumption
	#update_tiles()
"""
func _on_timer_2_timeout() -> void:
	create_tile_platforms()
"""


func player_entered_area(body, area):
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
	for obj_indx in range(level_canvas.size()):
		var search = bottle_name + "_" + "bar"
		if level_canvas[obj_indx].name == search:
			num = obj_indx
			
	level_canvas[num].value += bottle_vals[bottle_name]
	$AudioStreamPlayer.stream = load("res://Assets/Sounds/bottles/%s.mp3" % bottle_name)
	$AudioStreamPlayer.play()
	area.call_deferred("queue_free")
	
func handle_ship(area):
	if level_canvas[2].value <= 99:
		level_canvas[4].text = "NOT ENOUGH FUEL!!"
		await get_tree().create_timer(2.0).timeout
		level_canvas[4].text = ""
	elif level_canvas[2].value >= 99:
		"""
		level.call_deferred("queue_free")
		var level_selector = preload("res://Scenes/level_selector.tscn").instantiate()
		$Timer.stop(); $Timer2.stop()
		add_child(level_selector)
		"""
		get_tree().call_deferred("change_scene_to_file", "res://Scenes/game.tscn")

func handle_enemy(area):
	print(area)
