extends CharacterBody3D

var id: int

@export var does_respawn: bool

var permanency_status = true

var type = "NPC"

var enemy_name = "tree_man"

var body_type = "hardbody"

var item_drop = ["coin",800]

var coin_drop_base = 800

var coin_error = 150

@export var health: float = 1000.0

@export var experience: float = 1000.0

@export var resilience: float = 120

var resistance: Array = [-1,1,2,3] #standard,fire,dark,lightning

const is_boss = false

@onready var Gameplay = get_tree().root.get_node("Main/Gameplay")

@onready var torso_bone_id = $Armature/Skeleton3D.find_bone("Bone.003")
@onready var head_bone_id = $Armature/Skeleton3D.find_bone("Bone.002")
@onready var left_hand_bone_id = $Armature/Skeleton3D.find_bone("Bone_L.004")
@onready var right_arm_bone_id = $Armature/Skeleton3D.find_bone("Bone_R.003")

@onready var TorsoCollision = $HitBox/TorsoCollision
@onready var HeadCollision = $HitBox/HeadCollision

@onready var Animations = $AnimationPlayer

@onready var LineOfSight_R = $LineOfSight_R
@onready var LineOfSight_L = $LineOfSight_L

### AI Timers
@onready var GetUpTimer = $AI/GetUpTimer
@onready var LostTimer = $AI/LostTimer
@onready var AttackLight = $AI/AttackLight
@onready var AttackHeavy = $AI/AttackHeavy
@onready var IdleTime = $AI/IdleTime
@onready var DamageLight = $AI/DamageLight
@onready var DamageHeavy = $AI/DamageHeavy
@onready var DeathTimer = $AI/DeathTimer
@onready var HeavyDistributor = $AI/HeavyDistributor
@onready var RangedDelay = $AI/RangedDelay

@onready var Weapon = $LeftHandWeapon

@onready var LightRange = $LightRange
@onready var LightRangeShape = $LightRange/LightRangeShape
@onready var HeavyRange = $HeavyRange
@onready var HeavyRangeShape = $HeavyRange/HeavyRangeShape

@onready var HitBox = $HitBox

@onready var origin = global_position 

@onready var original_direction = Vector3(1,0,0).rotated(Vector3.UP,rotation.y + PI/2)

var player_position = Vector3(0,0,0)

@onready var direction = original_direction

var vision_range = 10.0

var current_animation = "Sitting_Idle"

var current_state = "sitting"

var idling = false

var following = false

var attacking_light = false

var attacking_heavy = false

var sitting = false

var sitting_down = false

var returning = false

var getting_damaged_light = false

var getting_damaged_heavy = false

var getting_up = false

var dying = false

var speed:float = 0


func _ready() -> void:
	updateState("sitting")


func updateState(new_state: String) -> void:
	idling = false
	following = false
	attacking_light = false
	attacking_heavy = false
	sitting = false
	sitting_down = false
	returning = false
	getting_damaged_light = false
	getting_damaged_heavy = false
	getting_up = false
	dying = false
	set(new_state,true)
	updateStateFunctions()
	current_state = new_state


func canSeePlayer(limit: float) -> bool:
	player_position = Gameplay.getPlayer().position
	var sight_r = player_position - LineOfSight_R.global_position + Vector3(0,1,0)
	var sight_l = player_position - LineOfSight_L.global_position + Vector3(0,1,0)
	var average_distance = (sight_r.length() + sight_l.length()) / 2
	LineOfSight_R.target_position = Vector3(sight_r - 0.5 * sight_r.normalized()).rotated(Vector3.UP,-rotation.y)
	LineOfSight_L.target_position = Vector3(sight_l - 0.5 * sight_l.normalized()).rotated(Vector3.UP,-rotation.y)
	if (LineOfSight_R.is_colliding() and LineOfSight_L.is_colliding()) or average_distance > limit:
		return false
	else:
		return true


