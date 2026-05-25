extends Area3D

var key_name = ""

var was_used = false

func _physics_process(delta: float) -> void:
	if was_used:
		self.queue_free()
	else:
		was_used = true
