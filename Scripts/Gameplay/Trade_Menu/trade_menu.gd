extends Control


@onready var Gameplay = get_tree().root.get_node("Main/Gameplay")
@onready var HUD = Gameplay.getPlayer().getHud()

var trade_inventory

var character_name: String

var trader_cheapness: int

@onready var BuySubMenu = $BuySubMenu
@onready var TraderNameLabel = $BuySubMenu/TraderNameLabel
@onready var CoinAmount = $BuySubMenu/CoinAmount
@onready var ItemPicture = $BuySubMenu/ItemPicture
@onready var ItemDescriptionLabel = $BuySubMenu/ItemDescriptionLabel
@onready var CostAmount = $BuySubMenu/CostAmount
@onready var ItemNameLabel = $BuySubMenu/ItemNameLabel
@onready var QuantityAmount = $BuySubMenu/QuantityAmount
@onready var BuyButton = $BuySubMenu/BuyButton
@onready var SellButton = $BuySubMenu/SellButton
@onready var coin_amount = Gameplay.coin_count
@onready var item_amount: int

var trader = null

@onready var item_number = 0

var is_selling = false


func displayItem(number: int) -> void:
	var item_name = trade_inventory[number][0]
	var item_quantity = trade_inventory[number][1]
	var item_cost = trade_inventory[number][2]
	var item_texture
	if ResourceLoader.exists("res://Textures/ItemPictures/"+item_name+".png"):
		item_texture = "res://Textures/ItemPictures/"+item_name+".png"
	elif item_name != "none":
		item_texture = "res://Textures/ItemPictures/placeholder.png"
	if item_name == "none":
		item_texture = "res://Textures/ItemPictures/sold_out.png"
		item_quantity = 0
		item_cost = 0
		BuyButton.disabled = true
		ItemDescriptionLabel.text = "Sold out!"
	elif Gameplay.coin_count < item_cost:
		if !is_selling:
			BuyButton.disabled = true
		ItemDescriptionLabel.text = ItemDescriptions.getDescription(item_name)
	else:
		BuyButton.disabled = false
		ItemDescriptionLabel.text = ItemDescriptions.getDescription(item_name)
	if item_quantity == -1:
		QuantityAmount.text = "∞"
	else:
		QuantityAmount.text = str(item_quantity)
	ItemPicture.texture = load(item_texture)
	CostAmount.text = str(item_cost)
	ItemNameLabel.text = Designators.represent("item",trade_inventory[number][0])

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CoinAmount.text = str(coin_amount)
	trade_inventory = stitchTraderInventories(trade_inventory)
	item_amount = trade_inventory.size() - 1
	displayItem(item_number)
	TraderNameLabel.text = Designators.represent("trader",character_name)
	HUD.visible = false
	


func updateButtonText() -> void:
	if is_selling:
		BuyButton.text = "Sell"
		SellButton.text = "Buy Items"
	else:
		BuyButton.text = "Buy"
		SellButton.text = "Sell Items"


func displayCoinCount(amount) -> void:
	CoinAmount.text = str(amount)


func stitchTraderInventories(trader_inventory: Array) -> Array:
	var stitched_inventory = []
	var stored_item_old: String = ""
	var stored_item_new: String = ""
	var stitch_index = -1
	var stored_amount = 0
	
	for index in trader_inventory.size():
		stored_item_new = trader_inventory[index][0]
		stored_amount = trader_inventory[index][1]
		if stored_item_new != stored_item_old:
			stitched_inventory.append([stored_item_new,stored_amount,TraderInventories.getTradePrice(stored_item_new,trader_cheapness)])
			stitch_index += 1
		else:
			stitched_inventory[stitch_index][1] += stored_amount
		stored_item_old = stored_item_new
	return stitched_inventory


