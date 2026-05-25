extends CharacterBody3D

@onready var HeadBone = $npc_f_rigged_1/Armature/Skeleton3D/Head_2
@onready var Gameplay = get_tree().root.get_node("Main/Gameplay")

var entity_present = false

var Entity = null

var type = "npc"

var character_name = "test" #the name of this npc as designated in the dialogue script

func lookAt(Who: Node3D) -> void:
	HeadBone.rotation.y = atan2(Who.position.x - position.x,Who.position.z - position.z) + PI - rotation.y
	HeadBone.rotation.y = atan2(Who.position.x - position.x,Who.position.z - position.z) + PI - rotation.y


func _physics_process(_delta: float) -> void:
	if entity_present:
		lookAt(Entity)
	


func _on_aggression_area_body_entered(body: Node3D) -> void:
	Entity = body
	entity_present = true


func _on_aggression_area_body_exited(body: Node3D) -> void:
	if body == Entity:
		entity_present = false
