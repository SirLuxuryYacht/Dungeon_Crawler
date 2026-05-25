extends StaticBody3D

@onready var MapTransition = $MapTransition

var first_map = "mountains"

var second_map = "tramway"

func _ready() -> void:
	MapTransition.first_map = "mountains"
	MapTransition.second_map = "tramway"
	
	MapTransition.first_map_path = "res://Scenes/Maps/"+str(first_map)+".tscn"
	MapTransition.second_map_path = "res://Scenes/Maps/"+str(second_map)+".tscn"
