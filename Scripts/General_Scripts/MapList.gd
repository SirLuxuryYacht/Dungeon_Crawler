extends Node

var map_list = ["test","village","castle_dungeon","forest","institute","mountains","tramway","snowpeak","cave","mountain_castle","bridge"]

var map_positions = [Vector3(0,0,0),Vector3(103,-4,-56),Vector3(0,0,0),Vector3(0,0,0),Vector3(0,0,0),Vector3(0,0,0),Vector3(0,0,0),Vector3(0,0,0),Vector3(0,0,0),Vector3(0,0,0),Vector3(0,0,0)]

var map_rotations = [Vector3(0,0,0),Vector3(0,0,0),Vector3(0,0,0),Vector3(0,0,0),Vector3(0,0,0),Vector3(0,0,0),Vector3(0,0,0),Vector3(0,0,0),Vector3(0,0,0),Vector3(0,0,0),Vector3(0,0,0)] #rotations should be zero, otherwise the placement of enemies and items is busted (some strange transforms)

var map_soundtracks = ["track_1","track_2","track_4","track_6","track_4","track_10","track_3","track_3","","track_9",""]


func showTransitions(transition_list: Array, MapTransitions: Node3D) -> void:
	for i in transition_list.size():
		MapTransitions.get_node(str(transition_list[i])+"Entrance").visible = true

func updateTransitionVisibility(map: String, Gameplay: Node) -> void:
	var MapTransitions = Gameplay.get_node("VirtualSpace/MapTransitions")
	for i in MapTransitions.get_child_count():
		MapTransitions.get_child(i).visible = false #resets all visibilities, so the visibilities can be turned on individually below
	
	match map:
		"test":
			showTransitions(["Dungeon","Forest","Mountain","Cave"],MapTransitions)
		"village":
			pass
		"castle_dungeon":
			showTransitions(["Dungeon"],MapTransitions)
		"forest":
			showTransitions(["Forest","Institute"],MapTransitions)
		"institute":
			showTransitions(["Institute"],MapTransitions)
		"mountains":
			showTransitions(["Mountain","Tramway"],MapTransitions)
		"tramway":
			showTransitions(["Tramway","Snowpeak"],MapTransitions)
		"snowpeak":
			showTransitions(["Snowpeak"],MapTransitions)
		"cave":
			showTransitions(["Cave","MountainCastle"],MapTransitions)
		"mountain_castle":
			showTransitions(["MountainCastle"],MapTransitions)


func getMapIndex(map_name) -> int:
	var index = 0
	while map_list[index] != map_name and index <= map_list.size():
		index += 1
	return index

func getMapPosition(map_name: String) -> Vector3:
	return map_positions[getMapIndex(map_name)]
	
func getMapRotation(map_name: String) -> Vector3:
	return map_rotations[getMapIndex(map_name)]
	
func getMapSoundtrack(map_name: String) -> String:
	return map_soundtracks[getMapIndex(map_name)]
