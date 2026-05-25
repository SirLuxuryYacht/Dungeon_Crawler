extends Node

@onready var Main = get_tree().root.get_node("Main")
@onready var Gameplay = Main.get_node("Gameplay")

@export var map_brightness: float = 0.0


### test
func _on_quest_updater_test_body_entered(_body: Node3D) -> void:
	if QuestStages.getStage("test",Gameplay.quest_stages,false) < 2:
		QuestStages.setStage("test",Gameplay.quest_stages,2,false)
