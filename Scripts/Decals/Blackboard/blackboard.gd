extends MeshInstance3D


@export var texture: String 


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if texture != "":
		$Decal.texture_albedo = load(texture)
