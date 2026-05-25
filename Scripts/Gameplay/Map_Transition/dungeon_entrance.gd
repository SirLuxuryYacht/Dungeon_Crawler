extends StaticBody3D

@onready var MapTransition = $MapTransition

var first_map = "test"

var second_map = "castle_dungeon"

func _ready() -> void:
	MapTransition.first_map = "test"
	MapTransition.second_map = "castle_dungeon"
	
	MapTransition.first_map_path = "res://Scenes/Maps/"+str(first_map)+".tscn"
	MapTransition.second_map_path = "res://Scenes/Maps/"+str(second_map)+".tscn"
