extends Node3D

var item_name = "root_attack"

var weapon_type = "sharp"

var attack_type = "light"

var area_type = "hurt_box"

var store_collision = []

var damage = [0,0,0,0]

var light_damage = [80,0,0,0] #standard,fire,dark,lightning, default [80,0,0,0]

var heavy_damage = [130,0,0,0]

@onready var Weapon = $Weapon

func _ready() -> void:
	pass


func _on_self_delete_timeout() -> void:
	self.queue_free()


func _on_active_delay_timeout() -> void:
	$SelfDelete.start()
	$AnimationPlayer.play("Spread")
	$Weapon/RootAttackShape.disabled = false
