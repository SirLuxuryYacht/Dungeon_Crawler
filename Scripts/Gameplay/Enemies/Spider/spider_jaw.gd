extends Node3D

var item_name = "spider_jaw"

var weapon_type = "blunt"

var attack_type = "light"

var area_type = "hurt_box"

var store_collision = []

var damage = [0,0,0,0]

var light_damage = [80,0,0,0] #standard,fire,dark,lightning, default [80,0,0,0]

var heavy_damage = [130,0,0,0]

var light_stamina_cost = 60

var heavy_stamina_cost = 120

var attacking = false

var has_hit = false

@onready var HurtBox = null

#@onready var TestSword = $TestSword
#@onready var Placeholder = $Placeholder


func get_hurt_box() -> Node:
	return HurtBox #returns a collisionshape3d
