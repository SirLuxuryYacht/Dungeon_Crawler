extends Node3D

@export var sound_paths: PackedStringArray = []

@export var radius: float = 200.0

@export_range (0,3) var attenuation_model: int = 3

@export var decibel_scale: float = 0

@export_range (0,100) var chance_for_silence: int = 0

@export_range (1,3) var silence_length_bias: int = 1

@onready var silence_short = "res://Sounds/Misc/silence_10.ogg"

@onready var silence_medium = "res://Sounds/Misc/silence_20.ogg"

@onready var silence_long = "res://Sounds/Misc/silence_30.ogg"

func changeLocationAndPlay(stream: AudioStreamPlayer3D) -> void:
	stream.position = stream.position.rotated(Vector3.UP,randf_range(-3*PI/2,3*PI/2))
	var random_stream_index = randi_range(0,sound_paths.size()-1)
	if randi_range(0,100) > chance_for_silence:
			stream.stream = load(sound_paths[random_stream_index])
	else:
		match silence_length_bias:
			1:
				stream.stream = load(silence_short)
			2:
				stream.stream = load(silence_medium)
			3:
				stream.stream = load(silence_long)
	stream.play()


func _ready() -> void:
	for sound in sound_paths:
		var new_sound = AudioStreamPlayer3D.new()
		new_sound.set_attenuation_model(attenuation_model)
		if randi_range(0,100) > chance_for_silence:
			new_sound.stream = load(sound)
		else:
			match silence_length_bias:
				1:
					new_sound.stream = load(silence_short)
				2:
					new_sound.stream = load(silence_medium)
				3:
					new_sound.stream = load(silence_long)
		new_sound.position = Vector3(radius,0,0).rotated(Vector3.UP,randf_range(0,2 * PI))
		new_sound.volume_db = decibel_scale
		new_sound.connect("finished",changeLocationAndPlay.bind(new_sound))
		add_child(new_sound)
		new_sound.play()
