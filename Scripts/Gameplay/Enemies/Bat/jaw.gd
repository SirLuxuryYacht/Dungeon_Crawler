extends Node3D

var item_name = "jaw"

var weapon_type = "melee"

var store_collision = []

var damage = [100,0,0,0]

var light_damage = [50,0,0,0] #standard,fire,dark,lightning

var heavy_damage = [100,0,0,0]

var light_stamina_cost = 60

var heavy_stamina_cost = 120

var attacking = false

var has_hit = false

@onready var HurtBox = $HurtBox/HurtBox

#@onready var TestSword = $HurtBox


func get_hurt_box() -> Node:
	return HurtBox #returns a collisionshape3d


func _ready() -> void:
	pass


func _physics_process(delta: float) -> void:
	if HurtBox.disabled == false:
		pass
