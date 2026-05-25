extends Node3D

@export var particle_amount: int

@export var effect_duration: float

@export var area_radius: float

@export var damping: float

@onready var Particles = $Particles

var gravitation = Vector3(0,-9.81,0)

var time: float = 0

var directions = []

var normal_vector

var texture

var shading: bool

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in particle_amount:
		var particle = CharacterBody3D.new()
		var sprite = Sprite3D.new()
		sprite.set_texture(load(texture))
		sprite.billboard = BaseMaterial3D.BILLBOARD_FIXED_Y
		sprite.shaded = shading
		var random_phi_2 = randf_range(0,2*PI)
		var random_theta_2 = randf_range(-PI,PI) #entire sphere
		var small_random_r = randf_range(0,area_radius) * Vector3(0,0,1).rotated(Vector3(1,0,0),random_theta_2).rotated(Vector3.UP,random_phi_2)
		var big_random_r = randf_range(0,25 * area_radius) * Vector3(0,0,1).rotated(Vector3(1,0,0),random_theta_2).rotated(Vector3.UP,random_phi_2)
		directions.append(50 * area_radius * normal_vector + big_random_r)
		Particles.add_child(particle)
		particle.add_child(sprite)
		particle.position = small_random_r
		particle.velocity = directions[i]
	$EffectDuration.start(effect_duration)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for i in particle_amount:
		var particle = Particles.get_child(i)
		var sprite = particle.get_child(0)
		particle.move_and_slide()
		particle.velocity += delta * gravitation - damping * particle.velocity
		sprite.modulate = Color(1,1,1,1 - time / effect_duration) 
	time += delta


func _on_effect_duration_timeout() -> void:
	self.queue_free()
