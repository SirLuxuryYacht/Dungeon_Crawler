extends Node3D

@onready var Light = $Light
@onready var HurtBox = $Weapon/HurtBox #this is called weapon in order to use the generalized damage sound function

var continuous #variable to determine the continuous damage nature of this node

var environmental_damage = [0,10,0,0] #standard, fire, dark, lightning

var attack_type = "environmental"

var weapon_type = "environmental"

var area_type = "hurt_box"

var store_collision = []

func doEnvironmentalDamage() -> void:
	HurtBox.set_deferred("disabled",!HurtBox.disabled)
	store_collision = []


func get_hurt_box() -> Node:
	return HurtBox


func _physics_process(_delta: float) -> void:
	doEnvironmentalDamage()
	Light.light_energy = randf_range(0.9,1.4)
