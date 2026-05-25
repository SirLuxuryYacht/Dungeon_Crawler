extends Node

####### all doors and keys (maybe redundand)
const door_list = ["stone_door"]
const key_list = ["stone_key"]

#test
const doors_test = ["stone_door","iron_door","iron_door","faulty_mirror","stone_door","iron_door"]
const door_positions_test = [Vector3(-4,-4,-32),Vector3(-15,-4,35),Vector3(40,6,-88),Vector3(50.5,2,-11),Vector3(60.5,6,-67.5),Vector3(30.5,2,25)]
const door_status_test = [false,false,false,false,false,false] #already opened? this is false by default, only updated during gameplay

#castle_dungeon
const doors_castle_dungeon = []
const door_positions_castle_dungeon = []
const door_status_castle_dungeon = [] #already opened? this is false by default, only updated during gameplay

#village
const doors_village = ["stone_door"]
const door_positions_village = [Vector3(0,0,0)]
const door_status_village = [false] #already opened? this is false by default, only updated during gameplay

#forest
const doors_forest = []
const door_positions_forest = []
const door_status_forest = [] #already opened? this is false by default, only updated during gameplay

#institute
const doors_institute = ["remnant_wooden_door","remnant_wooden_door","remnant_wooden_door","remnant_wooden_door","remnant_wooden_door","remnant_wooden_door","remnant_wooden_door","remnant_heavy_door"]
const door_positions_institute = [Vector3(-13,0,22),Vector3(-11,0,18),Vector3(-20,0,22),Vector3(-27,0,22),Vector3(-18,0,18),Vector3(-25,0,18),Vector3(22,0,26),Vector3(-9,-18,-16)]
const door_status_institute = [false,false,false,false,false,false,false,false] #already opened? this is false by default, only updated during gameplay

#mountains
const doors_mountains = ["iron_door"]
const door_positions_mountains = [Vector3(-21.5,7,11)]
const door_status_mountains = [false] #already opened? this is false by default, only updated during gameplay

#tramway
const doors_tramway = []
const door_positions_tramway = []
const door_status_tramway = [] #already opened? this is false by default, only updated during gameplay

#snowpeak
const doors_snowpeak = []
const door_positions_snowpeak = []
const door_status_snowpeak = [] #already opened? this is false by default, only updated during gameplay

#cave
const doors_cave = []
const door_positions_cave = []
const door_status_cave = [] #already opened? this is false by default, only updated during gameplay

#mountain_castle
const doors_mountain_castle = []
const door_positions_mountain_castle = []
const door_status_mountain_castle = [] #already opened? this is false by default, only updated during gameplay

#bridge
const doors_bridge = []
const door_positions_bridge = []
const door_status_bridge = [] #already opened? this is false by default, only updated during gameplay

func get_const(var_name: String) -> Array:
	var getter = get(var_name)
	return getter
