extends Area3D

var type = "item"

var item_name = "longsword"

var uniqueness = false

var amount = 0 #value of the coin, i want this to scale with enemy intensity

@onready var InteractionArea = $InteractionArea
@onready var Collision = $CollisionShape
@onready var velocity = Vector3.ZERO

var x_0 = Vector3(10,0,10)
var x_1 = x_0
var v_0 = Vector3(0,0.3,0) #three variables to give each other values like a ladder when solving newtons equation

var down_force = Vector3(0,-9.81,0)


func downfaller(delta) -> Vector3:
	if !has_overlapping_bodies():
		velocity += down_force * delta
		x_0 = x_1
		x_1 += velocity * delta
		velocity = (x_1 - x_0) / delta
	return (x_1 + x_0) / 2 #return average value


func _ready() -> void:
	velocity = v_0
	rotation.y = randf_range(0,2*PI)
	x_0 = position
	x_1 = position


func _physics_process(delta: float) -> void:
	position = downfaller(delta)
