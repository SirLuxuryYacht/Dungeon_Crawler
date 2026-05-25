extends Node

var node_name = "Gameplay"

@onready var Main = get_tree().root.get_node("Main")
@onready var VirtualSpace = $VirtualSpace
@onready var Maps = VirtualSpace.get_node("Maps")
@onready var Containers = $VirtualSpace/Containers
@onready var PlayerNode = VirtualSpace.get_node("PlayerNode")
@onready var Misc = VirtualSpace.get_node("Misc")
@onready var DialogueHandler = $DialogueHandler
@onready var Dialogue = $DialogueHandler/Dialogue
@onready var DialogueTimer = $DialogueHandler/DialogueTimer
@onready var DialogueInitial = $DialogueHandler/DialogueInitial
@onready var PauseMenuHandler = $PauseMenuHandler
@onready var EquippedWeapon = $EquippedWeapon
@onready var EquippedUsable = $EquippedUsable
@onready var SettingsMenuHandler = $SettingsMenuHandler
@onready var GameOverScreenHandler = $GameOverScreenHandler
@onready var TradeHandler = $TradeHandler
@onready var QuestManager = $QuestManager
@onready var Soundtrack = $Soundtrack

@onready var StaticItems = $VirtualSpace/StaticItems
@onready var DroppedItems = $VirtualSpace/DroppedItems
@onready var SpawnedEnemies = $VirtualSpace/SpawnedEnemies

@onready var Player = null

var game_paused = false

var can_pause = true

############################################ static reference lists --> needs to be updated when an item is added!
var usables_list = ["health_potion","stamina_potion","stone_key","torch"]

var usables_quantities = [0,0,0]

#############################################

################### settings variables
@onready var camera_sensitivity = Main.camera_sensitivity
###################


############################################# saveables
var loaded_map = "test"

## pickup status
var pickup_status_test: Array = []#ItemReference.pickup_status_test

var pickup_status_castle_dungeon: Array = []

var pickup_status_village: Array = []#ItemReference.pickup_status_village

var pickup_status_forest: Array = []

var pickup_status_institute: Array = [] 

var pickup_status_mountains: Array = []

var pickup_status_tramway: Array = []

var pickup_status_snowpeak: Array = []

var pickup_status_cave: Array = []

var pickup_status_mountain_castle: Array = []

## container status
var container_status_test: Array = []

var container_status_castle_dungeon: Array = []

var container_status_village: Array = []

var container_status_forest: Array = []

var container_status_institute: Array = []

var container_status_mountains: Array = []

var container_status_tramway: Array = []

var container_status_snowpeak: Array = []

var container_status_cave: Array = []

var container_status_mountain_castle: Array = []

## door status
var door_status_test: Array = []

var door_status_castle_dungeon: Array = []

var door_status_village: Array = []

var door_status_forest: Array = []

var door_status_institute: Array = []

var door_status_mountains: Array = []

var door_status_tramway: Array = []

var door_status_snowpeak: Array = []

var door_status_cave: Array = []

var door_status_mountain_castle: Array = []

## enemy permanency (respawn) status
var permanency_status_test: Array = [] #EnemyReference.permanency_status_test

var permanency_status_castle_dungeon: Array = []

var permanency_status_village: Array = [] #EnemyReference.permanency_status_village

var permanency_status_forest: Array = []

var permanency_status_institute: Array = []

var permanency_status_mountains: Array = []

var permanency_status_tramway: Array = []

var permanency_status_snowpeak: Array = []

var permanency_status_cave: Array = []

var permanency_status_mountain_castle: Array = []

## trader inventory status

var trade_inventories: Dictionary


var last_save_location = Vector3(-5,-3,6)#Vector3(-5,-3,6) spawn location in actual first map

var last_save_rotation = Vector3(0,0,0)

var inventory_weapons: Array = ["unarmed"] #array for storing the weapons in the inventory

var inventory_usables: Array = [["none",1]] #array for storing the usables in the inventory

var inventory_armor_1: Array = ["none"]

var inventory_armor_2: Array = ["none"]

var inventory_armor_3: Array = ["none"]

var inventory_armor_4: Array = ["none"]

var inventory_armor_5: Array = ["none"]

var inventory_armor: Array = [inventory_armor_1,inventory_armor_2,inventory_armor_3,inventory_armor_4,inventory_armor_5]

var inventory_shields: Array = ["none"]

var equipped_weapons = ["unarmed","unarmed","unarmed"]

var equipped_weapon = "unarmed"

var weapon_selector = 0

var equipped_usables = ["none","none","none"]

var equipped_usable = "none"

var usable_selector = 0

var equipped_armor = ["none","none","none","none","none"]

var equipped_shield = "none"

var coin_count = 3000 #the amount of coins in the inventory

var dropped_coin_counts = [] #writing the amounts of the coins that were dropped

var dropped_items: Array[String] = []
var dropped_item_positions: Array[Vector3] = [] #writing all temporary items and their positions

var static_items: Array[String] = []
var static_item_positions: Array[Vector3] = [] #writing all preexisting items and their positions

