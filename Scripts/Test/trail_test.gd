extends CharacterBody3D

@onready var Gameplay = get_tree().root.get_node("Main/Gameplay")

func _ready() -> void:
	velocity = Vector3(50,30,90)
	CombatFunctions.addProjectileTrail(Gameplay,15,20,velocity,self)

func _physics_process(delta: float) -> void:
	move_and_slide()
