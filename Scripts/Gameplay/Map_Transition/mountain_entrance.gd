extends StaticBody3D

@onready var MapTransition = $MapTransition

@export var first_map = "test"

@export var second_map = "mountains"

func _ready() -> void:
	MapTransition.first_map = "test"
	MapTransition.second_map = "mountains"
	
	MapTransition.first_map_path = "res://Scenes/Maps/"+str(first_map)+".tscn"
	MapTransition.second_map_path = "res://Scenes/Maps/"+str(second_map)+".tscn"
