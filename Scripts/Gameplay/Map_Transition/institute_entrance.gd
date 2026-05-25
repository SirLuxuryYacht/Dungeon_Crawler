extends StaticBody3D

@onready var MapTransition = $MapTransition

var first_map = "forest"

var second_map = "institute"

func _ready() -> void:
	MapTransition.first_map = "forest"
	MapTransition.second_map = "institute"
	
	MapTransition.first_map_path = "res://Scenes/Maps/"+str(first_map)+".tscn"
	MapTransition.second_map_path = "res://Scenes/Maps/"+str(second_map)+".tscn"
