extends CharacterBody3D

var id: int

var type = "NPC"

var enemy_name = "strange_fish"

var body_type = "softbody"

@export var item_drop = "nothing"

const is_boss = false

@onready var dummy_body = Node3D.new()

@onready var Gameplay = get_tree().root.get_node("Main/Gameplay")

@onready var PlayerDetector = $PlayerDetector
@onready var LightRange = $LightRange
@onready var HeavyRange = $HeavyRange

@onready var IdleTimer = $AI/IdleTimer
@onready var CircleTimer = $AI/CircleTimer
@onready var AttackBlocker = $AI/AttackBlocker
@onready var DeathTimer = $AI/DeathTimer

@onready var Animations = $strange_fish2/AnimationPlayer

var has_died = false

var detect_player = false

var speed: float

var attacking = false

var pursuing = false

var circling = false

var approaching = false

var retreating = false

var idle = true

var aggressive = false

var clockwise = false

var target_velocity: Vector3

@export var idle_speed: float = 1

@export var aggressive_speed: float = 5

@export var agility: float

@export var inverse_inertia: float = 15

@export var light_attack_duration: float

@export var heavy_attack_duration: float

@onready var idle_direction = Vector3(1,0,0).rotated(Vector3.UP,randf_range(0,2*PI))

var acceleration = -9.81

@export var resistance: PackedFloat32Array = [2.5,5.0,1.0,0.25] #physical, fire, dark, lightning

@export var resilience = 200

@export var health_max  = 500

@onready var health = health_max

@export var coin_drop_base = 3000

var coin_error = 0

@export var experience = 1500


func vectorToPlayer() -> Vector3:
	return Gameplay.getPlayerPosition() - position


func updateRotation(direction) -> void:
	if direction != Vector3.ZERO:
		rotation.y = atan2(direction.x,direction.z) + PI


func randomBool() -> bool:
	if randi_range(0,1) == 1:
		return true
	else:
		return false


func circlePlayerDirection(direction_to_player,clockwise_: bool) -> Vector3:
	var circle_direction = Vector3.ZERO
	if clockwise_:
		circle_direction = direction_to_player.rotated(Vector3.UP,PI/2)
	else:
		circle_direction = direction_to_player.rotated(Vector3.UP,-PI/2)
	return circle_direction.normalized()


func circlePlayer(delta) -> void:
	curveMovement(circlePlayerDirection(vectorToPlayer(),randomBool()),delta)


func curveMovement(travel_direction,delta) -> void:
	var curve_tightness = agility / 2
	if aggressive:
		curve_tightness = agility
	var omega = 0
	if atan2(travel_direction.rotated(Vector3.UP,-rotation.y).x,1) > 0.2: #determines the angle between the player direction and the direction the spider is facing. then sets a rotation direction
		omega = -curve_tightness
	elif atan2(travel_direction.rotated(Vector3.UP,-rotation.y).x,1) < -0.2:
		omega = curve_tightness
	else:
		omega = 0 #no rotation if the angle is inside a certain margin +- 0.2
	if travel_direction.length() != 0:
		if Vector2(velocity.x,velocity.z) == Vector2.ZERO:
			velocity = Vector3(0,0,-1).rotated(Vector3.UP,rotation.y)
		#velocity.x = speed * travel_direction.x #why minus z direction????????
		#velocity.z = speed * travel_direction.z
		var plane_direction = velocity.rotated(Vector3.UP,delta * omega).normalized()
		target_velocity.x = speed * plane_direction.x
		target_velocity.z = speed * plane_direction.z
		updateRotation(velocity)


func stateUpdater(new_state: String) -> void:
	stopAllTimers(["DeathTimer"])
	match new_state:
		"approaching":
			approaching = true
			retreating = false
			circling = false
			attacking = false
		"retreating":
			approaching = false
			retreating = true
			circling = false
			attacking = false
		"circling":
			approaching = false
			retreating = false
			circling = true
			attacking = false
		"attacking":
			approaching = false
			retreating = false
			circling = false
			attacking = true
		"passive":
			approaching = false
			retreating = false
			circling = false
			attacking = false
		"dead":
			unalive()
			has_died = true


func randomDirection() -> Vector3:
	return Vector3(1,0,0).rotated(Vector3.UP,randf_range(0,2 * PI))


