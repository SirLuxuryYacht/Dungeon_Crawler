extends Node


func findItemCategory(item_name: String) -> String:
	var found_category = ""
	for category in tradeables:
		if !("_prices" in category):
			for item in tradeables[category]:
				if item == item_name:
					found_category = category
					break
	return found_category


const tradeables: Dictionary = {
	"usables" = ["health_potion","stamina_potion","lantern","stone_key","iron_key","institute_wood_key"],
	"usables_prices" = [10,10,50,60,100,2],
	"weapons" = ["longsword","rifle","rusty_bar","chinese_blade","katana","bellhammer","poleaxe"],
	"weapons_prices" = [300,1600,20,1200,1100,1800,1300],
	"boots" = [],
	"boots_prices" = [],
	"greaves" = [],
	"greaves_prices" = [],
	"chest" = [],
	"chest_prices" = [],
	"gloves" = [],
	"gloves_prices" = [],
	"head" = [],
	"head_prices" = [],
	"shields" = [],
	"shields_prices" = []
}


func getTradePrice(item_name: String, price_multiplicator: float) -> int:
	var price = 0
	var index = -1
	for categories in tradeables:
		if !("_prices" in categories):
			index = tradeables[categories].find(item_name)
			if index > -1:
				price = tradeables[categories+"_prices"][index]
				break
	return price * price_multiplicator


const trade_inventories: Dictionary = {
	"test_trader_1" = [["health_potion",3,0],["stamina_potion",20,0],["lantern",1,0],["katana",1,0],["bellhammer",1,0],["chinese_blade",1,0],["rusty_bar",1,0],["rifle",1,0],["iron_key",1,0],["poleaxe",1,0]] #item_name, amount in inventory, price
}
