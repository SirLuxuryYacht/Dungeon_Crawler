extends Node3D

var impact_angle: float = 0

var lifetime: float = 1.0

var particle_amount: int = 16

var initial_particle_velocity_min: float = 4.0

var initial_particle_velocity_max: float = 8.0

var normal_vector = Vector3(10,0,10)

var player_position = Vector3.ZERO

var Sprite = null

var is_frontal: bool

@export var debris_lifetime: float = 3.0

@onready var GlowParticles = $GlowParticles
@onready var Debris = $Debris
@onready var ImpactLight = $ImpactLight
@onready var SelfDelete = $SelfDelete
@onready var LightSwitch = $LightSwitch

var sprite_fader: float = 0

func _ready() -> void:
	
	GlowParticles.amount = particle_amount
	GlowParticles.lifetime = lifetime
	GlowParticles.process_material.set_param_min(0,initial_particle_velocity_min)
	GlowParticles.process_material.set_param_max(0,initial_particle_velocity_max)
	
	Debris.amount = particle_amount
	Debris.lifetime = debris_lifetime #arbitrary
	Debris.process_material.set_param_min(0,initial_particle_velocity_min / 4)
	Debris.process_material.set_param_max(0,initial_particle_velocity_max / 4)
	
	GlowParticles.emitting = true
	Debris.emitting = true
	
	if impact_angle < 0.6: #about 35 degrees
		Sprite = $FrontViewSprite
		Sprite.sprite_frames = preload("res://SpriteSequences/bullet_impact_frontal.tres")
	else:
		Sprite = $SideViewSprite
		Sprite.sprite_frames = preload("res://SpriteSequences/bullet_impact_side.tres")
		
	Sprite.visible = true
	Sprite.scale = randf_range(0.75,1.2) * Sprite.scale
	
	Sprite.play()
	SelfDelete.start(debris_lifetime)
	LightSwitch.start()
	print("Position: "+str(global_position))
	print("Target: " +str(global_position + normal_vector))
	
	GeomFuncs.changeBasis(normal_vector,player_position - global_position,self)
	#changeBasis(normal_vector,player_position - global_position)
	
	if randi_range(1,2) == 1:
		Sprite.position.x = -Sprite.position.x
		Sprite.flip_h = true


func _physics_process(delta: float) -> void:
	var parameter = float(sprite_fader / lifetime)
	Sprite.modulate.a = 0.5 * (cos(PI * parameter**2) + 1)
	if parameter < 1:
		sprite_fader += delta
	#Pivot.look_at(position + normal_vector,Vector3(0,1,0))


func _on_self_delete_timeout() -> void:
	self.queue_free()


func _on_light_switch_timeout() -> void:
	ImpactLight.visible = false
