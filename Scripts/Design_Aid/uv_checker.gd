extends MeshInstance3D

func _process(delta: float) -> void:
	if Input.is_action_pressed("enlarge"):
		get_surface_override_material(0).uv1_scale -= delta * Vector3.ONE
		print(get_surface_override_material(0).uv1_scale)
	if Input.is_action_pressed("reduce"):
		get_surface_override_material(0).uv1_scale += delta * Vector3.ONE
		print(get_surface_override_material(0).uv1_scale)
