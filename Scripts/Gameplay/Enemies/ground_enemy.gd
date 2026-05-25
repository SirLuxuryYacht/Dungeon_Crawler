extends CharacterBody3D

var id: int

var type = "NPC"

@export var enemy_name: String #"spider"

@export var body_type = ""

@export var item_drop = ""

@export var drop_chance = 0.0

@onready var _AnimationPlayer = $Model/AnimationPlayer
@onready var AI = $AI
@onready var AttackInterval = $AI/AttackInterval
@onready var DeathTimer = $AI/DeathTimer
@onready var HitInterruption = $AI/HitInterruption
@onready var AttackOnset = $AI/AttackOnset
@onready var AttackDuration = $AI/AttackDuration
@onready var IdleDecider = $AI/IdleDecider
@onready var ForgetTimer = $AI/ForgetTimer
@onready var DetectorEnableDelay = $AI/DetectorEnableDelay
@onready var Gameplay = get_tree().root.get_node("Main/Gameplay")
@onready var PlayerDetector = $PlayerDetector
@onready var WeaponParent = $RightHand/SpiderJaw
@onready var WeaponCollision = $RightHand/SpiderJaw/Weapon/CollisionShape3D
@onready var HitBox = $HitBox

@onready var Step = $Step
@onready var StepTimer = $StepTimer

var acceleration = -9.81

@export var light_damage: PackedInt32Array = [80,0,0,0]

@export var heavy_damage: PackedInt32Array = [130,0,0,0]

@export var resistance: PackedFloat32Array = [1.0,-1.0,1.0,1.0] #spider is immune to fire

@export var resilience: int = 20

@export var health_max: int

@export var agility: float = 2.0

@export var memory: float = 3.0

@export var walk_sound_interval: float = 0.1

@onready var health = health_max

@export var coin_drop_base: int = 15

var coin_error = floor(sqrt(coin_drop_base))

@export var experience: int = 20

######## ai variables
@export var idle_speed: float = 1.3

@export var aggressive_speed: float = 2.0

var speed = idle_speed

var spawn_position = Vector3.ZERO

@export var passive_distance: int = 10

@export var aggressive_distance: int = 20

var travel_direction: Vector3 = Vector3(1,0,0)

var can_attack: bool = true

var was_hit: bool = false

var has_died: bool = false

var detect_player = false

var has_stepped = false

@export var onset_time: float = 0.3 #this should be short, at least shorter than the attack animation

var dummy_body = StaticBody3D.new()


func updateRotation(direction) -> void:
	if direction != Vector3.ZERO:
		rotation.y = atan2(direction.x,direction.z) + PI


func getPlayerDistance() -> Vector3:
	return Gameplay.getPlayerPosition() - position


func getTravelDistance() -> float:
	return (position - spawn_position).length()


func passiveMovement(delta) -> void:
	var omega = 0
	if travel_direction != Vector3.ZERO:
		if atan2(travel_direction.rotated(Vector3.UP,-rotation.y).x,1) > 0.1: #determines the angle between the player direction and the direction the spider is facing. then sets a rotation direction
			omega = -float(agility / 2)
		elif atan2(travel_direction.rotated(Vector3.UP,-rotation.y).x,1) < -0.1:
			omega = float(agility / 2)
		else:
			omega = 0 #no rotation if the angle is inside a certain margin +- 0.1
		if can_attack and !was_hit:
			if velocity == Vector3.ZERO:
				velocity = speed * Vector3(0,0,-1).rotated(Vector3.UP,rotation.y) #why minus z direction????????
			velocity = speed * velocity.rotated(Vector3.UP,delta * omega).normalized()
			updateRotation(velocity)
			updateAnimation("Walk")
	else:
		velocity = Vector3.ZERO
		updateAnimation("Idle")


func chasePlayer(delta) -> void:
	travel_direction = getPlayerDistance()
	var omega = 0
	if atan2(travel_direction.rotated(Vector3.UP,-rotation.y).x,1) > 0.1: #determines the angle between the player direction and the direction the spider is facing. then sets a rotation direction
		omega = -agility
	elif atan2(travel_direction.rotated(Vector3.UP,-rotation.y).x,1) < -0.1:
		omega = float(agility / 2)
	else:
		omega = 0 #no rotation if the angle is inside a certain margin +- 0.1
	if travel_direction.length() != 0:
		if can_attack and !was_hit:
			if velocity == Vector3.ZERO:
				velocity = speed * Vector3(0,0,-1).rotated(Vector3.UP,rotation.y) #why minus z direction????????
			velocity = speed * velocity.rotated(Vector3.UP,delta * omega).normalized()
			updateRotation(velocity)
			updateAnimation("Run")
		else:
			velocity = Vector3.ZERO
	if travel_direction.length() < 0.8 and can_attack:
		AttackInterval.start()
		AttackOnset.start(onset_time)
		can_attack = false
		updateAnimation("Attack")


func updateAnimation(animation: String) -> void:
	if animation != _AnimationPlayer.current_animation:
		_AnimationPlayer.play(animation,1)


func _ready() -> void:
	ParameterFunctions.applyShaderParameters("NPC",self,Gameplay.getCurrentMap().map_brightness)
	PlayerDetector.get_node("CollisionShape3D").shape.radius = passive_distance
	spawn_position = position
	WeaponParent.light_damage = light_damage
	WeaponParent.heavy_damage = heavy_damage
	IdleDecider.set_wait_time(randf_range(0.5,1))
	IdleDecider.start()


