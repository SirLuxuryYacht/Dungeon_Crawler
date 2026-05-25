extends StaticBody3D

@onready var Gameplay = get_tree().root.get_node("Main/Gameplay")
@onready var HitBox = $HitBox


func _ready() -> void:
	if Gameplay.isDoorOpened(self):
		$broken_part_keyframes/AnimationPlayer.play("Animation")
		for i in 8:
			get_node("Collision"+str(i+1)).set_deferred("disabled",true)
			HitBox.get_node("Collision"+str(i+1)).set_deferred("disabled",true)


func _on_hit_box_area_entered(_area: Area3D) -> void:
	$broken_part_keyframes/AnimationPlayer.play("Animation")
	for i in 8:
		get_node("Collision"+str(i+1)).set_deferred("disabled",true)
		HitBox.get_node("Collision"+str(i+1)).set_deferred("disabled",true)
	$AudioStreamPlayer3D.play()
	Gameplay.storeDoorOpening(self)
