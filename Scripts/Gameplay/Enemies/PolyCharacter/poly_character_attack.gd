extends Node3D

var item_name = "poly_character_punch"

var weapon_type = "fist"

@export var attack_type = "light"

var area_type = "hurt_box"

@export var store_collision = []

var damage = [0,0,0,0]

var light_damage = [200,0,0,0] #standard,fire,dark,lightning

var heavy_damage = [300,0,0,0]


func _on_weapon_left_body_entered(_body: Node3D) -> void:
	$Weapon_Left/Hit.play()
