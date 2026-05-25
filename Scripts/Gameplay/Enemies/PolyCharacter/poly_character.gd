extends CharacterBody3D

var id: int

var type = "NPC"

var enemy_name = "lyrian"

var body_type = "hardbody"

var item_drop = "longsword"

const is_boss = true

@onready var dummy_body = Node3D.new()

@export var passive = false

@onready var tilted = !passive

@onready var RightFootSound = $PolyCharacter/Armature/Skeleton3D/Foot_R/StepSound_R
@onready var LeftFootSound = $PolyCharacter/Armature/Skeleton3D/Foot_L/StepSound_L

@onready var _AnimationPlayer = $PolyCharacter/AnimationPlayer
@onready var AI = $AI
@onready var PassiveDecider = $AI/PassiveDecider
@onready var CircleTime = $AI/CircleTime
@onready var PrepareTimer = $AI/PrepareTimer
@onready var ForgetTimer = $AI/ForgetTimer
@onready var RetreatTimer = $AI/RetreatTimer

@onready var AttackTimer = $AI/AttackTimer

@onready var Main = get_tree().root.get_node("Main")
@onready var Gameplay = Main.get_node("Gameplay")

@onready var HitBox = $HitBox

@onready var HurtBoxAnimation = $HurtBoxAnimation 

@onready var RightHandWeapon = $PolyCharacter/Armature/Skeleton3D/Hand_R/RightHandWeapon
@onready var LeftHandWeapon = $PolyCharacter/Armature/Skeleton3D/Hand_L/LeftHandWeapon


#var velocity = Vector3.ZERO

var acceleration = -9.81

@export var resistance = [2.5,5,1,0.25] #physical, fire, dark, lightning

@export var resilience = 200

@export var health_max  = 500

@onready var health = health_max

@export var coin_drop_base = 3000

var coin_error = 0

@export var experience = 1500

######## ai variables
var idle_speed = 2

var aggressive_speed = 5

var speed = idle_speed

var spawn_position = Vector3.ZERO

var passive_distance = 20

var aggressive_distance = 20

var passive_direction = Vector3(1,0,0)

var aggressive_direction = Vector3(1,0,0)

var clockwise = true

var can_attack = true

var circling = false

var approaching = false

var stare_at_player = true

var unprepared = true

var retreating = false

var strolling = false

var idle = true

var current_animation: String = "Default"

var was_hit = false

var has_died = false

var detect_player = false

var attack_length = 0.5

var light_time = 1.291

var heavy_time = 1.458

var jump_back_time = 1

var jump_strength = 4


func _ready() -> void:
	_AnimationPlayer.set_default_blend_time(0.5)
	_on_passive_decider_timeout()
	if passive:
		$RetreatArea.monitoring = false
		$PlayerDetector.monitoring = false


func randomBool() -> bool:
	var i = randi_range(0,1)
	if i == 0:
		return false
	else:
		return true


func updateRotation(direction) -> void:
	if direction != Vector3.ZERO:
		rotation.y = atan2(direction.x,direction.z) + PI


func getPlayerDistance() -> Vector3:
	return Gameplay.getPlayerPosition() - position


func curveMovement(travel_direction,delta) -> void:
	var curve_tightness = 2
	if detect_player:
		curve_tightness = 4
	var omega = 0
	if atan2(travel_direction.rotated(Vector3.UP,-rotation.y).x,1) > 0.1: #determines the angle between the player direction and the direction the spider is facing. then sets a rotation direction
		omega = -curve_tightness
	elif atan2(travel_direction.rotated(Vector3.UP,-rotation.y).x,1) < -0.1:
		omega = curve_tightness
	else:
		omega = 0 #no rotation if the angle is inside a certain margin +- 0.1
	if travel_direction.length() != 0:
		if Vector2(velocity.x,velocity.z) == Vector2.ZERO:
			velocity = Vector3(0,0,-1).rotated(Vector3.UP,rotation.y)
		#velocity.x = speed * travel_direction.x #why minus z direction????????
		#velocity.z = speed * travel_direction.z
		var plane_direction = velocity.rotated(Vector3.UP,delta * omega).normalized()
		velocity.x = speed * plane_direction.x
		velocity.z = speed * plane_direction.z
		updateRotation(velocity)


func chasePlayer(delta) -> void:
	curveMovement(getPlayerDistance(),delta)


func retreat(delta) -> void:
	curveMovement(-getPlayerDistance(),delta)


func circlePlayer(delta) -> void:
	curveMovement(circlePlayerDirection(getPlayerDistance(),clockwise),delta)


func passiveMovement(delta) -> void:
	curveMovement(passive_direction,delta)


