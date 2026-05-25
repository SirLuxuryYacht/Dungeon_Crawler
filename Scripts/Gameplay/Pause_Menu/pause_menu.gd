extends Control

@onready var Main = get_tree().root.get_node("Main")
@onready var Gameplay = get_tree().root.get_node("Main/Gameplay")
@onready var Player = Gameplay.get_node("VirtualSpace/PlayerNode/Player")
@onready var GameMenu = $GameMenu
@onready var SystemMenu = $SystemMenu
@onready var Continue = $SystemMenu/Continue
@onready var ReturnToMenu = $SystemMenu/ReturnToMenu
@onready var SystemMenuButton = $GameMenu/SystemMenuButton
@onready var SettingsButton = $SystemMenu/SettingsButton
@onready var GameMenuButton = $SystemMenu/GameMenuButton
@onready var SaveGameButton = $SystemMenu/SaveGameButton
@onready var weapon1 = $GameMenu/weapon1
@onready var weapon2 = $GameMenu/weapon2
@onready var weapon3 = $GameMenu/weapon3
@onready var usable1 = $GameMenu/usable1
@onready var usable2 = $GameMenu/usable2
@onready var usable3 = $GameMenu/usable3
@onready var armor1 = $GameMenu/armor1
@onready var armor2 = $GameMenu/armor2
@onready var armor3 = $GameMenu/armor3
@onready var armor4 = $GameMenu/armor4
@onready var armor5 = $GameMenu/armor5
@onready var shield = $GameMenu/shield

@onready var DropButton = $GameMenu/InventoryBackground/DropButton

@onready var CloseRefusal = $CloseRefusal

@onready var ItemPicture = $GameMenu/InventoryBackground/ItemPicture
@onready var ItemName = $GameMenu/InventoryBackground/ItemName
@onready var DescriptionLabel = $GameMenu/InventoryBackground/DescriptionBackground/DescriptionLabel
@onready var Amount = $GameMenu/InventoryBackground/Amount
@onready var AmountLabel = $GameMenu/InventoryBackground/Amount/AmountLabel

@onready var CoinCountLabel = $GameMenu/CoinCountLabel

@onready var InventoryBackground = $GameMenu/InventoryBackground

@onready var SaveGameScreenHandler = $SaveGameScreenHandler
@onready var SettingsMenuHandler = $SettingsMenuHandler

var selected_inventory = []

var selected_category = ""

var selected_item_id = 0

var selected_item_name = ""

var inventory_open = false

var button_memory = ""

var can_close = false


func _ready() -> void:
	displayEquipped()
	CloseRefusal.start()
	CoinCountLabel.text = str(Gameplay.coin_count)


func _input(_event: InputEvent) -> void:
	if inventory_open:
		if selected_inventory.size() > 0:
			if Input.is_action_just_pressed("move_right"):
				if selected_item_id < selected_inventory.size() - 1:
					selected_item_id += 1
				else:
					selected_item_id = 0
				displayItems(selected_category,selected_item_id)
				equipSelected(selected_category,selected_item_id)
			if Input.is_action_just_pressed("move_left"):
				if selected_item_id > 0:
					selected_item_id -= 1
				else:
					selected_item_id = selected_inventory.size() - 1
				displayItems(selected_category,selected_item_id)
				equipSelected(selected_category,selected_item_id)
		if Input.is_action_just_pressed("pause"):
			InventoryBackground.visible = false
			inventory_open = false
			selected_item_id = 0
			CloseRefusal.start()
	if can_close:
		if Input.is_action_just_pressed("pause"):
			Gameplay.closePauseMenu()


func displayEquipped() -> void:
	for i in 3:
		get("weapon"+str(i+1)).text = Designators.represent("item",Gameplay.equipped_weapons[i])
		get("usable"+str(i+1)).text = Designators.represent("item",Gameplay.equipped_usables[i])
	for i in 5:
		get("armor"+str(i+1)).text = Designators.represent("item",Gameplay.equipped_armor[i])
	get("shield").text = Designators.represent("item",Gameplay.equipped_shield)


func heavisideInt(k: int) -> int:
	if k >= 0:
		return k
	else:
		return 0


func getIdByName(item_name:String,inventory: Array) -> int:
	var id = 0
	if inventory.size() > 0:
		if inventory[0] is Array:
			for index in inventory.size():
				if inventory[index].has(item_name):
					id = index
		else:
			id = heavisideInt(inventory.find(item_name))
	return id


