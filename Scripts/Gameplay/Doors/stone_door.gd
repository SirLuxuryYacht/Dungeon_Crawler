extends Node3D

@onready var Gameplay = get_tree().root.get_node("Main/Gameplay")

@export var key_type: String

@onready var door_name = key_type+"_door"

@onready var key_name = key_type+"_key"

func _ready() -> void:	
	if Gameplay.isDoorOpened(self):
		get_node("Door/OpenAnimation").play("Animation")
		$KeyArea/CollisionShape3D.set_deferred("disabled",true)


func _on_key_area_area_entered(area: Area3D) -> void:
	if area.key_name == key_name:
		get_node("Door/OpenAnimation").play("Animation")
		$KeyArea/CollisionShape3D.set_deferred("disabled",true)
		$KeyArea/Unlock.play()
		Gameplay.storeDoorOpening(self)


func _on_hit_box_area_entered(_area: Area3D) -> void:
	if $Door.has_node("BreakAnimation"):
		$KeyArea/CollisionShape3D.set_deferred("disabled",true)
		get_node("Door/BreakAnimation").play("break")
		$Door/CollisionShape3D.set_deferred("disabled",true) #deactivates collision and hitbox when hit
		$Door/HitBox/CollisionShape3D.set_deferred("disabled",true)
	if self.has_node("Door/BreakSound"):
		self.get_node("Door/BreakSound").pitch_scale = randf_range(0.95,1.05)
		self.get_node("Door/BreakSound").play()