var spawned_enemies: Array[String] = []
var spawned_enemies_positions: Array[Vector3] = [] #writing all temporary enemies and their positions
var spawned_enemies_rotations: Array[Vector3] = [] #writing all temporary enemies and their rotations

var player_health = 429

var quest_stages: Array = []

var player_level: int = 1

var player_physical_level: int = 1

var player_magic_level: int = 1

var player_xp: int = 0

var player_physical_xp: int = 0

var player_magic_xp: int = 0

var player_resistance = [1,1,1,1]
#############################################

var enough_stamina = true

var minimum_stamina = 80 #minimum amount of stamina required after draining all of it

var stamina_draining = false

var stamina_drain_timer = 0

var stamina_drain_offset = 0.5

var stamina_recovery_speed = 0.5

var stamina_weight_factor = 1

var stamina_strength_factor = 1


##################################### world interaction variables
var surface_breached = false
#####################################

var dialogue_stage = 0 ##dialogue interaction variable

var dialogue_array = []

var can_advance_dialogue = false

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("pause"):
		if PauseMenuHandler.get_child_count() == 0 and !game_paused:
			openPauseMenu()
	if Input.is_action_just_pressed("enlarge"):
		spawnEnemy(Player.position,Player.getCameraRotation(),"strange_fish",1) #test function
	if Input.is_action_just_pressed("reduce"):
		spawnEnemy(Player.position+Vector3.UP,Vector3.ZERO,"bat_test",1)
	if DialogueHandler.visible:
		if Input.is_action_just_pressed("use") and can_advance_dialogue:
			advanceDialogue()


func increaseHealth(initial_health,amount) -> float:
	var health = initial_health
	var max_health = Player.health_max
	if (max_health - health) > amount:
		health += amount
	else:
		health = max_health
	return health


func drainHealth(initial_health,amount) -> float:
	var health = initial_health
	if health > 0:
		if health >= amount:
			health -= amount
		else:
			health = 0
	return health


func getCurrentMap() -> Node3D:
	return VirtualSpace.get_node("Maps").get_child(0)


func addMisc(What: Node3D,where: Vector3,rotation: Vector3) -> void:
	What.rotation = rotation
	What.position = where
	Misc.add_child(What)


func getPlayer() -> Node:
	return Player


func damageEnemyHealth(initial_health,amount) -> float:
	var health = initial_health
	if health > 0:
		if health >= amount:
			health -= amount
		else:
			health = 0
	return health


func doDamage(Dealer,Receiver) -> float:
	var damage = 0
	for i in Receiver.resistance.size():
		if "damage" in Dealer:
			if Receiver.resistance[i] == -1:
				damage += 0
			else:
				damage += 1.0 / Receiver.resistance[i] * Dealer.damage[i]
	return damage


func increaseStamina(Who,delta,recovery_ability) -> void:
	if !stamina_draining:
		var stamina = Player.getStamina()
		var stamina_max = Player.stamina_max
		if !game_paused:
			if stamina < stamina_max:
				stamina += stamina_recovery_speed * exp(Who.weight_factor * Who.weight - Who.strength_factor * Who.strength * recovery_ability) * delta * stamina + 0.05 #failsafe for zero stamina
				if stamina > minimum_stamina:
					enough_stamina = true
			else:
				stamina = stamina_max
				enough_stamina = true
			Who.setStamina(stamina)


func staminaDrainPause(delta) -> void:
	if stamina_draining:
		stamina_drain_timer -= delta
	if stamina_drain_timer <= 0:
		stamina_draining = false
		stamina_drain_timer = 0


func drainStamina(Who,amount) -> void:
	var stamina = Who.getStamina()
	if stamina > 0:
		if stamina >= amount:
			stamina -= amount * exp(Who.weight_factor * Who.weight - Who.strength_factor * Who.strength)
			stamina_draining = true
			stamina_drain_timer = stamina_drain_offset
		else:
			stamina = 0
			enough_stamina = false
	Who.setStamina(stamina)


func staminaDrainFactor(strength_fac,strength,weight_fac,weight) -> float:
	var factor = exp(weight_fac * weight - strength_fac * strength)
	return factor 


func spawnPlayer(location,rotation,health) -> void:
	PlayerNode.add_child(load("res://Scenes/test_player/player.tscn").instantiate())
	Player = PlayerNode.get_node("Player")
	Player.position = location
	Player.setCameraRotation(rotation)
	Player.health = health


func playerPositionGetter() -> Vector3:
	return Player.position


func openPauseMenu() -> void:
	if can_pause:
		Input.warp_mouse(Vector2(get_viewport().size.x / 2,get_viewport().size.y / 2))
		game_paused = true
		get_tree().paused = true
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		PauseMenuHandler.add_child(load("res://Scenes/Gameplay_Scenes/PauseMenu/pause_menu.tscn").instantiate())
		#PauseMenuHandler.add_child(load("res://Scenes/test/test_button.tscn").instantiate())
		Player.getHud().visible = false
		sortInventoryItems()