func displayItems(inventory_category: String,item_id: int) -> void:
	Amount.visible = false
	DropButton.disabled = true
	var item_texture
	if Gameplay.get("inventory_"+inventory_category).size() > 0:
		if Gameplay.get("inventory_"+inventory_category)[0] is Array: #this is the case for usables, all other categories dont use two dimensional arrays
			if ResourceLoader.exists("res://Textures/ItemPictures/"+Gameplay.get("inventory_"+inventory_category)[item_id][0]+".png"):
				item_texture = "res://Textures/ItemPictures/"+Gameplay.get("inventory_"+inventory_category)[item_id][0]+".png"
				AmountLabel.text = str(Gameplay.get("inventory_"+inventory_category)[item_id][1])
			else:
				item_texture = "res://Textures/ItemPictures/placeholder.png"
			selected_item_name = Gameplay.get("inventory_"+inventory_category)[item_id][0]
			if selected_item_name != "none":
				Amount.visible = true
				DropButton.disabled = false
			ItemName.text = Designators.represent("item",selected_item_name)
			DescriptionLabel.text = ItemDescriptions.getDescription(selected_item_name)
		else:
			if ResourceLoader.exists("res://Textures/ItemPictures/"+Gameplay.get("inventory_"+inventory_category)[item_id]+".png"):
				item_texture = "res://Textures/ItemPictures/"+Gameplay.get("inventory_"+inventory_category)[item_id]+".png"
			else:
				item_texture = "res://Textures/ItemPictures/placeholder.png"
			selected_item_name = Gameplay.get("inventory_"+inventory_category)[item_id]
			if selected_item_name != "unarmed":
					DropButton.disabled = false
			ItemName.text = Designators.represent("item",selected_item_name)
			DescriptionLabel.text = ItemDescriptions.getDescription(selected_item_name)
	else:
		ItemName.text = "Nothing selected."
		DescriptionLabel.text = "Select an item."
		item_texture = "res://Textures/ItemPictures/no_item.png"
	ItemPicture.texture = load(item_texture) 


func equipSelected(inventory_category: String,item_id: int) -> void:
	match button_memory:
		"weapon_1":
			Gameplay.get("equipped_"+inventory_category)[0] = Gameplay.get("inventory_"+inventory_category)[item_id]
		"weapon_2":
			Gameplay.get("equipped_"+inventory_category)[1] = Gameplay.get("inventory_"+inventory_category)[item_id]
		"weapon_3":
			Gameplay.get("equipped_"+inventory_category)[2] = Gameplay.get("inventory_"+inventory_category)[item_id]
		"usable_1":
			Gameplay.get("equipped_"+inventory_category)[0] = Gameplay.get("inventory_"+inventory_category)[item_id][0] #item inventory has item plus amount of item
		"usable_2":
			Gameplay.get("equipped_"+inventory_category)[1] = Gameplay.get("inventory_"+inventory_category)[item_id][0]
		"usable_3":
			Gameplay.get("equipped_"+inventory_category)[2] = Gameplay.get("inventory_"+inventory_category)[item_id][0]
		"armor_1":
			Gameplay.get("equipped_"+inventory_category)[0] = Gameplay.get("inventory_"+inventory_category)[0][item_id]
		"armor_2":
			Gameplay.get("equipped_"+inventory_category)[1] = Gameplay.get("inventory_"+inventory_category)[1][item_id]
		"armor_3":
			Gameplay.get("equipped_"+inventory_category)[2] = Gameplay.get("inventory_"+inventory_category)[2][item_id]
		"armor_4":
			Gameplay.get("equipped_"+inventory_category)[3] = Gameplay.get("inventory_"+inventory_category)[3][item_id]
		"armor_5":
			Gameplay.get("equipped_"+inventory_category)[4] = Gameplay.get("inventory_"+inventory_category)[4][item_id]
		"shield":
			Gameplay.set("equipped_"+inventory_category,Gameplay.get("inventory_"+inventory_category)[item_id]) #change this because it is not an array????? 
	get(str(button_memory.replace("_",""))).text = Designators.represent("item",selected_item_name)


func openInventory(inventory_category: String) -> void:
	InventoryBackground.visible = true
	selected_inventory = Gameplay.get("inventory_"+inventory_category)
	selected_category = inventory_category


func removeSelected(inventory_category: String,item_name: String) -> void:
	if inventory_category == "usables":
		if item_name != "none":
			if Gameplay.get("inventory_"+inventory_category)[selected_item_id][1] > 1:
				Gameplay.get("inventory_"+inventory_category)[selected_item_id][1] -= 1
			else:
				Gameplay.get("inventory_"+inventory_category).erase([item_name,1])
				if selected_item_id > 0:
					selected_item_id = 0 #removes the usable from the list if only one quantity is available
			displayItems(selected_category,selected_item_id)
			equipSelected(selected_category,selected_item_id)
			Gameplay.spawnItem(Player.position,item_name,false,0)
	else:
		if item_name != "unarmed" and item_name != "none":
			Gameplay.get("inventory_"+inventory_category).erase(item_name)
			if selected_item_id > 0:
				selected_item_id = 0
			displayItems(selected_category,selected_item_id)
			equipSelected(selected_category,selected_item_id)
			Gameplay.spawnItem(Player.position,item_name,false,0)


