extends CharacterBody3D

var initial_velocity = randf_range(0,4) * Vector3.UP.rotated(Vector3(1,0,0),randf_range(0,PI/2)).rotated(Vector3.UP,randf_range(0,2*PI))

@onready var Shape = $ShapeCast3D

signal projection_request

var is_projecting = false

var persistence_interval: float = 10

var fade_time: float = 2

var elapsed_time: float = 0

func _ready() -> void:
	projection_request.connect(projectDecal)
	print(initial_velocity)
	velocity = initial_velocity


func _physics_process(delta: float) -> void:
	elapsed_time += delta
	if !is_projecting:
		if !Shape.is_colliding():
			move_and_slide()
			gravity(delta)
		else:
			projection_request.emit()
	
	if elapsed_time > persistence_interval:
		if elapsed_time >= persistence_interval + fade_time:
			self.queue_free()
		$Decal.modulate = Color(1,1,1,(fade_time + persistence_interval - elapsed_time) / fade_time)


func gravity(delta) -> void:
	velocity.y -= delta * 9.81


func setDecalTexture(texture: Texture2D) -> void:
	$Decal.texture_albedo = texture
	$Decal.texture_emission = texture


func projectDecal() -> void:
	is_projecting = true
	var collision_normal = Shape.get_collision_normal(0)
	if collision_normal != Vector3.UP:
		GeomFuncs.changeBasis(collision_normal,collision_normal - Vector3.UP,self)
