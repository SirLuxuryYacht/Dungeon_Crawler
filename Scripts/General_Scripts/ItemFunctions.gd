extends Node

func _ready() -> void:
	Signals.use_item.connect(on_use_item)


func on_use_item(item,User) -> void:
	match item:
		"health_potion":
			heal(User,200)
		"stamina_potion":
			rejuvenate(User,1000)
		"lantern":
			toggleTorch(User)
	if "_key" in item:
		attemptDoorOpen(User)


func heal(Who: Node3D,amount: float) -> void:
	if (Who.health_max - Who.health) > amount: 
		Who.health += amount
	else:
		Who.health = Who.health_max
	Who.playItemSound("potion_gulp")


func rejuvenate(Who: Node3D, amount: float) -> void:
	if (Who.stamina_max - Who.stamina) > amount: 
		Who.stamina += amount
	else:
		Who.stamina = Who.stamina_max
	Who.playItemSound("potion_gulp")


func attemptDoorOpen(Who: Node3D) -> void:
	var key = Who.usable_in_hand #this requires the Who to be the player, maybe other characters can also open doors? Then they need to have an equipped usable
	var KeyHandler = get_tree().root.get_node("Main/Gameplay/VirtualSpace/KeyHandler")
	var key_instance = load("res://Scenes/Items/Keys/stone.tscn").instantiate()
	key_instance.position = Who.position
	key_instance.key_name = key
	KeyHandler.add_child(key_instance)


func toggleTorch(Who: Node3D) -> void:
	if "Torch" in Who:
		var Torch = Who.getTorch()
		if Torch.visible == false:
			Torch.visible = true
			Who.playItemSound("lantern_ignition")
		else:
			Torch.visible = false
			Who.playItemSound("lantern_extinguish")
