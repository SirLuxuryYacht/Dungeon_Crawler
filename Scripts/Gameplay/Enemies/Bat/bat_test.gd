extends CharacterBody3D

var id: int

var type = "NPC"

var enemy_name = "bat_test"

@onready var Gameplay = get_tree().root.get_node("Main/Gameplay")
@onready var HitBox = $HitBox
@onready var WeaponParent = $RightHand/BatJaw
@onready var Weapon = WeaponParent.get_node("Weapon")

@onready var Skeleton = $bat/Armature/Skeleton3D
@onready var AnimationPlayer_ = $bat/AnimationPlayer

@onready var start_position = position

var health = 100

var health_max = 100

var resistance = [1,1,1,1]

var damage

var coin_drop_base = 10

var coin_error = float(coin_drop_base) / 4 

var experience = 25

var returning = false #is bat returning home?

var passive = true

var passive_timer = 0

var passive_timer_max = randf_range(0.5,1)

var passive_speed = 4

var inertia = 2.5

var uninert_velocity = Vector3.ZERO #the velocity aimed for

########################## behavior variables
var bite_timer = 0

var bite_time = 3
##########################



func getHealth() -> float:
	return health


func setHealth(value: float) -> void:
	if value <= 0:
		health = 0
	else:
		health = value


func inertVelocity(delta) -> void:
	velocity += -inertia * delta * (velocity - uninert_velocity)


func distanceLimiter(maximum,minimum) -> void:
	var home_direction = -(position - start_position)
	var distance = home_direction.length()
	if distance > maximum:
		uninert_velocity = passive_speed * home_direction.normalized()
		rotation.y = atan2(velocity.x,velocity.z)
		returning = true
	if distance < minimum and returning:
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


func primitiveAttacking(delta) -> void:
	bite_timer += delta
	if bite_timer > bite_time * (1 - 0.5):
		WeaponParent.get_hurt_box().set_deferred("disabled", false)
	if bite_timer > bite_time:
		WeaponParent.get_hurt_box().set_deferred("disabled", true)
		WeaponParent.store_collision = []
		bite_timer = 0


func _ready() -> void:
	uninert_velocity = passive_speed * Vector3(1,0,0).rotated(Vector3.UP,randf_range(0,2*PI))
	rotation.y = atan2(velocity.x,velocity.z)
	WeaponParent.damage = WeaponParent.light_damage
	damage = WeaponParent.damage
	WeaponParent.get_hurt_box().disabled = true
	
	#Weapon.set_collision_layer_value(4,true)
	#Weapon.set_collision_mask_value(4,true)
	WeaponParent.damage = WeaponParent.light_damage

func _process(delta: float) -> void:
	primitiveAttacking(delta)
	AnimationPlayer_.play("Flight")
	inertVelocity(delta)
	passiveFlight(delta)
	move_and_slide()
	#Gameplay.generalizedDamager(HitBox,self)
	if health <= 0:
		Gameplay.spawnCoin(position,Gameplay.coinCalculator(coin_drop_base,coin_error))
		CombatFunctions.addKillExperience(Gameplay,experience)
		CombatFunctions.killAndUpdate(self)


func _on_hit_box_area_entered(area: Area3D) -> void:
	if "area_type" in area.get_parent():
		if area.get_parent().area_type == "hurt_box": #prevents hitboxes to be detected as sources of damage (only hurtboxes allowed). get_parent because the area is the weapon area3d and not the node controlling the variabless
			Signals.take_damage.emit(area,self)