func closePauseMenu() -> void:
	Input.warp_mouse(Vector2(get_viewport().size.x / 2,get_viewport().size.y / 2))
	game_paused = false
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	PauseMenuHandler.get_node("PauseMenu").queue_free()
	Player.chooseWeapon("at_game_resume")
	Player.getHud().visible = true


func openTradeMenu(target_name: String,trader_node: Node3D) -> void:
	Input.warp_mouse(Vector2(get_viewport().size.x / 2,get_viewport().size.y / 2))
	can_pause = false
	get_tree().paused = true
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	TradeHandler.visible = true
	var trade_menu = load("res://Scenes/TradeMenu/trade_menu.tscn").instantiate()
	trade_menu.trade_inventory = trade_inventories[target_name]
	trade_menu.character_name = target_name
	trade_menu.trader = trader_node
	trade_menu.trader_cheapness = trader_node.trader_cheapness
	TradeHandler.add_child(trade_menu)


func closeTradeMenu(target_name) -> void:
	Input.warp_mouse(Vector2(get_viewport().size.x / 2,get_viewport().size.y / 2))
	get_tree().paused = false
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	TradeHandler.visible = false
	trade_inventories[target_name] = TradeHandler.get_child(1).trade_inventory
	TradeHandler.get_child(1).queue_free()
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	updateItemEquips()
	TradeHandler.get_node("TradeDelay").start(0.075)


func _on_trade_delay_timeout() -> void:
	can_pause = true


func storeItemDrops() -> void:
	dropped_coin_counts = []
	dropped_item_positions = []
	dropped_items = []
	for i in DroppedItems.get_child_count():
		var Item = DroppedItems.get_child(i)
		if Item.item_name == "coin":
			dropped_coin_counts.append(Item.amount) #writes the coin counts if the item is a coin
		dropped_item_positions.append(Item.position)
		dropped_items.append(Item.item_name)


func storeSpawnedEnemies() -> void:
	spawned_enemies = []
	spawned_enemies_positions = []
	spawned_enemies_rotations = []
	for i in SpawnedEnemies.get_child_count():
		var Enemy = SpawnedEnemies.get_child(i)
		spawned_enemies_positions.append(Enemy.position)
		spawned_enemies_rotations.append(Enemy.rotation)
		spawned_enemies.append(Enemy.enemy_name)


func getInventoryItemId(Inventory: ItemList,item: String) -> int:
	var i = 0
	if Inventory.get_item_count() > 0:
		while Inventory.get_item_text(i) != item:
			if i <= Inventory.get_item_count():
				i += 1
			else:
				break
	return i


func isPersistent(item: String) -> bool:
	var is_persistent = false
	if item in ItemReference.persistence_list: #append all the cases of the different keys
		is_persistent = true
	return is_persistent


func useItem(item: String,User: Node3D) -> void:
	if item != "none":
		if User.name == "Player":
			var item_id = getUsableId(item,inventory_usables)
			if !isPersistent(item): #keys dont get removed from the inventory upon use, other items, like lantern, as well
				if inventory_usables[item_id][1] > 1:
					inventory_usables[item_id][1] -= 1
				else:
					inventory_usables.remove_at(item_id)
					equipped_usables[getUsableId(equipped_usable,equipped_usables)] = "none"
					equipped_usable = "none"
			Player.usable_in_hand = equipped_usable
		Signals.use_item.emit(item,User)


func hasItem(List: ItemList,item_name: String) -> bool:
	var found = false
	if List.get_item_count() > 0:
		for index in List.get_item_count():
			if List.get_item_text(index) == item_name:
				found = true
	return found


func getPlayerPosition() -> Vector3:
	return Player.position


func getUsableId(usable_name: String, from_where: Array) -> int:
	var id = 0
	if from_where.size() > 0:
		for i in from_where.size():
			if from_where[0] is Array:
				if from_where[i][0] == usable_name:
					id = i
			else:
				if from_where[i] == usable_name:
					id = i
	return id


func getUsableAmount(usable_name: String) -> int:
	return inventory_usables[getUsableId(usable_name,inventory_usables)][1]


func takeDamage(Damager,Damaged) -> void:
	var damage
	var damage_multiplier = [1,1,1,1]
	var DamagerParent = Damager.get_parent()
	if DamagerParent.attack_type == "light":
		damage = DamagerParent.light_damage
	if DamagerParent.attack_type == "heavy":
		damage = DamagerParent.heavy_damage
	if DamagerParent.attack_type == "environmental":
		damage = DamagerParent.environmental_damage
	if "player_weapon" in DamagerParent: #checks if the weapon belongs to the player, else it only uses the default damage multiplier (1) when enemies should hit each other
			damage_multiplier = [player_physical_level,player_magic_level,player_magic_level,player_magic_level]
	for i in damage.size():
		if Damaged.resistance[i] != -1:
			Damaged.health -= (0.9 + 0.1 * damage_multiplier[i]) * damage[i] / Damaged.resistance[i] #use 0.1 as magic number, responsible for a more balanced increas of damage


func _on_dialogue_timer_timeout() -> void:
	advanceDialogue()


