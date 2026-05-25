extends Node


func fillEnemyIdList(map: String) -> Array:
	var id_list = []
	for i in get("enemies_"+map).size():
		id_list.append(int(i))
	return id_list


func assignPermanencyStatus(Gameplay: Node, map: String, id: int) -> void:
	if get("does_respawn_"+map)[id] == false:
		Gameplay.get("permanency_status_"+map)[id] = false


#test
const enemies_test = ["survivor","spider","bat_test","bat_test","poly_character","marionette"] #name of the enemy on the map // the _string is indicative of the map the items are supposed to appear
const enemy_positions_test = [Vector3(-14,-3,-12),Vector3(-14,-3,-10),Vector3(-32,-4,28),Vector3(-28,-3,36),Vector3(49,7,-79),Vector3(47,2,-32)] #the positions of the enemies in the world / map // in global space!
const does_respawn_test = [true,false,true,false,false,false] #comparison array to determine if an enemy should respawn
const permanency_status_test = [true,true,true,true,true,true] #the status of the enemy, if false, the enemy doesnt respawn when the map is reloaded. Gets changed dynamically, this is just the initial status
@onready var enemy_ids_test = fillEnemyIdList("test")

#village
const enemies_village = ["spider"]
const enemy_positions_village = [Vector3(103,0,-56)]
const does_respawn_village = [true]
const permanency_status_village = [true]
@onready var enemy_ids_village = fillEnemyIdList("village")

#castle_dungeon
const enemies_castle_dungeon = ["marionette"]
const enemy_positions_castle_dungeon = [Vector3(42,-9,-31)]
const does_respawn_castle = [true]
const permanency_status_castle_dungeon = [true]
@onready var enemy_ids_castle_dungeon = fillEnemyIdList("castle_dungeon")

#forest
const enemies_forest = []
const enemy_positions_forest = []
const does_respawn_forest = []
const permanency_status_forest = []
@onready var enemy_ids_forest = fillEnemyIdList("forest")

#institute
const enemies_institute = ["survivor"]
const enemy_positions_institute = [Vector3(6,-1,-165)]
const does_respawn_institute = [true]
const permanency_status_institute = [true]
@onready var enemy_ids_institute = fillEnemyIdList("institute")

#mountains
const enemies_mountains = ["spider","spider"]
const enemy_positions_mountains = [Vector3(-46,-8,116),Vector3(-46,1,116)]
const does_respawn_mountains = [true,true]
const permanency_status_mountains = [true,true]
@onready var enemy_ids_mountains = fillEnemyIdList("mountains")

#tramway
const enemies_tramway = []
const enemy_positions_tramway = []
const does_respawn_tramway = []
const permanency_status_tramway = []
@onready var enemy_ids_tramway = fillEnemyIdList("tramway")

#snowpeak
const enemies_snowpeak = []
const enemy_positions_snowpeak = []
const does_respawn_snowpeak = []
const permanency_status_snowpeak = []
@onready var enemy_ids_snowpeak = fillEnemyIdList("snowpeak")

#cave
const enemies_cave = []
const enemy_positions_cave = []
const does_respawn_cave = []
const permanency_status_cave = []
@onready var enemy_ids_cave = fillEnemyIdList("cave")

#mountain_castle
const enemies_mountain_castle = []
const enemy_positions_mountain_castle = []
const does_respawn_mountain_castle = []
const permanency_status_mountain_castle = []
@onready var enemy_ids_mountain_castle = fillEnemyIdList("mountain_castle")

#bridge
const enemies_bridge = []
const enemy_positions_bridge = []
const does_respawn_bridge = []
const permanency_status_bridge = []
@onready var enemy_ids_bridge = fillEnemyIdList("bridge")


func get_const(var_name: String) -> Array:
	var getter = get(var_name)
	return getter