func canSeePlayer() -> bool:
	$PlayerVision.target_position = (Gameplay.getPlayerPosition()+Vector3(0,0.4,0) - self.global_position).rotated(Vector3.UP,-rotation.y)
	if $PlayerVision.is_colliding():
		return false
	else:
		return true


func deviation(input: float, attack: float) -> float:
	return (1 - exp(-(1.0/attack) * sqrt(input)))*sqrt(input)



func _physics_process(delta: float) -> void:
	move_and_slide()
	if !is_on_floor():
		velocity.y += acceleration * delta
	else:
		if velocity != Vector3.ZERO and !has_stepped:
			Step.pitch_scale = randf_range(0.9,1.1)
			Step.play()
			StepTimer.start(randf_range(walk_sound_interval - deviation(walk_sound_interval,2),walk_sound_interval + deviation(walk_sound_interval,2)))
			has_stepped = true
		if detect_player and !has_died:
			if !canSeePlayer():
				passiveMovement(delta)
				if ForgetTimer.is_stopped():
					ForgetTimer.start(memory)
			else:
				chasePlayer(delta)
		else:
			if !has_died and !was_hit:
				passiveMovement(delta)
	if health <= 0 and !has_died:
		velocity = Vector3.ZERO
		has_died = true
		DeathTimer.start(_AnimationPlayer.get_animation("Death").length)
		updateAnimation("Death")


func _on_attack_interval_timeout() -> void:
	can_attack = true
	WeaponCollision.set("disabled",true)


func _on_player_detector_body_entered(_body: Node3D) -> void:
	if !detect_player:
		detect_player = true
		speed = aggressive_speed
		PlayerDetector.get_node("CollisionShape3D").shape.radius = aggressive_distance
	$PlayerVision.set_deferred("enabled",true)


func _on_player_detector_body_exited(_body: Node3D) -> void:
	if detect_player:
		detect_player = false
		speed = idle_speed
		travel_direction = Vector3.ZERO
		IdleDecider.set_wait_time(randf_range(0.5,1))
		IdleDecider.start()
		PlayerDetector.get_node("CollisionShape3D").shape.radius = passive_distance
	$PlayerVision.set_deferred("enabled",false)


func _on_hit_box_area_entered(area: Area3D) -> void:
	if area.name == "DarknessBox":
		ParameterFunctions.applyShaderParameters("NPC",self,0.0)
	var hitter_parent = area.get_parent()
	if "area_type" in hitter_parent:
		if hitter_parent.area_type == "hurt_box": #prevents hitboxes to be detected as sources of damage (only hurtboxes allowed). get_parent because the area is the weapon area3d and not the node controlling the variabless
			var health_prior = health
			if !(HitBox in hitter_parent.store_collision): #prevents the hurtbox from hitting twice or more if it is left during a single attack
				_AnimationPlayer.play("Hit",1)
				CombatFunctions.playHitSound(hitter_parent,self)
				CombatFunctions.addHitExperience(Gameplay,area,self)
				Signals.take_damage.emit(area,self)
				hitter_parent.store_collision.append(HitBox)
			var health_posterior = health
			if health_prior - health_posterior > resilience:
				HitInterruption.start()
				was_hit = true
				$HitMajor.pitch_scale = randf_range(0.9,1.1)
				$HitMajor.play()
			else:
				$HitMinor.pitch_scale = randf_range(0.9,1.1)
				$HitMinor.play()


func _on_death_timer_timeout() -> void:
	Gameplay.spawnItem(position,"coin",false,Gameplay.coinCalculator(coin_drop_base,coin_error))
	CombatFunctions.addKillExperience(Gameplay,experience)
	CombatFunctions.killAndUpdate(self)
	if randf_range(0,0.999) >= (1 - drop_chance) and item_drop != "": #exclude the case where the random number is 1, should be unnoticable
		Gameplay.spawnItem(position,item_drop,false,0)


func _on_hit_interruption_timeout() -> void:
	was_hit = false


func _on_attack_duration_timeout() -> void:
	WeaponCollision.set("disabled",true)


func _on_attack_onset_timeout() -> void:
	AttackDuration.start(_AnimationPlayer.get_animation("Attack").length - onset_time)
	WeaponCollision.set("disabled",false)
	WeaponParent.store_collision = []


func _on_idle_decider_timeout() -> void:
	IdleDecider.set_wait_time(randf_range(1,2))
	IdleDecider.start()
	if getTravelDistance() > 10:
		travel_direction = spawn_position - position
	else:
		var coin_flip = randi_range(0,1)
		if coin_flip == 0:
			travel_direction = Vector3(1,0,0).rotated(Vector3.UP,randf_range(0,2*PI))
		else:
			travel_direction = Vector3.ZERO


func _on_step_timer_timeout() -> void:
	has_stepped = false


func _on_forget_timer_timeout() -> void:
	_on_player_detector_body_exited(dummy_body)
	PlayerDetector.get_child(0).set_deferred("disabled",true)
	DetectorEnableDelay.start()


func _on_detector_enable_delay_timeout() -> void:
	PlayerDetector.get_child(0).set_deferred("disabled",false)


func _on_hit_box_area_exited(area: Area3D) -> void:
	if area.name == "DarknessBox":
		ParameterFunctions.applyShaderParameters("NPC",self,Gameplay.getCurrentMap().map_brightness)
