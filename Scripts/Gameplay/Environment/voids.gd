extends Node3D



func _on_void_1_area_entered(area: Area3D) -> void:
	if "type" in area.get_parent():
		if area.get_parent().type == "item":
			area.queue_free()


func _on_void_1_body_entered(body: Node3D) -> void:
	if body.name == "Player" or body.name == "NPC":
		body.health = 0
		if body.name == "Player":
			body.voided = true
	else:
		body.queue_free()
