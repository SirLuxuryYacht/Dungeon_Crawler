extends Node3D

var player_weapon

var item_name = "rifle"

var weapon_type = "blunt"

var attack_type = "light"

var area_type = "hurt_box"

var store_collision = []

var damage = [0,0,0,0]

var light_damage = [40,15,0,0] #standard,fire,dark,lightning

var heavy_damage = [40,15,0,0]

var light_stamina_cost = 30 #change later to a sensible value

var heavy_stamina_cost = 65 #dito

var light_attack_blocker = 1.3 #default 1.3

var heavy_attack_blocker = 1.3

var heavy_ready_time = 0.1

var light_projectile_speed = 225 #are light and heavy attacks better?

var heavy_projectile_speed = 225

var projectile_radius = 0.1

var ready_param = [[Vector3(-0.25,0.2,-0.05),Vector3(0,0,0)],[Vector3(-0.25,0.2,-0.05),Vector3(0,0,0)]] #both position and rotation of the ready state of the weapon

var pivot_rest_position = Vector3(0,-0.2,-0.15)

var pivot_rest_rotation = Vector3(-4*PI/11,PI/4,0)#Vector3(deg_to_rad(-60),deg_to_rad(90),0)

@onready var Pivot = $Pivot
@onready var Weapon = $Weapon

@onready var Muzzle = $Weapon/Origin/Model/Barrel/Muzzle
@onready var Muzzle2 = $Weapon/Origin/Model/Barrel/Muzzle2

@onready var MuzzleLight = Muzzle2.get_node("OmniLight3D")

@onready var Gameplay = get_tree().root.get_node("Main/Gameplay")

func _ready() -> void:
	resetPivot()


func projectileSpeed(attack_type_: String) -> float:
	var speed = light_projectile_speed
	if attack_type_ == "heavy":
		speed = heavy_projectile_speed
	return speed


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


func playRifleAnimation() -> void:
	$Weapon/Origin/Model/AnimationPlayer.play("trigger_and_reload")
	$Weapon/Origin/Model/Recoil.play("recoil")


func playReloadSound() -> void:
	$Weapon/Origin/Model/ReloadMechanism/ReloadSound.play()


func fire() -> void:
	if !MuzzleLight.visible:
		MuzzleLight.visible = true
	var firing_damage = damage
	if attack_type == "light":
		firing_damage = light_damage
	if attack_type == "heavy":
		firing_damage = heavy_damage
	var shot_direction = Muzzle2.global_position - Muzzle.global_position
	CombatFunctions.fireProjectile(Gameplay,load("res://Scenes/Weapons/projectile.tscn").instantiate(),projectile_radius,firing_damage,Gameplay.getPlayer().velocity + projectileSpeed(attack_type) * shot_direction,0.005,7,Muzzle.global_position,Vector3(0,Muzzle.global_rotation.y,0))
	CombatFunctions.particleImpact(Gameplay,"medium",Muzzle2.global_position,"dust",shot_direction,true)
	$FlashDuration.start()


func resetPivot() -> void:
	Pivot.position = pivot_rest_position
	Pivot.rotation = pivot_rest_rotation


func _physics_process(delta: float) -> void:
	Weapon.position -= 15 * delta * (Weapon.position - Pivot.position) #inertia, the weapon lags behind the Pivot, which is moved by the attack animation/function
	Weapon.rotation -= 15 * delta * (Weapon.rotation - Pivot.rotation)
	#resetPivot()


func _on_flash_duration_timeout() -> void:
	MuzzleLight.visible = false
