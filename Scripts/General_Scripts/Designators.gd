extends Node


func findRepresentation(list: Array,name_: String) -> int:
	var index = 0
	while name_ != list[index] and index <= list.size():
		index += 1
	return index


func represent(type: String,name_: String) -> String:
	var clears = get("clears_"+type)
	var synonyms = get("synonyms_"+type)
	return synonyms[findRepresentation(clears,name_)]


#### item orders
const order_weapons = ["unarmed","rusty_bar","testsword","longsword","katana","chinese_blade","poleaxe","bellhammer","rifle"]

const order_usables = ["none","stamina_potion","health_potion","lantern","stone_key","iron_key","institute_wood_key","institute_heavy_key"]

const order_helmet = ["none"]

const order_chestpiece = ["none"]

const order_gloves = ["none"]

const order_greaves = ["none"]

const order_boots = ["none"]

const order_shields = ["none"]

#### clears and synonyms
const clears_map = ["test","castle_dungeon","forest","institute","mountains","tramway","snowpeak","cave","mountain_castle","bridge"]
const synonyms_map = ["Castle","Castle Dungeon","Forest","Institute","Mountains","Tramway","Snowy Peak","Cave","Mountain Castle","Bridge"]

const clears_item = ["none","coin","stone_key","iron_key","institute_wood_key","institute_heavy_key","health_potion","stamina_potion","unarmed","rusty_bar","longsword","test_sword","rifle","lantern","katana","chinese_blade","poleaxe","bellhammer"]
const synonyms_item = ["None","Coin","Stone Key","Iron Key","Low Security Key","High Security Key","Health Potion","Stamina Potion","Unarmed","Rusty Bar","Longsword","Test Sword","Rifle","Lantern","Odachi","Great Jian","Poleaxe","Bellhammer"]

const clears_trader = ["test_trader_1"]
const synonyms_trader = ["Peter Funny's Pawnshop"]
