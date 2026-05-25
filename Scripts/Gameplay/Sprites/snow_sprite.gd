extends Sprite3D

var float_direction: Vector3

var float_velocity: float

var lifetime: float

var snow_path_1 = "res://Textures/Sprite/Snow/snow.png"

var snow_path_2 = "res://Textures/Sprite/Snow/snow_2.png"

@onready var variation = randf_range(0.8,1.2)

@onready var random_vector = Vector3(1,0,0).rotated(Vector3(0,0,1),randf_range(-PI/2,PI/2)).rotated(Vector3.UP,randf_range(0,2*PI))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if randf_range(0,1) < 0.8:
		self.texture = load(snow_path_1)
	else:
		self.texture = load(snow_path_2)
	$Lifetime.start(lifetime + lifetime / 3 * randf_range(-1,1))
	float_direction += 0.2 * random_vector

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += variation * float_direction.normalized() * float_velocity * delta


func _on_lifetime_timeout() -> void:
	self.queue_free()


func _on_collision_area_body_entered(body: Node3D) -> void:
	self.queue_free()
