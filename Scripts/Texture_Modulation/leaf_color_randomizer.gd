extends Node3D

@onready var Leaves: MeshInstance3D = $Leaves

@onready var tint = Leaves.get_surface_override_material(0).get_shader_parameter("Tint")

@export var is_shrubbery: bool = false

var rest_rotation: Vector3

var active = false

func randomizeLeafColorTint(color_to_modulate: Color) -> Color:
	var color_vector = Vector3(color_to_modulate.r,color_to_modulate.g,color_to_modulate.b)
	var rand_r = randf_range(-0.03,0.03)
	var rand_g = randf_range(-0.03,0.03)
	var rand_b = randf_range(-0.03,0.03)
	var rand = [rand_r,rand_g,rand_b]
	var index = 1
	for color_value in color_vector:
		if color_value < 0.03:
			color_value += abs(rand[index])
		elif tint.r > 0.97:
			color_value -= abs(rand[index])
		else:
			color_value += rand[index]
		index += 1
	return Color(color_vector.x,color_vector.y,color_vector.z)
			
func _ready() -> void:
	tint = randomizeLeafColorTint(tint)
	rest_rotation = rotation


func reactToOutsideForce() -> void:
	if active:
		$RustleNoise.play()


### maybe out of place in here, but as long as it works:
func _on_body_entered(_body: Node3D) -> void:
	if is_shrubbery:
		reactToOutsideForce()
	if !active:
		active = true