func toggleRangeAreas(disabled: bool) -> void:
	if disabled:
		LightRange.get_node("CollisionShape3D").set_deferred("disabled",true)
		HeavyRange.get_node("CollisionShape3D").set_deferred("disabled",true)
	else:
		LightRange.get_node("CollisionShape3D").set_deferred("disabled",false)
		HeavyRange.get_node("CollisionShape3D").set_deferred("disabled",false)


func toggleDetectorArea(disabled: bool) -> void:
	if disabled:
		PlayerDetector.get_node("CollisionShape3D").set_deferred("disabled",true)
	else:
		PlayerDetector.get_node("CollisionShape3D").set_deferred("disabled",false)


func stopAllTimers(exception: Array) -> void:
	for node in $AI.get_children():
		if (node is Timer) and (node.name not in exception):
			node.stop()


func updateAnimations(new_animation: String) -> void:
	if Animations.current_animation != new_animation:
		Animations.play(new_animation,0.25)


func likelihood(probability: float) -> bool:
	if probability > randf_range(0,0.9999):
		return true
	else:
		return false


func calculateInertVelocity(goal_velocity: Vector3,delta) -> void:
	velocity.x += -delta * inverse_inertia * (velocity.x - goal_velocity.x)
	velocity.z += -delta * inverse_inertia * (velocity.z - goal_velocity.z)


func unalive() -> void:
	toggleRangeAreas(true)
	toggleDetectorArea(true)
	await DeathTimer.is_stopped()
	DeathTimer.start()
	health = 0


func _physics_process(delta: float) -> void:
	calculateInertVelocity(target_velocity,delta)
	velocity.y += acceleration * delta
	if !has_died:
		move_and_slide()
		if !aggressive:
			curveMovement(idle_direction,delta)
		else:
			if !attacking:
				if circling:
					curveMovement(circlePlayerDirection(vectorToPlayer(),clockwise),delta)
				if approaching:
					curveMovement(vectorToPlayer(),delta)
				if retreating:
					curveMovement(-vectorToPlayer(),delta)
			else:
					curveMovement(vectorToPlayer(),delta)
		if Vector2(get_real_velocity().x,get_real_velocity().z).length() < 0.05 and is_on_floor():
			target_velocity = randomDirection()
		if health <= 0:
			stateUpdater("dead")


func _on_player_detector_body_entered(_body: Node3D) -> void:
	aggressive = true
	speed = aggressive_speed
	_on_circle_timer_timeout()


func _on_player_detector_body_exited(_body: Node3D) -> void:
	aggressive = false
	_on_idle_timer_timeout()
	stateUpdater("passive")


func _on_idle_timer_timeout() -> void:
	IdleTimer.start(randf_range(1,3))
	if likelihood(0.8):
		speed = idle_speed
		updateAnimations("Walk")
	else:
		speed = 0
		updateAnimations("Idle")
	idle_direction = randomDirection()


func _on_circle_timer_timeout() -> void:
	if likelihood(0.5):
		stateUpdater("approaching")
	elif likelihood(0.5):
		stateUpdater("circling")
	else:
		stateUpdater("retreating")
	updateAnimations("Run")
	CircleTimer.start(randf_range(1,2.5))
	if likelihood(0.1):
		$Talk.play()


func _on_attack_blocker_timeout() -> void:
	_on_circle_timer_timeout()
	toggleRangeAreas(false)


func _on_light_range_body_entered(_body: Node3D) -> void:
	stateUpdater("attacking")
	AttackBlocker.start(light_attack_duration)
	toggleRangeAreas(true)
	if randomBool():
		updateAnimations("Light_1")
	else:
		updateAnimations("Light_2")


func _on_heavy_range_body_entered(_body: Node3D) -> void:
	if likelihood(0.5):
		stateUpdater("attacking")
		AttackBlocker.start(heavy_attack_duration)
		toggleRangeAreas(true)
		updateAnimations("Heavy_1")



func _ready() -> void:
	pass


func _on_death_timer_timeout() -> void:
	Gameplay.spawnCoin(position,Gameplay.coinCalculator(coin_drop_base,coin_error))
	Gameplay.spawnItem(position,item_drop,false,0)
	CombatFunctions.addKillExperience(Gameplay,experience)
	CombatFunctions.killAndUpdate(self)
