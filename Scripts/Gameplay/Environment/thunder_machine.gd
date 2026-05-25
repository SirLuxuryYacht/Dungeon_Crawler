extends Node3D

var distance = 500

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Pause.start(randf_range(1,5))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_pause_timeout() -> void:
	$SoundMachine.position = distance * Vector3(1,0,0).rotated(Vector3.UP,randf_range(0,2*PI))
	$SoundMachine.stop()
	$SoundMachine.play()
	$Pause.start(randf_range(5,15))
