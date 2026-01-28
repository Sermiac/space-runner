@tool
extends Node2D

@export var prop_scene: PackedScene
@export_enum("Derecha", "Izquierda") var direction := 1:
	set(value):
		direction = value
		update_visual()
@export var extra_data := {}

@onready var sprite = $Sprite2D if self.has_node("Sprite2D") else null
@onready var activate: ColorRect = $activate if self.has_node("activate") else null


func _ready():
	update_visual()


func update_visual():
	if sprite:
		if self.name == "plant":
			var anim = "derecha" if direction == 0 else "izquierda"
			sprite.play(anim)
		else:
			sprite.flip_h = true if direction == 0 else false
			
	if activate and self.name != "worm":
		activate.position.x = -61 if direction == 0 else -528
