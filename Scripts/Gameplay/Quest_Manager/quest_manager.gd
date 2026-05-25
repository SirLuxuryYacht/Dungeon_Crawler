extends Node

@onready var Gameplay = get_parent()
@onready var VirtualSpace = Gameplay.get_node("VirtualSpace")
@onready var DroppedItems = VirtualSpace.get_node("DroppedItems")
@onready var SpawnedEnemies = VirtualSpace.get_node("SpawnedEnemies")

var quest_stage_1 = 0

var quest_names = ["test"]

var quest_stages = [quest_stage_1]
#need easy way to identify the quests other than by their id
