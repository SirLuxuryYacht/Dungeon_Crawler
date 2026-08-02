extends Node3D

@export var do_position_randomizer: bool = false
@export var position_range: float = 1.0
@export var restrict_position_to_xy: bool = true
@export var do_scale_ranzomizer: bool = false
@export var scale_range: float = 0.2
@export var do_rotation_randomizer: bool = false
@export var restrict_rotation_to_y: bool = false

func _ready() -> void:
	for nodes in get_children():
		var node_position = nodes.position
		var node_rotation = nodes.rotation
		var node_scale = nodes.scale
		if do_position_randomizer:
			node_position.x = GeomFuncs.randomizeByInputValue(node_position.x,position_range,node_position.x)
			node_position.z = GeomFuncs.randomizeByInputValue(node_position.z,position_range,node_position.z)
			if !restrict_position_to_xy:
				node_position.y = GeomFuncs.randomizeByInputValue(node_position.y,position_range,node_position.y)
		if do_scale_ranzomizer:
			node_scale.x = GeomFuncs.randomizeByInputValue(node_scale.x,scale_range,node_position.x + node_position.y + node_position.z)
			node_scale.y = node_scale.x
			node_scale.z = node_scale.x
			nodes.scale = Vector3(node_scale.x,node_scale.x,node_scale.z)
		if do_rotation_randomizer:
			node_rotation.y = GeomFuncs.randomizeByInputValue(node_rotation.y,2 * PI,node_position.x + node_position.y + node_position.z)
			if !restrict_rotation_to_y:
				node_rotation.x = GeomFuncs.randomizeByInputValue(node_rotation.x,2 * PI,node_rotation.x)
				node_rotation.z = GeomFuncs.randomizeByInputValue(node_position.z,2 * PI,node_rotation.z)
			nodes.rotation = node_rotation
