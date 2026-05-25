extends Node3D

var item_name = "test_sword"

var weapon_type = "melee"

var attack_type = "light"

var area_type = "hurt_box"

var store_collision = []

var damage = [0,0,0,0]

var light_damage = [50,0,0,0] #standard,fire,dark,lightning

var heavy_damage = [100,0,0,0]

var light_stamina_cost = 30

var heavy_stamina_cost = 120


@onready var Weapon = $Weapon
@onready var HurtBox = $Weapon/HurtBox
@onready var Pivot = $Pivot


func get_hurt_box() -> Node:
	return HurtBox #returns a collisionshape3d


func _ready() -> void:
	HurtBox.set_deferred("disabled",true)

func getPivotAnimation() -> Node3D:
	return $AnimationPlayer

func _physics_process(delta: float) -> void:
	Weapon.position -= 15 * delta *(Weapon.position - Pivot.position) #inertia, the weapon lags behind the Pivot, which is moved by the attack animation/function
	Weapon.rotation -= 15 * delta *(Weapon.rotation - Pivot.rotation)
