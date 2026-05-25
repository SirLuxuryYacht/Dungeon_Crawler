extends CharacterBody3D

@onready var Skeleton = $bat/Armature/Skeleton3D
@onready var AnimationPlayer_ = $bat/AnimationPlayer
@onready var Gameplay = get_tree().root.get_node("Main/Gameplay")
@onready var shape = $bat

@onready var start_position = position

var returning = false #is bat returning home?

var passive = true

var passive_timer = 0

var passive_timer_max = randf_range(0.5,1)

var passive_speed = 8

var inertia = 2.5

var uninert_velocity = Vector3.ZERO #the velocity aimed for


func inertVelocity(delta) -> void:
	velocity += -inertia * delta * (velocity - uninert_velocity)


func distanceLimiter(max,min) -> void:
	var home_direction = -(position - start_position)
	var distance = home_direction.length()
	if distance > max:
		uninert_velocity = passive_speed * home_direction.normalized()
		rotation.y = atan2(velocity.x,velocity.z)
		returning = true
	if distance < min and returning:
		returning = false
		passive_timer = passive_timer_max


func passiveFlight(delta) -> void:
	distanceLimiter(10,5)
	if passive_timer >= passive_timer_max:
		passive_timer = 0
		passive_timer_max = randf_range(0.5,1)
		if !returning:
			uninert_velocity = passive_speed * uninert_velocity.normalized().rotated(Vector3.UP,randf_range(-PI/2,PI/2))
	rotation.y = atan2(velocity.x,velocity.z)
	passive_timer += delta



func _ready() -> void:
	uninert_velocity = passive_speed * Vector3(1,0,0).rotated(Vector3.UP,randf_range(0,2*PI))
	rotation.y = atan2(velocity.x,velocity.z)


func _process(delta: float) -> void:
	AnimationPlayer_.play("Flight")
	inertVelocity(delta)
	passiveFlight(delta)
	move_and_slide()
