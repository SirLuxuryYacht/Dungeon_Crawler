extends Node3D

@onready var Snow = load("res://Scenes/Sprites/snow_sprite.tscn")

@export var mean_lifetime: float

@export var float_direction: Vector3

@export var wind_velocity: float

@export var snow_radius: float

@export var snow_density: float

@export var snow_multiplicity: int

var active = false


func createSnow(lifetime: float,size: float,velocity: float, direction: Vector3) -> void:
	var snow_instance = Snow.instantiate()
	snow_instance.pixel_size = size * randf_range(0.01,0.025)
	snow_instance.lifetime = lifetime
	snow_instance.float_direction = direction
	snow_instance.float_velocity = velocity
	snow_instance.position = Vector3(snow_radius,0,0).rotated(Vector3(0,0,1),randf_range(-PI/2,PI/2)).rotated(Vector3.UP,randf_range(0,2*PI))
	self.add_child(snow_instance)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Area3D.position = wind_velocity * float_direction


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if active:
		if randf_range(0,1) < snow_density:
			for i in snow_multiplicity:
				createSnow(mean_lifetime,1,wind_velocity,float_direction)


func _on_area_3d_body_entered(body: Node3D) -> void:
	active = true


func _on_area_3d_body_exited(body: Node3D) -> void:
	active = false
