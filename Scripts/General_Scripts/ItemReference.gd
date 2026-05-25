extends Node

####### all items (udate when necessary)
const all_items = ["unarmed","rusty_bar","test_sword","health_potion","chinese_blade"]

####### all containers
const all_containers = ["barrel","wooden_bpx","large_gravestone_intact","large_gravestone_broken"]


const persistence_list = ["none","stone_key","iron_key","institute_wood_key","institute_heavy_key","lantern"]


#test
const items_test = ["bellhammer","stone_key"] #name of the item on the map // the _string is indicative of the map the items are supposed to appear
const item_positions_test = [Vector3(-9.5,-3.5,4.5),Vector3(56,4,2.6)] #the positions of the items in the world / map // in global space!
const pickup_status_test = [false,false] #the status of the item, if false, then it has not yet been picked up. True if picked up and its supposed to never spawn again

const containers_test = ["barrel","barrel","barrel","barrel","barrel","barrel","barrel","barrel","barrel","barrel","barrel","barrel","wooden_box","wooden_box","large_gravestone_intact","large_gravestone_broken"]
const container_contents_test = [["coin",8000],"nothing",["coin",100],["coin",150],"health_potion","nothing","health_potion","nothing",["coin",100],"health_potion",["coin",200],"nothing","health_potion",["coin",250],"health_potion","stamina_potion"]
const container_positions_test = [Vector3(-5.5,-4,0.3),Vector3(-4.2,-4,0.4),Vector3(15,3,0),Vector3(12,3,-1),Vector3(-14,-4,-43.5),Vector3(-19,-4,-43.5),Vector3(14,-4,9.5),Vector3(13,-4,9.5),Vector3(5,-8,14.5),Vector3(-9,-4,20.5),Vector3(-9,-4,21.5),Vector3(-9,-8,33.3),Vector3(43.3,2,-13.2),Vector3(44.6,2,-15),Vector3(-27,-4,-55),Vector3(-29,-4,-61)]
const container_status_test = [false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false] #determines the destruction/open state of the container

#village
const items_village = ["test_sword"]
const item_positions_village = [Vector3(103,0,-56)]
const pickup_status_village = [false]

const containers_village = ["barrel"]
const container_contents_village = ["health_potion"]
const container_positions_village = [Vector3(-6,-4,2)]
const container_status_village = [false] #determines the destruction/open state of the container

#castle_dungeon
const items_castle_dungeon = ["rusty_bar"]
const item_positions_castle_dungeon = [Vector3(0,0,0)]
const pickup_status_castle_dungeon = [false]

const containers_castle_dungeon = ["stone_chest"]
const container_contents_castle_dungeon = ["health_potion"]
const container_positions_castle_dungeon = [Vector3(42,-9,-28)]
const container_status_castle_dungeon = [false] #determines the destruction/open state of the container

#forest
const items_forest = []
const item_positions_forest = []
const pickup_status_forest = []

const containers_forest = []
const container_contents_forest = []
const container_positions_forest = []
const container_status_forest = [] #determines the destruction/open state of the container

#institute
const items_institute = ["institute_wood_key","institute_heavy_key"]
const item_positions_institute = [Vector3(31,0,-185),Vector3(31,0,-185)]
const pickup_status_institute = [false,false]

const containers_institute = []
const container_contents_institute = []
const container_positions_institute = []
const container_status_institute = [] #determines the destruction/open state of the container

#mountains
const items_mountains = []
const item_positions_mountains = []
const pickup_status_mountains = []

const containers_mountains = []
const container_contents_mountains = []
const container_positions_mountains = []
const container_status_mountains = [] #determines the destruction/open state of the container

#tramway
const items_tramway = []
const item_positions_tramway = []
const pickup_status_tramway = []

const containers_tramway = []
const container_contents_tramway = []
const container_positions_tramway = []
const container_status_tramway = [] #determines the destruction/open state of the container

#snowpeak
const items_snowpeak = []
const item_positions_snowpeak = []
const pickup_status_snowpeak = []

const containers_snowpeak = []
const container_contents_snowpeak = []
const container_positions_snowpeak = []
const container_status_snowpeak = [] #determines the destruction/open state of the container

#cave
const items_cave = []
const item_positions_cave = []
const pickup_status_cave = []

const containers_cave = []
const container_contents_cave = []
const container_positions_cave = []
const container_status_cave = [] #determines the destruction/open state of the container

#mountain_castle
const items_mountain_castle = []
const item_positions_mountain_castle = []
const pickup_status_mountain_castle = []

const containers_mountain_castle = []
const container_contents_mountain_castle = []
const container_positions_mountain_castle = []
const container_status_mountain_castle = [] #determines the destruction/open state of the container

#bridge
const items_bridge = []
const item_positions_bridge = []
const pickup_status_bridge = []

const containers_bridge = []
const container_contents_bridge = []
const container_positions_bridge = []
const container_status_bridge = [] #determines the destruction/open state of the container


func get_const(var_name: String) -> Array:
	var getter = get(var_name)
	return getter
