extends Node3D

@onready var MapTransition = $MapTransition

@export var first_map: String

@export var second_map: String

func _ready() -> void:
	MapTransition.first_map = first_map
	MapTransition.second_map = second_map
	
	MapTransition.first_map_path = "res://Scenes/Maps/"+str(first_map)+".tscn"
	MapTransition.second_map_path = "res://Scenes/Maps/"+str(second_map)+".tscn"
