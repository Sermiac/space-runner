extends Node

var level
# Controls global game speed
@export var SPEED = 2.0
# Level Nodes
var tile_map
var background
var player
var p_init
var ba_init

func _on_exit_button_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/main_menu.tscn")
	
	
func _physics_process(delta: float) -> void:
	if level:
		var p_pos = player.global_position
		var ba_pos = background.global_position 
		# BACKGROUND MOVEMENT
		background.global_position.x = (p_pos.x - p_init.x) + ba_init.x
		background.global_position.y = (p_pos.y - p_init.y) / 2 + ba_init.y
		# PLAYER MOVEMENT
		


func level_selected(btn_name):
	btn_name = btn_name.to_lower()
	# set nodes
	tile_map = get_node("%s/floor/TileMapLayer" % btn_name)
	background = get_node("%s/Parallax2D/Sprite2D" % btn_name)
	player = get_node("%s/player" % btn_name)
	# set nodes properties
	player.game_ctrl = self
	p_init = player.global_position
	ba_init = background.position
	background.global_position = (p_init - p_init) + ba_init
	
	init_tiles()
	
	spd_controller(SPEED)
	$Timer.start()
	

func init_tiles():
	for i in range(20):
		for j in range(3):
			tile_map.set_cell(Vector2i(i - 10, -1 - j), 2, Vector2i(1,0))
	var cells = tile_map.get_used_cells()
	tile_map.set_cells_terrain_connect(cells, 0, 0)
	tile_map.set_cell(cells[0], 2, Vector2i(0,0))
	tile_map.set_cell(cells[-1], 2, Vector2i(2,0))

func update_tiles():
	var added_cells = []
	var cells = tile_map.get_used_cells()
	# Create
	for i in range(3):
		# Create
		var new_cell = cells[-1 - i] + Vector2i(1,0)
		tile_map.set_cell(new_cell, 2, Vector2i(2,0))
		# Delete
		tile_map.set_cell(cells[0 + i], -1)
		added_cells += [new_cell]
	# Update
	tile_map.set_cells_terrain_connect(added_cells, 0, 0)

"""
func update_player_area(btn_name):
	var player_area = get_node("%s/player/player_area" % btn_name)
	player_area.connect("area_entered", player_area_entered)
	
func player_area_entered(area):
	print(area)
"""

func spd_controller(speed):
	#CON ESCALA 10 EN EL TILEMAP
	#$Timer.wait_time = speed / 2
	#CON ESCALA 4.5 EN EL TILEMAP
	$Timer.wait_time = speed / 4.55

# Clock
func _on_timer_timeout() -> void:
	update_tiles()
