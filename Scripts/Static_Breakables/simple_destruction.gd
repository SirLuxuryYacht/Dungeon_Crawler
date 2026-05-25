extends Node3D

@onready var HitBox = $HitBox
@onready var Model = $Model

@export var disappears: bool = false
@export var disappearance_time: float = 1


func makeInactive() -> void:
	for i in HitBox.get_child_count():
		HitBox.get_child(i).set_deferred("disabled",true)
		Model.get_child(i+1).set_deferred("disabled",true)


func destructionSequence() -> void:
	var vanishing_timer = Timer.new()
	self.add_child(vanishing_timer)
	vanishing_timer.timeout.connect(_on_vanishing_timer_timeout)
	vanishing_timer.start(disappearance_time)


func _on_hit_box_area_entered(_area: Area3D) -> void:
	$BreakSound.pitch_scale = randf_range(0.95,1.05)
	$BreakSound.play()
	$Model/AnimationPlayer.play("break")
	makeInactive()
	if disappears:
		destructionSequence()


func _on_vanishing_timer_timeout() -> void:
	self.queue_free()
