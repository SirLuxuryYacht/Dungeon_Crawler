extends Node3D

@export var item_name = "poly_character_punch"

@export var weapon_type = "fist"

var attack_type = "light"

var area_type = "hurt_box"

var store_collision = []

var damage = [0,0,0,0]

@export var light_damage = [200,0,0,0] #standard,fire,dark,lightning

@export var heavy_damage = [300,0,0,0]

@onready var Weapon = get_child(0)


func _ready() -> void:
	Weapon.get_node("CollisionShape3D").disabled = true


func _on_weapon_left_body_entered(_body: Node3D) -> void:
	Weapon.get_node("Hit").play()