func stitchPlayerInventories() -> Array:
	var stitched_inventory = []
	var stored_item_old: String = ""
	var stored_item_new: String = ""
	var stitch_index = -1
	
	for index in Gameplay.inventory_weapons.size(): ## weapons
		stored_item_new = Gameplay.inventory_weapons[index]
		if stored_item_new != "unarmed":
			if stored_item_new != stored_item_old:
				stitched_inventory.append([stored_item_new,1,TraderInventories.getTradePrice(stored_item_new,1.0/trader_cheapness)])
				stitch_index += 1
			else:
				stitched_inventory[stitch_index][1] += 1
		stored_item_old = stored_item_new
	
	for index in Gameplay.inventory_armor_1.size(): ## helmets
		stored_item_new = Gameplay.inventory_armor_1[index]
		if stored_item_new != "none":
			if stored_item_new != stored_item_old:
				stitched_inventory.append([stored_item_new,1,TraderInventories.getTradePrice(stored_item_new,1.0/trader_cheapness)])
				stitch_index += 1
			else:
				stitched_inventory[stitch_index][1] += 1
		stored_item_old = stored_item_new
	
	for index in Gameplay.inventory_armor_2.size(): ## chestpieces
		stored_item_new = Gameplay.inventory_armor_2[index]
		if stored_item_new != "none":
			if stored_item_new != stored_item_old:
				stitched_inventory.append([stored_item_new,1,TraderInventories.getTradePrice(stored_item_new,1.0/trader_cheapness)])
				stitch_index += 1
			else:
				stitched_inventory[stitch_index][1] += 1
		stored_item_old = stored_item_new
	
	for index in Gameplay.inventory_armor_3.size(): ## gloves
		stored_item_new = Gameplay.inventory_armor_3[index]
		if stored_item_new != "none":
			if stored_item_new != stored_item_old:
				stitched_inventory.append([stored_item_new,1,TraderInventories.getTradePrice(stored_item_new,1.0/trader_cheapness)])
				stitch_index += 1
			else:
				stitched_inventory[stitch_index][1] += 1
		stored_item_old = stored_item_new
	
	for index in Gameplay.inventory_armor_4.size(): ## greaves
		stored_item_new = Gameplay.inventory_armor_4[index]
		if stored_item_new != "none":
			if stored_item_new != stored_item_old:
				stitched_inventory.append([stored_item_new,1,TraderInventories.getTradePrice(stored_item_new,1.0/trader_cheapness)])
				stitch_index += 1
			else:
				stitched_inventory[stitch_index][1] += 1
		stored_item_old = stored_item_new
	
	for index in Gameplay.inventory_armor_5.size(): ## boots
		stored_item_new = Gameplay.inventory_armor_5[index]
		if stored_item_new != "none":
			if stored_item_new != stored_item_old:
				stitched_inventory.append([stored_item_new,1,TraderInventories.getTradePrice(stored_item_new,1.0/trader_cheapness)])
				stitch_index += 1
			else:
				stitched_inventory[stitch_index][1] += 1
		stored_item_old = stored_item_new
	
	for index in Gameplay.inventory_shields.size(): ## shields
		stored_item_new = Gameplay.inventory_shields[index]
		if stored_item_new != "none":
			if stored_item_new != stored_item_old:
				stitched_inventory.append([stored_item_new,1,TraderInventories.getTradePrice(stored_item_new,1.0/trader_cheapness)])
				stitch_index += 1
			else:
				stitched_inventory[stitch_index][1] += 1
		stored_item_old = stored_item_new
	
	for index in Gameplay.inventory_usables.size(): ## usables
		stored_item_new = Gameplay.inventory_usables[index][0]
		var little_array = Gameplay.inventory_usables[index]
		little_array.append(TraderInventories.getTradePrice(stored_item_new,1.0/trader_cheapness))
		if stored_item_new != "none":
			stitched_inventory.append(little_array)
	return stitched_inventory


func buyItem(number) -> void:
	var item_category = TraderInventories.findItemCategory(trade_inventory[number][0])
	Gameplay.addItem(trade_inventory[number][0],Gameplay.getTypeFromCategory(item_category))
	if trade_inventory[number][1] != -1:
		trade_inventory[number][1] -= 1
	if trade_inventory[number][1] == 0:
		trade_inventory[number][0] = "none"
	Gameplay.trade_inventories[character_name] = trade_inventory
	Gameplay.coin_count -= trade_inventory[number][2]
	displayCoinCount(Gameplay.coin_count)
	displayItem(number)


func sellItem(number) -> void:
	var item_category = TraderInventories.findItemCategory(trade_inventory[number][0])
	Gameplay.removeItem(trade_inventory[number][0],Gameplay.getTypeFromCategory(item_category))
	Gameplay.trade_inventories[character_name].append([trade_inventory[number][0],1,0])
	if trade_inventory[number][1] != -1:
		trade_inventory[number][1] -= 1
	if trade_inventory[number][1] == 0:
		trade_inventory[number][0] = "none"
	Gameplay.coin_count += trade_inventory[number][2]
	displayCoinCount(Gameplay.coin_count)
	displayItem(number)


func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("move_right"):
		if item_number == item_amount:
			item_number = 0
		else:
			item_number += 1
		displayItem(item_number)
	if Input.is_action_just_pressed("move_left"):
		if item_number == 0:
			item_number = item_amount
		else:
			item_number -= 1
		displayItem(item_number)
	if Input.is_action_just_pressed("pause"):
		_on_close_button_button_up()


func _on_buy_button_button_up() -> void:
	if is_selling:
		sellItem(item_number)
	else:
		buyItem(item_number)


func _on_close_button_button_up() -> void:
	trade_inventory = Gameplay.trade_inventories[character_name]
	is_selling = false
	Gameplay.closeTradeMenu(character_name)
	HUD.visible = true


func _on_talk_button_button_up() -> void:
	Gameplay.closeTradeMenu(character_name)
	HUD.visible = true
	if trader != null:
		Gameplay.openDialogue(trader,false)


func _on_sell_button_button_up() -> void:
	if !is_selling:
		trade_inventory = stitchPlayerInventories()
		TraderNameLabel.text = "Your Items"
	else:
		trade_inventory = stitchTraderInventories(Gameplay.trade_inventories[character_name])
		TraderNameLabel.text = Designators.represent("trader",character_name)
	is_selling = !is_selling
	item_number = 0
	item_amount = trade_inventory.size() - 1
	displayItem(item_number)
	updateButtonText()


func _physics_process(delta: float) -> void:
	pass
	