func _on_dialogue_initial_timeout() -> void:
	can_advance_dialogue = true


func openDialogue(ConversationPartner,can_interrupt: bool) -> void:
	if can_interrupt:
		SpawnedEnemies.process_mode = Node.PROCESS_MODE_DISABLED
	var dialogue = ConversationPartner.character_name+"_"+str(QuestStages.getStage(ConversationPartner.character_name,quest_stages,false))+"_"+str(QuestStages.getStage(ConversationPartner.character_name,quest_stages,true)) #the number should be replaced by the quest stage of the npc
	QuestStages.setStage(ConversationPartner.character_name,quest_stages,2,true) #doesnt set the quest stage, but the dialogue stage from 1 to 2
	dialogue_stage = 1
	dialogue_array = Dialogues.composeDialogue(dialogue)
	DialogueHandler.visible = true
	Dialogue.text = dialogue_array[0]
	DialogueTimer.start()
	DialogueInitial.start()
	Player.get_node("GameplayPromptHandler").visible = false


func closeDialogue() -> void:
	can_advance_dialogue = false
	DialogueHandler.visible = false
	dialogue_stage = 1
	dialogue_array = []
	DialogueTimer.stop()
	Player.get_node("GameplayPromptHandler/DialoguePause").start()
	SpawnedEnemies.process_mode = Node.PROCESS_MODE_INHERIT


func advanceDialogue() -> void:
	if dialogue_stage < dialogue_array.size():
		dialogue_stage += 1
		DialogueTimer.start()
		Dialogue.text = dialogue_array[dialogue_stage-1]
	else:
		closeDialogue()


func soundtrackFinder(map) -> String:
	var index = 0
	while MapList.map_list[index] != map:
		index += 1
	return MapList.map_soundtracks[index]


func refillArray(onto,from: ItemList) -> void:
	onto.clear()
	var items = []
	for i in from.get_item_count():
		items.append(from.get_item_text(i))
	for i in items.size():
		onto.append(items[i])


func storeStaticItems(item: String,map: String) -> void: #map: supposed to be the currently loaded map
	var i = 0
	while map != MapList.map_list[i]:
		i += 1
	map = MapList.map_list[i] #redundant if map is already given
	i = 0
	while item != ItemReference.get_const("items_"+map)[i]:
		i += 1
	setMapVariable(loaded_map,"pickup_status",true,i)


func setMapVariable(map: String, variable: String, value, array_position: int) -> void:
	if map == "test":
		match variable:
			"pickup_status":
				pickup_status_test[array_position] = value
			"container_status":
				container_status_test[array_position] = value
			"door_status":
				door_status_test[array_position] = value
	
	if map == "village":
		match variable:
			"pickup_status":
				pickup_status_village[array_position] = value
			"container_status":
				container_status_village[array_position] = value
			"door_status":
				door_status_village[array_position] = value
				
	if map == "castle_dungeon":
		match variable:
			"pickup_status":
				pickup_status_castle_dungeon[array_position] = value
			"container_status":
				container_status_castle_dungeon[array_position] = value
			"door_status":
				door_status_castle_dungeon[array_position] = value
	if map == "forest":
		match variable:
			"pickup_status":
				pickup_status_forest[array_position] = value
			"container_status":
				container_status_forest[array_position] = value
			"door_status":
				door_status_forest[array_position] = value
	if map == "institute":
		match variable:
			"pickup_status":
				pickup_status_institute[array_position] = value
			"container_status":
				container_status_institute[array_position] = value
			"door_status":
				door_status_institute[array_position] = value
	if map == "mountains":
		match variable:
			"pickup_status":
				pickup_status_mountains[array_position] = value
			"container_status":
				container_status_mountains[array_position] = value
			"door_status":
				door_status_mountains[array_position] = value


func getMapVariable(map: String, variable: String, array_position: int):
	if map == "test":
		match variable:
			"pickup_status":
				return pickup_status_test[array_position]
			"container_status":
				return container_status_test[array_position]
			"door_status":
				return door_status_test[array_position]
	
	if map == "village":
		match variable:
			"pickup_status":
				return pickup_status_village[array_position]
			"container_status":
				return container_status_village[array_position]
			"door_status":
				return door_status_village[array_position]
	
	if map == "castle_dungeon":
		match variable:
			"pickup_status":
				return pickup_status_castle_dungeon[array_position]
			"container_status":
				return container_status_castle_dungeon[array_position]
			"door_status":
				return door_status_castle_dungeon[array_position]

	if map == "forest":
		match variable:
			"pickup_status":
				return pickup_status_forest[array_position]
			"container_status":
				return container_status_forest[array_position]
			"door_status":
				return door_status_forest[array_position]
	
	if map == "institute":
		match variable:
			"pickup_status":
				return pickup_status_institute[array_position]
			"container_status":
				return container_status_institute[array_position]
			"door_status":
				return door_status_institute[array_position]
	
	if map == "mountains":
		match variable:
			"pickup_status":
				return pickup_status_mountains[array_position]
			"container_status":
				return container_status_mountains[array_position]
			"door_status":
				return door_status_mountains[array_position]