func _on_weapon_1_button_up() -> void:
	button_memory = "weapon_1"
	selected_item_id = getIdByName(Gameplay.equipped_weapons[0],Gameplay.inventory_weapons)
	openInventory("weapons")
	displayItems("weapons",selected_item_id)
	inventory_open = true
	can_close = false


func _on_weapon_2_button_up() -> void:
	button_memory = "weapon_2"
	selected_item_id = getIdByName(Gameplay.equipped_weapons[1],Gameplay.inventory_weapons)
	openInventory("weapons")
	displayItems("weapons",selected_item_id)
	inventory_open = true
	can_close = false


func _on_weapon_3_button_up() -> void:
	button_memory = "weapon_3"
	selected_item_id = getIdByName(Gameplay.equipped_weapons[2],Gameplay.inventory_weapons)
	openInventory("weapons")
	displayItems("weapons",selected_item_id)
	inventory_open = true
	can_close = false


func _on_usable_1_button_up() -> void:
	button_memory = "usable_1"
	selected_item_id = getIdByName(Gameplay.equipped_usables[0],Gameplay.inventory_usables)
	openInventory("usables")
	displayItems("usables",selected_item_id)
	inventory_open = true
	can_close = false


func _on_usable_2_button_up() -> void:
	button_memory = "usable_2"
	selected_item_id = getIdByName(Gameplay.equipped_usables[1],Gameplay.inventory_usables)
	openInventory("usables")
	displayItems("usables",selected_item_id)
	inventory_open = true
	can_close = false


func _on_usable_3_button_up() -> void:
	button_memory = "usable_3"
	selected_item_id = getIdByName(Gameplay.equipped_usables[2],Gameplay.inventory_usables)
	openInventory("usables")
	displayItems("usables",selected_item_id)
	inventory_open = true
	can_close = false


func _on_armor_1_button_up() -> void:
	button_memory = "armor_1"
	selected_item_id = getIdByName(Gameplay.equipped_armor[0],Gameplay.inventory_armor[0])
	openInventory("armor_1")
	displayItems("armor_1",selected_item_id)
	inventory_open = true
	can_close = false


func _on_armor_2_button_up() -> void:
	button_memory = "armor_2"
	selected_item_id = getIdByName(Gameplay.equipped_armor[1],Gameplay.inventory_armor[1])
	openInventory("armor_1")
	displayItems("armor_1",selected_item_id)
	inventory_open = true
	can_close = false


func _on_armor_3_button_up() -> void:
	button_memory = "armor_3"
	selected_item_id = getIdByName(Gameplay.equipped_armor[2],Gameplay.inventory_armor[2])
	openInventory("armor_3")
	displayItems("armor_3",selected_item_id)
	inventory_open = true
	can_close = false


func _on_armor_4_button_up() -> void:
	button_memory = "armor_4"
	selected_item_id = getIdByName(Gameplay.equipped_armor[3],Gameplay.inventory_armor[3])
	openInventory("armor_4")
	displayItems("armor_4",selected_item_id)
	inventory_open = true
	can_close = false


func _on_armor_5_button_up() -> void:
	button_memory = "armor_5"
	selected_item_id = getIdByName(Gameplay.equipped_armor[4],Gameplay.inventory_armor[4])
	openInventory("armor_5")
	displayItems("armor_5",selected_item_id)
	inventory_open = true
	can_close = false


func _on_shield_button_up() -> void:
	button_memory = "shield"
	selected_item_id = getIdByName(Gameplay.equipped_shield,Gameplay.inventory_shields)
	openInventory("shields") ## kind of bad, the inventory_category in Gameplay is not the same name as the button in this script
	displayItems("shields",selected_item_id)
	inventory_open = true
	can_close = false


func _on_close_refusal_timeout() -> void:
	can_close = true


func _on_drop_button_button_up() -> void:
	removeSelected(selected_category,selected_item_name)


func _on_system_menu_button_button_up() -> void:
	GameMenu.visible = false
	SystemMenu.visible = true


func _on_game_menu_button_button_up() -> void:
	GameMenu.visible = true
	SystemMenu.visible = false


func _on_return_to_menu_button_up() -> void:
	Main.returnToMainMenu("")

func _on_save_game_button_button_up() -> void:
	SaveGameScreenHandler.visible = true
	SaveGameScreenHandler.add_child(load("res://Scenes/SaveGameScreen/save_game_screen.tscn").instantiate())


func _on_settings_button_button_up() -> void:
	SettingsMenuHandler.add_child(load("res://Scenes/UI/settings_menu.tscn").instantiate())
	SettingsMenuHandler.visible = true


func _on_continue_button_up() -> void:
	Gameplay.closePauseMenu()
	
