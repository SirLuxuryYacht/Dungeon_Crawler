extends Node3D

@onready var Gameplay = get_tree().root.get_node("Main/Gameplay")
@onready var Maps = Gameplay.get_node("VirtualSpace/Maps")
@onready var MapTransitions = Gameplay.get_node("VirtualSpace/MapTransitions")

@onready var Map1 = null
@onready var Map2 = null

var first_map: String
var first_map_position : Vector3
var first_map_rotation : Vector3
var first_map_soundtrack : String
var second_map: String
var second_map_position : Vector3
var second_map_rotation : Vector3
var second_map_soundtrack : String

@onready var LoadingHandler = $LoadingHandler
@onready var LoadTimer = $LoadTimer


var first_map_path = "res://Scenes/Maps/"+str(first_map)+".tscn"
var second_map_path = "res://Scenes/Maps/"+str(second_map)+".tscn"


func _ready() -> void:
	pass


func addMapContent(map_instance,map_name) -> void:
	Maps.add_child(map_instance)
	Gameplay.fillMapWithItems(map_name)
	Gameplay.fillMapWithEnemies(map_name)
	Gameplay.spawnContainers(map_name)


func _on_load_box_1_body_exited(_body: Node3D) -> void:
	if !Maps.has_node(second_map):
		ResourceLoader.load_threaded_request(second_map_path)
		Gameplay.itemSweeper()
		Gameplay.enemySweeper()
		Gameplay.sweepContainers()
	else:
		Maps.get_node(second_map).queue_free()
	if !Maps.has_node(first_map):
		var map_1 = ResourceLoader.load_threaded_get(first_map_path).instantiate()
		map_1.position = MapList.getMapPosition(first_map)
		map_1.rotation = MapList.getMapRotation(first_map)
		LoadingHandler.visible = true
		Gameplay.loaded_map = first_map
		Signals.change_soundtrack.emit(MapList.getMapSoundtrack(first_map))
		LoadTimer.start()
		await LoadTimer.timeout
		addMapContent(map_1,first_map)
		LoadingHandler.visible = false
		LoadTimer.start()
		MapList.updateTransitionVisibility(first_map,Gameplay)


func _on_load_box_2_body_exited(_body:Node3D) -> void:
	if !Maps.has_node(first_map):
		ResourceLoader.load_threaded_request(first_map_path)
		Gameplay.itemSweeper()
		Gameplay.enemySweeper()
		Gameplay.sweepContainers()
	else:
		Maps.get_node(first_map).queue_free()
	if !Maps.has_node(second_map):
		var map_2 = ResourceLoader.load_threaded_get(second_map_path).instantiate()
		map_2.position = MapList.getMapPosition(second_map)
		map_2.rotation = MapList.getMapRotation(second_map)
		LoadingHandler.visible = true
		Gameplay.loaded_map = second_map
		Signals.change_soundtrack.emit(MapList.getMapSoundtrack(second_map))
		LoadTimer.start()
		await LoadTimer.timeout
		addMapContent(map_2,second_map)
		LoadingHandler.visible = false
		MapList.updateTransitionVisibility(second_map,Gameplay)
	

func _on_load_timer_timeout() -> void:
	pass