func standStill() -> void:
	if is_on_floor():
		velocity.x = 0
		velocity.z = 0


func passiveDecider() -> void:
	if randomBool():
		idle = !idle
		strolling = !strolling


func updateAnimation(animation: String) -> void:
	if current_animation != animation:
		_AnimationPlayer.stop()
		_AnimationPlayer.play(animation)
		current_animation = animation


func easeVelocity(_delta) -> void:
	#velocity.x += easyness * delta * (velocity.x - velocity.x)
	velocity = velocity
	velocity.y = velocity.y
	#velocity.z += easyness * delta * (velocity.x - velocity.z)


func _physics_process(delta: float) -> void:
	if !has_died:
		move_and_slide()
		if detect_player:
			if unprepared:
				updateRotation(getPlayerDistance())
				standStill()
			elif circling:
				circlePlayer(delta)
			elif retreating:
				retreat(delta)
			elif approaching:
				chasePlayer(delta)
				if can_attack and getPlayerDistance().length() < 1:
					punch()
			else: pass
		else:
			if strolling:
				passiveMovement(delta)
		
		if is_on_floor() and !can_attack:
			velocity.x = 0
			velocity.z = 0
		
		if health < 0:
			health = 0
			stopTimers()
			$Essence/DeathTimer.start()
			has_died = true
			interruptAggressiveness()
			updateAnimation("T_Pose")
			
	velocity.y += delta * acceleration
	easeVelocity(delta)


func changeStateTo(state: String) -> void:
	match state:
		"circling":
			circling = true
			approaching = false
			retreating = false
		"approaching":
			approaching = true
			retreating = false
			circling = false
		"retreating":
			retreating = true
			circling = false
			approaching = false
		"none":
			retreating = false
			approaching = false
			circling = false


func retreatDecider(_health: float, max_health: float,p_max:float) -> void:
	var random_float = randf_range(0,1)
	var likelihood = 0
	if _health < max_health / 2:
		likelihood = p_max * _health / (max_health / 2)
	else:
		likelihood = abs(2 * p_max * (1 - _health / max_health)) #guarantees a positive probability
	if likelihood > random_float:
		updateAnimation("Jog")
		changeStateTo("retreating")
		RetreatTimer.start()


func interruptAggressiveness() -> void:
	changeStateTo("none")


func circlePlayerDirection(direction_to_player,clockwise_: bool) -> Vector3:
	var circle_direction = Vector3.ZERO
	if clockwise_:
		circle_direction = direction_to_player.rotated(Vector3.UP,PI/2)
	else:
		circle_direction = direction_to_player.rotated(Vector3.UP,-PI/2)
	return circle_direction.normalized()


func stopTimers() -> void:
	for i in AI.get_child_count():
		AI.get_child(i).stop()


func leapTowardsEnemy() -> void:
	interruptAggressiveness()
	can_attack = false
	AttackTimer.start(heavy_time)
	if randomBool():
		updateAnimation("JumpAttack_r_heavy")
		HurtBoxAnimation.play("heavy_r")
	else:
		updateAnimation("JumpAttack_l_heavy")
		HurtBoxAnimation.play("heavy_l")
	velocity = getPlayerDistance().normalized() * aggressive_speed
	velocity.y += jump_strength
	CombatFunctions.particleImpact(Gameplay,"strong",self.position,"dust",Vector3.ZERO,false)


func probability(percent: float) -> bool:
	var rand = randf_range(0.001,100)
	if rand < percent:
		return true
	else:
		return false


func jumpBack() -> void:
	stopTimers()
	interruptAggressiveness()
	can_attack = false
	AttackTimer.start(jump_back_time)
	var player_direction = getPlayerDistance().normalized()
	velocity = Vector3(-jump_strength * player_direction.x,velocity.y + jump_strength,-jump_strength * player_direction.z)
	updateAnimation("Jump")


func punch() -> void:
	stopTimers()
	interruptAggressiveness()
	can_attack = false  
	AttackTimer.start(light_time)
	if randomBool():
		updateAnimation("Punch_r_light")
		HurtBoxAnimation.play("light_r")
	else:
		updateAnimation("Punch_l_light")
		HurtBoxAnimation.play("light_l")
	velocity = Vector3(0,velocity.y,0)


func _on_player_detector_body_entered(_body: Node3D) -> void:
	interruptAggressiveness()
	PassiveDecider.stop()
	speed = aggressive_speed
	detect_player = true
	if unprepared:
		PrepareTimer.start()
		updateAnimation("Idle")
	else:
		_on_circle_time_timeout()
		updateAnimation("Jog")


