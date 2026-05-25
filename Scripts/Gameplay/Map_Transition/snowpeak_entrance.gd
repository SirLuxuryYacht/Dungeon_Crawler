extends StaticBody3D

@onready var MapTransition = $MapTransition

var first_map = "tramway"

var second_map = "snowpeak"

func _ready() -> void:
	MapTransition.first_map = "tramway"
	MapTransition.second_map = "snowpeak"
	
	MapTransition.first_map_path = "res://Scenes/Maps/"+str(first_map)+".tscn"
	MapTransition.second_map_path = "res://Scenes/Maps/"+str(second_map)+".tscn"