func isContainerOpened(container: Node3D) -> bool:
	var container_position = container.position
	var container_position_list = ItemReference.get_const("container_positions_"+str(loaded_map))
	var i = 0
	if container_position_list.size() == 0: #catch the case where there is no container on the map, seems unnecessary
		pass
	while container_position != container_position_list[i]:
		i += 1
	return getMapVariable(loaded_map,"container_status",i)


func storeContainerOpening(container: Node3D) -> void: #the position of the container is unique, it can be used to differentiate between the containers, even if they have the same name
	var container_position = container.position
	var container_position_list = ItemReference.get_const("container_positions_"+str(loaded_map)) #either loaded_map here or in the function argument
	var i = 0
	if container_position_list.size() == 0: #catch the case where there is no container on the map, seems unnecessary
		pass
	while container_position != container_position_list[i]:
		i += 1
	get("container_status_"+str(loaded_map))[i] = true


##### the same for doors instead of containers
func isDoorOpened(door: Node3D) -> bool:
	var door_position = door.position
	var door_position_list = DoorReference.get_const("door_positions_"+str(loaded_map))
	var i = 0
	if door_position_list.size() != 0: #catch the case where there is no container on the map, seems unnecessary
		while door_position != door_position_list[i]:
			i += 1
		#var returner = get("door_status_"+str(loaded_map))
		return getMapVariable(loaded_map,"door_status",i)
	else:
		return true


func storeDoorOpening(door: Node3D) -> void: #the position of the container is unique, it can be used to differentiate between the containers, even if they have the same name
	var door_position = door.position
	var door_position_list = DoorReference.get_const("door_positions_"+str(loaded_map)) #either loaded_map here or in the function argument
	var i = 0
	if door_position_list.size() == 0: #catch the case where there is no container on the map, seems unnecessary
		pass
	while door_position != door_position_list[i]:
		i += 1
	get("door_status_"+str(loaded_map))[i] = true


func saveGame(selected_file) -> void:
	storeItemDrops()
	storeSpawnedEnemies()
	var file
	var main_info_file
	
	var desktop_path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
	
	if !DirAccess.dir_exists_absolute(desktop_path.path_join("save_test")):
		DirAccess.make_dir_recursive_absolute(desktop_path.path_join("save_test"))
	
	var save_file_path = desktop_path.path_join("save_test/save_game_"+str(selected_file)+".dat")
	var main_info_file_path = desktop_path.path_join("save_test/main_info_file.dat")
	
	file = FileAccess.open(save_file_path, FileAccess.WRITE)
	main_info_file = FileAccess.open(main_info_file_path, FileAccess.WRITE)
	
	last_save_location = Player.position #save player location
	last_save_rotation = Player.getCameraRotation() #save player rotation
	
	weapon_selector = Player.weapon_selector
	
	main_info_file.store_var(selected_file) #stores the currently loaded save file for easy continuing upon later game start
	
	file.store_var(player_level) #stores the player level into the savefile
	file.store_var(player_xp) #stores the player total experience into the savefile. Level can be seen upon load
	file.store_var(player_physical_level) #stores the player physical level into the savefile
	file.store_var(player_magic_level) #stores the player magic level into the savefile
	
	file.store_var(loaded_map)
	
	file.store_var(player_physical_xp)
	file.store_var(player_magic_xp)
	
	
	for map in MapList.map_list:
		file.store_var(get("pickup_status_"+map))
		file.store_var(get("container_status_"+map))
		file.store_var(get("door_status_"+map))
		file.store_var(get("permanency_status_"+map))
	
	file.store_var(trade_inventories)
	
	file.store_var(last_save_location) #store player location
	file.store_var(last_save_rotation) #store player rotation
	
	file.store_var(equipped_weapon) #store player's currently equipped weapon (in hand)
	file.store_var(weapon_selector)
	file.store_var(equipped_usable) #store player's currently equipped usable
	file.store_var(usable_selector) #store player's currently equipped usable reference
	file.store_var(equipped_weapons) #store player's equipped weapons
	file.store_var(equipped_usables) #store player's equipped usables
	file.store_var(equipped_armor) #store player's equipped armor
	file.store_var(equipped_shield) #store player's equipped shield
	
	file.store_var(inventory_weapons) #store player#s inventory weapons
	file.store_var(inventory_usables)#store player#s inventory usables
	file.store_var(inventory_armor) #store player#s inventory armor
	file.store_var(inventory_shields) #store player#s inventory shields
	
	file.store_var(coin_count) #store player's coin count
	file.store_var(usables_quantities) #store player's usables and their amounts
	file.store_var(dropped_coin_counts) #store the amount of coins lying on the floor
	file.store_var(dropped_items) #store the items laying on the ground
	file.store_var(dropped_item_positions) #store the positions of the items laying on the ground
	file.store_var(spawned_enemies) #store the enemies spawned on the map
	file.store_var(spawned_enemies_positions) #store their positions
	file.store_var(spawned_enemies_rotations) #store their rotations
	file.store_var(Player.health) #store player health
	
	file.store_var(quest_stages) #store the quest stages
	
	file.store_var(player_resistance) #stores the player's resistances
	#check order!!