func enableAttackRangeShapes(is_enabled: bool) -> void:
	if is_enabled:
		LightRangeShape.disabled = false
		HeavyRangeShape.disabled = false
	elif !is_enabled:
		LightRangeShape.disabled = true
		HeavyRangeShape.disabled = true
		


func updateAnimation(new_animation: String) -> void:
	if new_animation != current_animation:
		Animations.play(new_animation)
		current_animation = new_animation


func disableHurtBoxes() -> void:
	Weapon.get_node("Weapon/CollisionShape3D").disabled = true


func stopTimers() -> void:
	for timer in $AI.get_children():
		timer.stop()


func updateStateFunctions() -> void:
	#stopTimers()
	disableHurtBoxes()
	HeavyRangeShape.disabled = true
	if getting_up:
		velocity.x = 0
		velocity.z = 0
		updateAnimation("Get_up")
		GetUpTimer.start()
	if idling:
		velocity.x = 0
		velocity.z = 0
		updateAnimation("Standing_Still")
		IdleTime.start(randf_range(2,4))
		if current_state == "idling":
			vision_range = 10
	if sitting:
		velocity.x = 0
		velocity.z = 0
		updateAnimation("Sitting_Idle")
	if sitting_down:
		velocity.x = 0
		velocity.z = 0
		Animations.play_backwards("Get_up")
		GetUpTimer.start()
	if attacking_light:
		velocity.x = 0
		velocity.z = 0
		updateAnimation("Attack_2")
		AttackLight.start()
	if attacking_heavy:
		velocity.x = 0
		velocity.z = 0
		updateAnimation("Attack_1")
		AttackHeavy.start()
	if following or returning:
		updateAnimation("Walk")
		if following:
			enableAttackRangeShapes(true)
			HeavyDistributor.start()
	if getting_damaged_light or getting_damaged_heavy:
		velocity.x = 0
		velocity.z = 0
		enableAttackRangeShapes(false)
		if getting_damaged_light:
			updateAnimation("Light_Hit")
			#stopTimers()
			DamageLight.start()
			if current_state == "following":
				vision_range = 20
		if getting_damaged_heavy:
			updateAnimation("Heavy_Hit")
			DamageHeavy.start()
			if current_state == "following":
				vision_range = 20
	if dying:
		velocity.x = 0
		velocity.z = 0
		updateAnimation("Death")
		DeathTimer.start()


func turnTowardsDirection(goal_direction: Vector3,turning_vector: Vector3,rate_of_change: float) -> Vector3:
	var orthogonal_vec: Vector2 = Vector2(goal_direction.x,goal_direction.z).rotated(PI/2).normalized() ##orthogonal vector, simply rotate 
	var flat_turning_vector = Vector2(turning_vector.x,turning_vector.z).normalized()
	var turned_vector: Vector3 = Vector3(0,0,0)
	if flat_turning_vector.dot(orthogonal_vec) < -0.05:
		turned_vector = turning_vector.rotated(Vector3.UP,-rate_of_change)
	elif flat_turning_vector.dot(orthogonal_vec) > 0.05:
		turned_vector = turning_vector.rotated(Vector3.UP,+rate_of_change)
	else:
		if goal_direction.dot(turning_vector) < 0:
			turned_vector = turning_vector.rotated(Vector3.UP,+rate_of_change)
		else:
			turned_vector = turning_vector
	rotation.y = atan2(turned_vector.x,turned_vector.z) + PI
	return turned_vector.normalized()



