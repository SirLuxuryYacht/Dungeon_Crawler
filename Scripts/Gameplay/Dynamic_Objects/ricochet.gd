extends AudioStreamPlayer3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Timeout.start()
	pitch_scale = randf_range(0.95,1.05)
	play()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_timeout_timeout() -> void:
	self.queue_free()