func loadGame(selected_file) -> void:
	if selected_file == 1 or selected_file == 2 or selected_file == 3:
	
		var desktop_path = OS.get_system_dir(OS.SYSTEM_DIR_DESKTOP)
		
		if !DirAccess.dir_exists_absolute(desktop_path.path_join("save_test")):
			DirAccess.make_dir_recursive_absolute(desktop_path.path_join("save_test"))
		
		var save_file_path = desktop_path.path_join("save_test/save_game_"+str(selected_file)+".dat")
		
		if FileAccess.file_exists(save_file_path):
			var file = FileAccess.open(save_file_path, FileAccess.READ)
			
			player_level = file.get_var()
			player_xp = file.get_var()
			player_physical_level = file.get_var()
			player_magic_level = file.get_var()
			
			loaded_map = file.get_var() #this strange order is to help the savefile menu display
			
			player_physical_xp = file.get_var()
			player_magic_xp = file.get_var()
			
			for map in MapList.map_list:
				set("pickup_status_"+map,file.get_var())
				set("container_status_"+map,file.get_var())
				set("door_status_"+map,file.get_var())
				set("permanency_status_"+map,file.get_var())
				
			trade_inventories = file.get_var()
			
			last_save_location = file.get_var()
			last_save_rotation = file.get_var()
			
			equipped_weapon = file.get_var()
			weapon_selector = file.get_var()
			equipped_usable = file.get_var()
			usable_selector = file.get_var()
			equipped_weapons = file.get_var()
			equipped_usables = file.get_var()
			equipped_armor = file.get_var()
			equipped_shield = file.get_var()
			
			inventory_weapons = file.get_var()
			inventory_usables = file.get_var()
			inventory_armor = file.get_var()
			inventory_shields = file.get_var()
			
			coin_count = file.get_var()
			usables_quantities = file.get_var()
			dropped_coin_counts = file.get_var()
			dropped_items = file.get_var() #get the names of the nodes that existed as items in the world
			dropped_item_positions = file.get_var()
			spawned_enemies = file.get_var()
			spawned_enemies_positions = file.get_var()
			spawned_enemies_rotations = file.get_var()
			player_health = file.get_var()
			
			quest_stages = file.get_var()
			
			player_resistance = file.get_var()
		#check order!!
		else:
			for map in MapList.map_list:
				set("pickup_status_"+map,ItemReference.get_const("pickup_status_"+map).duplicate_deep())
				set("container_status_"+map,ItemReference.get_const("container_status_"+map).duplicate_deep())
				set("door_status_"+map,DoorReference.get_const("door_status_"+map).duplicate_deep())
				set("permanency_status_"+map,EnemyReference.get_const("permanency_status_"+map).duplicate_deep())
			
			trade_inventories = TraderInventories.trade_inventories.duplicate_deep()
			
			quest_stages = QuestStages.get_const("quest_stages").duplicate_deep()
		
		spawnPlayer(last_save_location,last_save_rotation,player_health)
		createWorld(loaded_map)
		sweepContainers()
		spawnContainers(loaded_map)
		itemSweeper()
		droppedItemSpawner(dropped_items,dropped_item_positions,dropped_coin_counts)
		fillMapWithItems(loaded_map)
		enemySweeper()
		fillMapWithEnemies(loaded_map)
		MapList.updateTransitionVisibility(loaded_map,self)
		#enemySpawner(spawned_enemies,spawned_enemies_positions,spawned_enemies_rotations)
	else:
		pass #do nothing if the selected file does not exist


func itemSweeper() -> void:
	for i in DroppedItems.get_child_count(): #make sure no children exist in DroppedItems
		DroppedItems.get_child(i).queue_free()
	for i in StaticItems.get_child_count():
		StaticItems.get_child(i).queue_free()

func droppedItemSpawner(items,item_positions,coin_amounts) -> void:
	var k = 0
	for i in items.size(): #adds all items whose names and positions were saved when saving the game
		var spawn = load("res://Scenes/Items/"+items[i]+".tscn").instantiate()
		spawn.position = item_positions[i] #replaces the first uppercase letter of the node name and removes this letter from the rest of the name, then puts them together to form the scene path
		if spawn.item_name == "coin":
			spawn.amount = coin_amounts[k]
			k += 1
		DroppedItems.add_child(spawn)


func enemySweeper() -> void:
	for i in SpawnedEnemies.get_child_count():
		SpawnedEnemies.get_child(i).queue_free()


func enemySpawner(enemies,enemy_positions,enemy_rotations) -> void:
	for i in enemies.size(): #adds all enemies whose names and positions were saved when saving the game
		var spawn = load("res://Scenes/Enemies/"+enemies[i]+".tscn").instantiate()
		spawn.position = enemy_positions[i]
		spawn.rotation = enemy_rotations[i] #replaces the first uppercase letter of the node name and removes this letter from the rest of the name, then puts them together to form the scene path
		SpawnedEnemies.add_child(spawn) #+lcc(dropped_items[i].left(0))+dropped_items[i].lstrip(dropped_items[i].left(0))+