func _physics_process(delta: float) -> void:
	## update the position of the hitboxes. This is always the case
	TorsoCollision.position = $Armature/Skeleton3D.to_global($Armature/Skeleton3D.get_bone_global_pose(torso_bone_id).origin) - global_position
	HeadCollision.position = $Armature/Skeleton3D.to_global($Armature/Skeleton3D.get_bone_global_pose(head_bone_id).origin) - global_position
	move_and_slide()
	velocity.y -= 9.81 * delta ##gravity physics
	if following:
		var follow_direction = Gameplay.getPlayer().position - global_position
		var new_velocity = turnTowardsDirection(follow_direction,direction,0.025)
		velocity.x = new_velocity.x
		velocity.z = new_velocity.z
		direction.x = velocity.x
		direction.z = velocity.z
		if !canSeePlayer(vision_range):
			updateState("idling")
	elif idling:
		if canSeePlayer(vision_range):
			updateState("following")
			IdleTime.stop()
	elif returning:
		var follow_direction = origin - global_position
		var new_velocity = turnTowardsDirection(follow_direction,direction,0.025)
		velocity.x = new_velocity.x
		velocity.z = new_velocity.z
		direction.x = velocity.x
		direction.z = velocity.z
		if follow_direction.length() < 0.45:
			updateState("sitting_down")
		if canSeePlayer(vision_range):
			updateState("following")
	elif sitting_down:
		direction = turnTowardsDirection(original_direction,direction,0.025)
	if health <= 0.0 and current_state != "dying":
		updateState("dying")



func _on_player_detector_body_entered(_body: Node3D) -> void:
	if current_state == "sitting":
		updateState("getting_up")
	else:
		_on_get_up_timer_timeout()


func _on_get_up_timer_timeout() -> void:
	if current_state == "getting_up":
		updateState("idling")
	elif current_state == "sitting_down":
		updateState("sitting")


func _on_player_detector_body_exited(_body: Node3D) -> void:
	LostTimer.start(1.5)


func _on_lost_timer_timeout() -> void:
	pass


func _on_hit_box_area_entered(area: Area3D) -> void:
	var hitter_parent = area.get_parent()
	if "area_type" in hitter_parent:
		if hitter_parent.area_type == "hurt_box": #prevents hitboxes to be detected as sources of damage (only hurtboxes allowed). get_parent because the area is the weapon area3d and not the node controlling the variabless
			if !(HitBox in hitter_parent.store_collision): #prevents the hurtbox from hitting twice or more if it is left during a single attack
				var health_prior = health
				CombatFunctions.playHitSound(hitter_parent,self)
				CombatFunctions.addHitExperience(Gameplay,area,self)
				Signals.take_damage.emit(area,self)
				hitter_parent.store_collision.append(HitBox)
				if current_state == "sitting":
					updateState("getting_up")
				else:
					var health_posterior = health
					if health_prior - health_posterior > resilience:
						updateState("getting_damaged_heavy")
					else:
						updateState("getting_damaged_light")


func _on_idle_time_timeout() -> void:
	updateState("returning")


func _on_damage_light_timeout() -> void:
	stopTimers()
	updateState("idling")


func _on_damage_heavy_timeout() -> void:
	stopTimers()
	updateState("idling")


func _on_death_timer_timeout() -> void:
	Gameplay.spawnCoin(position,Gameplay.coinCalculator(coin_drop_base,coin_error))
	#Gameplay.spawnItem(position,item_drop,false,0)
	CombatFunctions.addKillExperience(Gameplay,experience)
	CombatFunctions.killAndUpdate(self)


func _on_light_range_body_entered(_body: Node3D) -> void:
	LightRangeShape.disabled = true
	updateState("attacking_light")


func _on_attack_light_timeout() -> void:
	Weapon.store_collision = []
	LightRangeShape.disabled = false
	updateState("idling")


func _on_attack_heavy_timeout() -> void:
	HeavyRangeShape.disabled = false
	updateState("idling")


func _on_heavy_range_body_entered(_body: Node3D) -> void:
	updateState("attacking_heavy")
	RangedDelay.start()


func _on_ranged_delay_timeout() -> void:
	if current_state == "attacking_heavy":
		Gameplay.addMisc(load("res://Scenes/Enemies/Tree_Man/root_attack.tscn").instantiate(),Gameplay.getPlayer().position - Vector3(0,0.5,0),Vector3(0,randf_range(0,2*PI),0))


func _on_heavy_distributor_timeout() -> void:
	if current_state == "following":
		HeavyRange.position = Vector3(randf_range(5,10),0,0).rotated(Vector3.UP,randf_range(0,2 * PI))
		HeavyDistributor.start()
