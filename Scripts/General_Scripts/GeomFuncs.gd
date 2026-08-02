extends Node

func changeBasis(new_normal: Vector3,another_vector: Vector3,whose_base: Node) -> void:
	var new_y = new_normal.normalized()
	var new_x = new_y.cross(another_vector).normalized()
	var new_z = new_x.cross(new_y).normalized()
	whose_base.global_transform.basis = Basis(new_x,new_y,new_z)



func randomizeByInputValue(input: float, range: float, modifier: float) -> float:
	return input + range * cos(modifier + 50 * PI)