func spawnCoin(spawn_position,amount): #test function for save feature
	var coin = load("res://Scenes/Items/coin.tscn").instantiate()
	coin.position = spawn_position
	coin.amount = amount
	DroppedItems.add_child(coin)


func spawnEnemy(spawn_position,spawn_rotation,enemy_name,id):
	var enemy = load("res://Scenes/Enemies/"+enemy_name+".tscn").instantiate()
	enemy.position = spawn_position
	enemy.rotation = spawn_rotation
	enemy.id = id
	SpawnedEnemies.add_child(enemy)


func createWorld(loaded_map_) -> void:
	var i = 0
	while loaded_map != MapList.map_list[i]: #the map has a unique name, it is the same as the node name, all lower case
		i += 1
	Maps.add_child(load("res://Scenes/Maps/"+str(loaded_map)+".tscn").instantiate())
	Maps.get_node(loaded_map_).position = MapList.map_positions[i]
	Maps.get_node(loaded_map_).rotation = MapList.map_rotations[i]


func spawnItem(spawn_position,item_name,is_static_item,coin_amount: int) -> void:
	if item_name == "nothing":
		pass
	else:
		var _Item = load("res://Scenes/Items/"+str(item_name)+".tscn").instantiate()
		_Item.position = spawn_position
		_Item.rotation.y = spawn_position.length() #pseudorandom rotation that is always the same
		if is_static_item:
			_Item.uniqueness = true
			StaticItems.add_child(_Item)
		else:
			var coin_id = 0
			if _Item.item_name == "coin":
				if coin_amount == 0:
					_Item.amount = dropped_coin_counts[coin_id]
				else:
					_Item.amount = coin_amount
				DroppedItems.add_child(_Item)
				coin_id += 1
			else:
				DroppedItems.add_child(_Item)


func sweepContainers() -> void:
	for i in Containers.get_child_count():
		Containers.get_child(i).queue_free()


func spawnContainers(map_name) -> void:
	var container_positions = ItemReference.get_const("container_positions_"+str(map_name))
	var container_content = ItemReference.get_const("container_contents_"+str(map_name))
	var container_type = ItemReference.get_const("containers_"+str(map_name))
	for i in container_positions.size():
		var pseudorandom_variable = 2*PI*sin(sqrt(2) * i)**2
		var new_container
		match container_type[i]:
			"barrel":
				new_container = load("res://Scenes/SmallerBuildingBlocks/Barrels/barrel.tscn").instantiate()
			"wooden_box":
				new_container = load("res://Scenes/SmallerBuildingBlocks/Barrels/wooden_box.tscn").instantiate()
			"stone_chest":
				new_container = load("res://Scenes/SmallerBuildingBlocks/Chests/stone_chest.tscn").instantiate()
			"large_gravestone_intact":
				new_container = load("res://Scenes/SmallerBuildingBlocks/Gravestones/large_gravestone_intact.tscn").instantiate()
			"large_gravestone_broken":
				new_container = load("res://Scenes/SmallerBuildingBlocks/Gravestones/large_gravestone_broken.tscn").instantiate()
		new_container.setContent(container_content[i])
		new_container.position = container_positions[i]
		new_container.rotation.y = pseudorandom_variable
		new_container.id = i
		Containers.add_child(new_container)


func fillMapWithItems(map_name) -> void:
	var items_on_map = ItemReference.get("items_"+str(map_name))
	var items_on_map_positions = ItemReference.get("item_positions_"+str(map_name))
	var actual_items = get("pickup_status_"+str(map_name))
	for i in items_on_map.size():
		if actual_items[i] == false: #checks if the item was already picked up, false if not
			spawnItem(items_on_map_positions[i],items_on_map[i],true,0)


func fillMapWithEnemies(map_name) -> void:
	var enemies_on_map = EnemyReference.get("enemies_"+str(map_name))
	var enemies_on_map_positions = EnemyReference.get("enemy_positions_"+str(map_name))
	var enemies_on_map_ids = EnemyReference.get("enemy_ids_"+str(map_name))
	var actual_enemies = self.get("permanency_status_"+str(map_name))
	for i in enemies_on_map.size():
		if actual_enemies[i] == true: #checks if the enemy can respawn, false if not
			spawnEnemy(enemies_on_map_positions[i],Vector3.ZERO,enemies_on_map[i],enemies_on_map_ids[i])


func coinCalculator(base: int,max_deviation: float) -> int:
	var x = randf_range(-1,1)
	return base + round(max_deviation * (x + 1/PI * sin(PI * x)))


func writeItemPickup(item_name) -> void:
	var item_list = get("items_"+str(loaded_map))
	for i in item_list.size():
		if item_name == item_list[i]:
			set("pickup_status_"+str(loaded_map)[i],true)


func getPureUsableInventory(usables_inventory: Array) -> Array:
	var pure_array = []
	if usables_inventory.size() > 0:
		if usables_inventory[0] is Array:
			for i in usables_inventory.size():
				pure_array.append(usables_inventory[i][0])
	return pure_array


