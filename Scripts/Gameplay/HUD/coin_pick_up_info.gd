extends Control

@onready var InfoLabel = $InfoLabel

var show_time = 2

var fade_time = 2

var timer = 0

func _physics_process(delta: float) -> void:
	timer += delta
	if timer > show_time:
		InfoLabel.modulate.a = (timer - (fade_time + show_time)) / (show_time - (fade_time + show_time))
	if timer > (fade_time + show_time):
		self.queue_free()
