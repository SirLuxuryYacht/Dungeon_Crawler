extends CharacterBody3D

var player_weapon

var item_name = "projectile"

var weapon_type = "blunt"

var attack_type = "light"

var area_type = "hurt_box"

var store_collision = []

@export var damage = [0,0,0,0]

var light_damage: Array #standard,fire,dark,lightning

var heavy_damage: Array

var lifetime = 0

var model = null

var gravitation = Vector3(0,-9.81,0)

var initial_velocity

var timer = 0

var start_velocity

var initial_damage

var damping

var projectile_visible = false

var radius

var bounce_amount = 0

@onready var Gameplay = get_tree().root.get_node("Main/Gameplay")
@onready var Weapon = $Weapon
@onready var GeometryInteractor = $InteractionArea

func _ready() -> void:
	velocity = initial_velocity
	start_velocity = initial_velocity
	initial_damage = damage
	$Lifetime.start(lifetime)
	if model != null:
		$Weapon/MeshInstance3D.mesh = model
	$Weapon/CollisionShape3D.shape.radius = radius
	$InteractionArea/CollisionShape3D.shape.radius = radius


func _physics_process(delta: float) -> void:
	move_and_slide()
	velocity += delta * (gravitation - damping * (velocity.length())**2 * velocity.normalized())
	var temp_damage = []
	for i in damage.size():
		if i == 0:
			temp_damage.append(initial_damage[i] * (velocity.length() / start_velocity.length()))
		else:
			temp_damage.append(initial_damage[i])
	light_damage = temp_damage 
	heavy_damage = temp_damage #this could be solved more elegantly, but for now its ok (this wont get changed anyway)
	timer += delta
	var flight_rotation = atan2(velocity.y,sqrt(velocity.x**2 + velocity.z**2))
	Weapon.rotation.x = flight_rotation
	GeometryInteractor.rotation.x = flight_rotation
	if !projectile_visible:
		projectile_visible = true
		$Weapon/MeshInstance3D.visible = true


func setDamage(value: Array) -> void:
	damage = value


func _on_lifetime_timeout() -> void:
	self.queue_free()


func _on_interaction_area_body_entered(body: Node3D) -> void:
	var impact_position = $InteractionArea/RayCast3D.get_collision_point()
	var normal_vector = $InteractionArea/RayCast3D.get_collision_normal().normalized()
	var material = body.get_child(0).get_name()
	if (material == "Stone" or material == "Metal") and bounce_amount <= 3: #not all projectiles shoult bounce off, some should immediately have an effect
		if abs(acos(-velocity.normalized().dot(normal_vector))) > randf_range(1.1,1.3) and normal_vector != Vector3.ZERO: #1.3 is about 60 degrees
			velocity = -velocity.rotated(normal_vector,PI)
			bounce_amount += 1
		else:
			self.queue_free()
	else:
		self.queue_free()
	if velocity.length() > 10:
		CombatFunctions.particleImpact(Gameplay,"medium",impact_position,"dust",normal_vector,true)
		Gameplay.addMisc(load("res://Scenes/SoundPlayers/ricochet.tscn").instantiate(),position,Vector3.ZERO)


func _on_interaction_area_area_entered(area: Area3D) -> void: #mainly for water, maybe also for something else
	var impact_position = $InteractionArea/RayCast3D.get_collision_point()
	var normal_vector = $InteractionArea/RayCast3D.get_collision_normal().normalized()
	var material = area.get_child(0).get_name()
	if material == "Water" and bounce_amount <= 3:
		if abs(acos(-velocity.normalized().dot(normal_vector))) > randf_range(1.4,1.5) and normal_vector != Vector3.ZERO: #1.3 is about 60 degrees
			velocity = -0.5 * velocity.rotated(normal_vector,PI)
			bounce_amount += 1
		else:
			velocity = 0.05 * velocity
	else:
		self.queue_free()
	CombatFunctions.particleImpact(Gameplay,"medium",impact_position,"water",normal_vector,false)
	Gameplay.addMisc(load("res://Scenes/SoundPlayers/splash.tscn").instantiate(),position,Vector3.ZERO)


func _on_weapon_body_entered(body: Node3D) -> void:
	Gameplay.addMisc(load("res://Scenes/SoundPlayers/ricochet.tscn").instantiate(),position,Vector3.ZERO)
