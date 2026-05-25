extends Node3D

var player_weapon

@export var item_name = "poleaxe"

@export var weapon_type = "sharp"

var attack_type = "light"

var area_type = "hurt_box"

var store_collision = []

var damage = [0,0,0,0]

@export var light_damage = [60,0,0,15] #standard,fire,dark,lightning

@export var heavy_damage = [100,0,0,15]

@export var light_stamina_cost = 120

@export var heavy_stamina_cost = 160

@export var light_attack_blocker = 0.4

@export var heavy_attack_blocker = 0.5

@export var heavy_ready_time = 0.3

@export var ready_param = [[Vector3(0.1,0.1,0),Vector3(-PI/2,0,0)],[Vector3(-0.8,0,0),Vector3(-PI/2,0,0)]] #both position and rotation of the ready state of the weapon

@onready var Weapon = $Weapon
@onready var HurtBox = $Weapon/HurtBox
@onready var Pivot = $Pivot


func _ready() -> void:
	HurtBox.set_deferred("disabled",true)


func getPivotAnimation() -> Node3D:
	return $AnimationPlayer


func getSound(type: String) -> AudioStreamPlayer3D:
	if type == "light":
		return  $Weapon/Light
	elif type == "heavy":
		return $Weapon/Heavy
	elif type == "hit":
		return $Weapon/Hit
	else:
		return null


func resetPivot() -> void:
	Pivot.position = Vector3.ZERO
	Pivot.rotation = Vector3.ZERO


func _physics_process(delta: float) -> void:
	Weapon.position -= 15 * delta *(Weapon.position - Pivot.position) #inertia, the weapon lags behind the Pivot, which is moved by the attack animation/function
	Weapon.rotation -= 15 * delta *(Weapon.rotation - Pivot.rotation)
	#resetPivot()
