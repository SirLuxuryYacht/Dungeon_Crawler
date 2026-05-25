extends AudioStreamPlayer

@onready var Silence = $Silence
@onready var Fade = $Fade

var new_track = ""

func _ready() -> void:
	Signals.change_soundtrack.connect(soundtrackChanger)

func soundtrackChanger(track) -> void:
	Fade.start()
	new_track = track

func _on_silence_timeout() -> void:
	volume_linear = 1
	stream = load("res://Soundtrack/"+str(new_track)+".ogg")
	play()


func _on_fade_timeout() -> void:
	Silence.start()

func _process(_delta: float) -> void:
	if !Fade.is_stopped():
		volume_linear = Fade.get_time_left() / Fade.get_wait_time()


func _on_finished() -> void:
	play()
