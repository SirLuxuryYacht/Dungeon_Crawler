extends MeshInstance3D

var speed  = 0.0005

func _physics_process(delta: float) -> void:
	get_surface_override_material(0).uv1_offset.x -= delta * speed
	if get_surface_override_material(0).uv1_offset.x <= -1:
		get_surface_override_material(0).uv1_offset.x = 0
