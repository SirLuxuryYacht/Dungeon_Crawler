extends StaticBody3D

@onready var allow_texture_flipping = get_parent().allow_texture_flipping


func flipTextures() -> void:
	for child in get_children():
		if child is MeshInstance3D:
			child.get_surface_override_material(0).set_shader_parameter("DisableGreenChannel",true)
			child.get_surface_override_material(0).set_shader_parameter("UseAlternativeTexture",true)


func _ready() -> void:
	if allow_texture_flipping:
		flipTextures()
