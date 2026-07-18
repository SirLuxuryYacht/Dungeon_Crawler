extends Node3D

@onready var FireSprite = $FireSprite

var texture_id = randi_range(1,4)

func _ready() -> void:
	$OmniLight3D.light_color = Color(242/256,randi_range(155,175)/256,32/256,1)
	FireSprite.texture = load("res://Textures/Sprite/Muzzle_Fire/muzzle_flash_"+str(texture_id)+".png")
	FireSprite.scale = 0.75 * randf_range(0.8,1.2) * Vector3(1,1,1)
	if randi_range(1,2) == 1:
		FireSprite.flip_h = true
	if randi_range(1,2) == 1:
		FireSprite.flip_v = true

func _on_self_delete_timeout() -> void:
	self.queue_free()
