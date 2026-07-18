extends Node3D

@onready var Gameplay = get_tree().root.get_node("Main/Gameplay")

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and false:
		if QuestStages.getStage("remnant_generator",Gameplay.quest_stages,false) == 1:
			activate()
			QuestStages.setStage("remnant_generator",Gameplay.quest_stages,2,false)
		else:
			QuestStages.setStage("remnant_generator",Gameplay.quest_stages,1,false)
			

func activate() -> void:
	$AnimationPlayer.play("Animation")
	$GeneratorSound.play()