func _on_player_detector_body_exited(_body: Node3D) -> void:
	if !is_boss:
		interruptAggressiveness()
		CircleTime.stop()
		RetreatTimer.stop()
		PrepareTimer.stop()
		detect_player = false
		speed = idle_speed
		updateAnimation("Walk")
		_on_passive_decider_timeout()
		ForgetTimer.start(3)
	

func randomDirection() -> Vector3:
	return Vector3(1,0,0).rotated(Vector3.UP,randf_range(0,2*PI))


func circleDecider() -> void:
	if can_attack:
		if randomBool():
			changeStateTo("circling")
			clockwise = randomBool()
		else:
			changeStateTo("approaching")
		CircleTime.start(randf_range(2,4))
		updateAnimation("Jog")


func _on_circle_time_timeout() -> void:
	circleDecider()


func randomSpeed(state: String) -> float:
	var random_speed = 0
	match state:
		"passive":
			if randomBool():
				random_speed = idle_speed
		"aggressive":
			random_speed = aggressive_speed
	return random_speed


func _on_retreat_area_body_entered(_body: Node3D) -> void:
	if can_attack:
		retreatDecider(health,health_max,0.5)


func _on_prepare_timer_timeout() -> void:
	_on_circle_time_timeout()
	unprepared = false


func _on_retreat_timer_timeout() -> void:
	can_attack = true
	if !has_died:
		_on_circle_time_timeout()


func _on_passive_decider_timeout() -> void:
	passive_direction = randomDirection()
	passiveDecider()
	if idle:
		standStill()
		updateAnimation("Idle")
	else:
		updateAnimation("Walk")
	PassiveDecider.start(randf_range(1,2))


func _on_forget_timer_timeout() -> void:
	unprepared = true
	if passive:
		tilted = false


func _on_foot_area_l_body_entered(_body: Node3D) -> void:
	LeftFootSound.pitch_scale = randf_range(0.9,1.1)
	LeftFootSound.play()


func _on_foot_area_r_body_entered(_body: Node3D) -> void:
	LeftFootSound.pitch_scale = randf_range(0.9,1.1)
	RightFootSound.play()


func _on_attack_timer_timeout() -> void:
	can_attack = true
	$LightRange/CollisionShape3D.set_deferred("disabled",false)
	$HeavyRange/CollisionShape3D.set_deferred("disabled",false)
	LeftHandWeapon.store_collision = []
	RightHandWeapon.store_collision = []
	if detect_player:
		_on_circle_time_timeout()
	else:
		_on_passive_decider_timeout()


func _on_hit_box_area_entered(area: Area3D) -> void:
	if !tilted:
		tilted = true
		_on_player_detector_body_entered(dummy_body)
	
	var hitter_parent = area.get_parent()
	if "area_type" in hitter_parent:
		if hitter_parent.area_type == "hurt_box": #prevents hitboxes to be detected as sources of damage (only hurtboxes allowed). get_parent because the area is the weapon area3d and not the node controlling the variabless
			var health_prior = health
			if !(HitBox in hitter_parent.store_collision): #prevents the hurtbox from hitting twice or more if it is left during a single attack
				updateAnimation("Hit")
				CombatFunctions.playHitSound(hitter_parent,self)
				CombatFunctions.addHitExperience(Gameplay,area,self)
				Signals.take_damage.emit(area,self)
				hitter_parent.store_collision.append(HitBox)
			var health_posterior = health
			if health_prior - health_posterior > resilience:
				#HitInterruption.start()
				was_hit = true
				#$HitMajor.pitch_scale = randf_range(0.9,1.1)
				#$HitMajor.play()
			else:
				pass
				#$HitMinor.pitch_scale = randf_range(0.9,1.1)
				#$HitMinor.play()


func _on_heavy_range_body_entered(_body: Node3D) -> void:
	if can_attack and is_on_floor() and !unprepared:
		if randomBool():
			leapTowardsEnemy()
			$HeavyRange/CollisionShape3D.set_deferred("disabled",true)
			$LightRange/CollisionShape3D.set_deferred("disabled",true)


func _on_light_range_body_entered(_body: Node3D) -> void:
	if can_attack and is_on_floor() and !unprepared:
		if probability(80):
			punch()
			$HeavyRange/CollisionShape3D.set_deferred("disabled",true)
			$LightRange/CollisionShape3D.set_deferred("disabled",true)
		else:
			jumpBack()


func _on_death_timer_timeout() -> void:
	Gameplay.spawnCoin(position,Gameplay.coinCalculator(coin_drop_base,coin_error))
	Gameplay.spawnItem(position,item_drop,false,0)
	CombatFunctions.addKillExperience(Gameplay,experience)
	CombatFunctions.killAndUpdate(self)
