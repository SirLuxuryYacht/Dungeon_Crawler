extends OmniLight3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	omni_range = randf_range(17,22)
	light_color = Color(1,0.72,randf_range(0.33,0.53))
