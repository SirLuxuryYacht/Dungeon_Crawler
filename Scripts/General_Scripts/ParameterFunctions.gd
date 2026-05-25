extends Node


func applyShaderParameters(scene_type: String,scene_root: Node3D,brightness: float) -> void:
	if scene_type == "NPC":
		for child in get_tree().get_nodes_in_group("MeshGroupNPC"):
			if child.owner != null:
				if child is MeshInstance3D and child.owner.id == scene_root.id:
					for surface_index in child.get_surface_override_material_count():
						child.get_active_material(surface_index).set("shader_parameter/MapBrightness",brightness)
	if scene_type == "container":
		for child in get_tree().get_nodes_in_group("MeshGroupContainer"):
			if child.owner != null:
				if child is MeshInstance3D and child.owner.id == scene_root.id:
					for surface_index in child.get_surface_override_material_count():
						child.get_active_material(surface_index).set("shader_parameter/MapBrightness",brightness)


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