func updateItemEquips() -> void:
	for i in equipped_weapons.size():
		if !(equipped_weapons[i] in inventory_weapons):
			equipped_weapons[i] = "unarmed"
	for i in equipped_usables.size():
		if !(equipped_usables[i] in getPureUsableInventory(inventory_usables)):
			equipped_usables[i] = "none"
	for i in equipped_armor.size():
		for j in equipped_armor[i]:
			if !(equipped_armor[i] in inventory_armor[i]):
				equipped_armor[i] = "none"
	if !(equipped_shield in inventory_shields):
		equipped_shield = "none"
	Player.weaponEquipper(Player.weapon_selector)


func sortInventoryArray(array_to_be_sorted: Array,comparison_array: Array) -> Array:
	var sorted_array = []
	var memory = [] #distinguishes the cases of a one- or two-dimensional array (like the usable array)
	for i in comparison_array.size():
		for j in array_to_be_sorted.size():
			if !(array_to_be_sorted[0] is Array):
				if array_to_be_sorted[j] == comparison_array[i] and j not in memory:
					memory.append(j)
					sorted_array.append(array_to_be_sorted[j])
			else:
				if array_to_be_sorted[j][0] == comparison_array[i] and j not in memory:
					memory.append(j)
					sorted_array.append(array_to_be_sorted[j])
	return sorted_array                                                                                                                                                                                                                                                                                                                                     


func sortInventoryItems() -> void:
	inventory_weapons = sortInventoryArray(inventory_weapons,Designators.order_weapons)
	inventory_usables = sortInventoryArray(inventory_usables,Designators.order_usables)
	inventory_armor_1 = sortInventoryArray(inventory_armor_1,Designators.order_helmet)
	inventory_armor_2 = sortInventoryArray(inventory_armor_2,Designators.order_chestpiece)
	inventory_armor_3 = sortInventoryArray(inventory_armor_3,Designators.order_gloves)
	inventory_armor_4 = sortInventoryArray(inventory_armor_4,Designators.order_greaves)
	inventory_armor_5 = sortInventoryArray(inventory_armor_5,Designators.order_boots)
	inventory_shields = sortInventoryArray(inventory_shields,Designators.order_shields)
	inventory_armor = [inventory_armor_1,inventory_armor_2,inventory_armor_3,inventory_armor_4,inventory_armor_5]


func addItem(item_name: String,item_type: String) -> void:
	match item_type:
		"Weapon":
			inventory_weapons.append(item_name)
		"Helmet":
			inventory_armor[0].append(item_name)
		"Chestpiece":
			inventory_armor[1].append(item_name)
		"Gloves":
			inventory_armor[2].append(item_name)
		"Greaves":
			inventory_armor[3].append(item_name)
		"Boots":
			inventory_armor[4].append(item_name)
		"Shield":
			inventory_shields.append(item_name)
		"Usable":
			if inventory_usables.size() > 0:
				var is_in_inventory = false
				for index in inventory_usables.size():
					if inventory_usables[index][0] == item_name:
						inventory_usables[index][1] += 1
						is_in_inventory = true
				if !is_in_inventory:
					inventory_usables.append([item_name,1])
			else:
				inventory_usables.append([item_name,1])


func removeItem(item_name: String,item_type: String) -> void:
	match item_type:
		"Weapon":
			inventory_weapons.erase(item_name)
		"Helmet":
			inventory_armor[0].erase(item_name)
		"Chestpiece":
			inventory_armor[1].erase(item_name)
		"Gloves":
			inventory_armor[2].erase(item_name)
		"Greaves":
			inventory_armor[3].erase(item_name)
		"Boots":
			inventory_armor[4].erase(item_name)
		"Shield":
			inventory_shields.erase(item_name)
		"Usable":
			if inventory_usables.size() > 0:
				var is_in_inventory = false
				for index in inventory_usables.size():
					if inventory_usables[index][0] == item_name:
						inventory_usables[index][1] -= 1
						is_in_inventory = true
				if !is_in_inventory:
					pass


func getTypeFromCategory(category: String) -> String:
	var type = ""
	match category:
		"usables":
			type = "Usable"
		"weapons":
			type = "Weapon"
		"armor_1":
			type = "Helmet"
		"armor_2":
			type = "Chestpiece"
		"armor_3":
			type = "Gloves"
		"armor_4":
			type = "Greaves"
		"armor_5":
			type = "Boots"
		"shields":
			type = "Shield"
	return type
		

func startGame() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	loadGame(Main.selected_file)
	Soundtrack.stream = load("res://Soundtrack/"+str(soundtrackFinder(loaded_map))+".ogg")
	Soundtrack.play()
	Player.setHealth(player_health)
	EquippedWeapon.text = str(Player.weapon_in_hand)
	EquippedUsable.text = str(Player.usable_in_hand)
	Signals.take_damage.connect(takeDamage)
	Signals.pick_map_item.connect(writeItemPickup)


func _ready() -> void:
	startGame()

func _physics_process(delta: float) -> void:
	pass
