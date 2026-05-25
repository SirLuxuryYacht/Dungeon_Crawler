extends Node3D

var id: int

var item_name = "stone_chest"

@export var content = "test_sword"

@export var coin_amount = 50

@onready var Gameplay = get_tree().root.get_node("Main/Gameplay")


func setContent(desired_content) -> void:
	if desired_content is Array:
		content = desired_content[0]
		coin_amount = desired_content[1]
	else:
		content = desired_content


func _ready() -> void:
	if Gameplay.isContainerOpened(self):
		$stone_chest/AnimationPlayer.play("Open")
		$KeyArea/CollisionShape3D.set_deferred("disabled",true)


func _on_key_area_area_entered(area: Area3D) -> void:
	if area.key_name == "stone_key":
		$stone_chest/AnimationPlayer.play("Open")
		$KeyArea/CollisionShape3D.set_deferred("disabled",true)
		$KeyArea/Unlock.play()
		Gameplay.storeContainerOpening(self)
		if content == "coin":
			Gameplay.spawnCoin(position+Vector3(0,0.2,0),coin_amount) #0.2, such that the content spawns inside the chest
		else:
			Gameplay.spawnItem(position+Vector3(0,0.2,0),content,false,0) #spawns the content at the position of the container. the content is not permanent, thus false is given to spawnItem()
