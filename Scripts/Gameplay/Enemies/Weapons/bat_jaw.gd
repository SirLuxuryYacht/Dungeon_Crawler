extends Node3D

var item_name = "test_sword"

var weapon_type = "melee"

var attack_type = "light"

var area_type = "hurt_box"

var store_collision = []

var damage = [0,0,0,0]

var light_damage = [400,0,0,0] #standard,fire,dark,lightning

var heavy_damage = [100,0,0,0]

var light_stamina_cost = 60

var heavy_stamina_cost = 120

var attacking = false

var has_hit = false

@onready var HurtBox = get_node("Weapon/HurtBox")

#@onready var TestSword = $TestSword
#@onready var Placeholder = $Placeholder


func get_hurt_box() -> Node:
	return HurtBox #returns a collisionshape3d


func _ready() -> void:
	pass


func _physics_process(_delta: float) -> void:
	if HurtBox.disabled == false:
		pass
